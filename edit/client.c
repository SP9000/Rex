#include <arpa/inet.h>
#include <errno.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#define PORT 1234
#define TRUE 1
#define FALSE 0

int run(int sockfd) {
	char recvBuff[1024];
	memset(recvBuff, '0', sizeof(recvBuff));
	{
		char cmdBuff[1024];
		memset(cmdBuff, '\0', sizeof(cmdBuff));
		putchar('>');
		gets(cmdBuff);
		if (strncmp("x", cmdBuff, strlen(cmdBuff)) == 0) {
			printf("bye\n");
			return FALSE;
		}
		write(sockfd, cmdBuff, strlen(cmdBuff) + 1);
	}
	return TRUE;
}

int initconn(int *sockfd, char *addr) {
	struct sockaddr_in serv_addr;

	memset(&serv_addr, '0', sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_port = htons(PORT);

	if (inet_pton(AF_INET, addr, &serv_addr.sin_addr) <= 0) {
		printf("\n inet_pton error occured\n");
		return 1;
	}
	if ((*sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		printf("\n Error : Could not create socket \n");
		return 1;
	}

	if (connect(*sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) <
	    0) {
		printf("\n Error : Connect Failed \n");
		return 1;
	}
	return 0;
}

int main(int argc, char *argv[]) {
	int sockfd;

	if (argc != 2) {
		printf("\n Usage: %s <ip of server> \n", argv[0]);
		return 1;
	}

	if (initconn(&sockfd, argv[1]) != 0) return -1;
	while (run(sockfd))
		;
	close(sockfd);
	return 0;
}
