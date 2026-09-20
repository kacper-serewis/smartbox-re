/* Ensure emulator timeout handling is real, not a no-op workaround. */
#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
int main(void) {
    int fd[2]; assert(socketpair(AF_UNIX, SOCK_STREAM, 0, fd) == 0);
    struct timeval timeout = {0, 50000};
    assert(setsockopt(fd[0], SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) == 0);
    assert(setsockopt(fd[0], SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout)) == 0);
    struct timespec a, b; char byte;
    clock_gettime(CLOCK_MONOTONIC, &a);
    assert(recv(fd[0], &byte, 1, 0) == -1 && (errno == EAGAIN || errno == EWOULDBLOCK));
    clock_gettime(CLOCK_MONOTONIC, &b);
    double elapsed = b.tv_sec - a.tv_sec + (b.tv_nsec - a.tv_nsec) / 1e9;
    assert(elapsed >= 0.04 && elapsed < 5);
    close(fd[0]); close(fd[1]);
    printf("PASS: RV32 time64 socket timeout expired in %.3fs\n", elapsed);
    return 0;
}
