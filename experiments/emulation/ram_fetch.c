/* One-shot bounded TCP transfer into a new RAM file; no flash or shell calls. */
#include <arpa/inet.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
int main(int argc, char **argv) {
    if (argc != 5) return 2;
    unsigned long count = strtoul(argv[4], NULL, 10), total = 0;
    int port = atoi(argv[2]);
    if (!count || count > 2*1024*1024 || port < 1024 || port > 65535) return 2;
    struct sockaddr_in addr = {.sin_family=AF_INET, .sin_port=htons(port)};
    if (inet_pton(AF_INET, argv[1], &addr.sin_addr) != 1) return 2;
    alarm(20);
    int sock = socket(AF_INET, SOCK_STREAM, 0), fd = -1, result = 1;
    if (sock < 0 || connect(sock, (void *)&addr, sizeof(addr))) goto done;
    fd = open(argv[3], O_WRONLY|O_CREAT|O_EXCL, 0700);
    if (fd < 0) goto done;
    char buffer[4096];
    while (total < count) {
        size_t remaining = count-total;
        ssize_t n = read(sock, buffer, remaining < sizeof(buffer) ? remaining : sizeof(buffer));
        if (n < 0 && errno == EINTR) continue;
        if (n <= 0) goto done;
        ssize_t offset = 0;
        while (offset < n) {
            ssize_t written = write(fd, buffer+offset, n-offset);
            if (written < 0 && errno == EINTR) continue;
            if (written <= 0) goto done;
            offset += written;
        }
        total += n;
    }
    if (fsync(fd)) goto done;
    result = 0;
done:
    if (fd >= 0) close(fd);
    if (sock >= 0) close(sock);
    if (result) perror("RAM transfer");
    return result;
}
