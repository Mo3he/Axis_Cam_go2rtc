// SPDX-License-Identifier: MIT
//
// Minimal ACAP supervisor for go2rtc.
//
// The ACAP main executable (named after the appName, "go2rtc") launches the
// go2rtc_run shell script, restarts it if it dies, and forwards SIGTERM/SIGINT
// so the embedded go2rtc binary shuts down cleanly when the app is stopped.
//
// Runs as the unprivileged ACAP user. No root, no extra libraries.

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define APP_NAME   "go2rtc"
#define RUN_SCRIPT "/usr/local/packages/go2rtc/go2rtc_run"

static volatile sig_atomic_t stop_requested = 0;
static volatile pid_t child_pid = -1;

static void handle_term(int signo) {
    (void)signo;
    stop_requested = 1;
    if (child_pid > 0)
        kill(child_pid, SIGTERM);
}

static pid_t start_child(void) {
    pid_t pid = fork();
    if (pid < 0) {
        syslog(LOG_ERR, "fork failed: %s", strerror(errno));
        return -1;
    }
    if (pid == 0) {
        execl(RUN_SCRIPT, RUN_SCRIPT, (char *)NULL);
        syslog(LOG_ERR, "execl %s failed: %s", RUN_SCRIPT, strerror(errno));
        _exit(127);
    }
    syslog(LOG_INFO, "started %s (pid %d)", RUN_SCRIPT, pid);
    return pid;
}

int main(void) {
    openlog(APP_NAME, LOG_PID, LOG_USER);
    syslog(LOG_INFO, "supervisor starting");

    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = handle_term;
    sigaction(SIGTERM, &sa, NULL);
    sigaction(SIGINT, &sa, NULL);

    while (!stop_requested) {
        child_pid = start_child();
        if (child_pid < 0) {
            sleep(5);
            continue;
        }

        int status;
        pid_t r;
        do {
            r = waitpid(child_pid, &status, 0);
        } while (r < 0 && errno == EINTR && !stop_requested);

        if (stop_requested)
            break;

        if (WIFEXITED(status))
            syslog(LOG_WARNING, "go2rtc exited (code %d), restarting",
                   WEXITSTATUS(status));
        else if (WIFSIGNALED(status))
            syslog(LOG_WARNING, "go2rtc killed (signal %d), restarting",
                   WTERMSIG(status));

        /* brief backoff so a crash-on-start does not hot-loop */
        for (int i = 0; i < 3 && !stop_requested; i++)
            sleep(1);
    }

    if (child_pid > 0) {
        kill(child_pid, SIGTERM);
        for (int i = 0; i < 30; i++) {
            if (waitpid(child_pid, NULL, WNOHANG) == child_pid) {
                child_pid = -1;
                break;
            }
            usleep(100000);
        }
        if (child_pid > 0) {
            kill(child_pid, SIGKILL);
            waitpid(child_pid, NULL, 0);
        }
    }

    syslog(LOG_INFO, "supervisor stopped");
    closelog();
    return 0;
}
