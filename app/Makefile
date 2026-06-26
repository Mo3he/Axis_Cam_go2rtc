PROG = go2rtc
SRCS = supervisor.c
CFLAGS += -Wall -Wextra -O2

all: $(PROG)
	chmod +x go2rtc_run

$(PROG): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f $(PROG)
