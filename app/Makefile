PROG = go2rtc
SRCS = supervisor.c
CFLAGS += -Wall -Wextra -O2 -std=gnu11
LDFLAGS += -Wl,-z,noexecstack

all: $(PROG)
	chmod +x go2rtc_run

$(PROG): $(SRCS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

clean:
	rm -f $(PROG)
