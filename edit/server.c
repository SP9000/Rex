#include <SDL2/SDL.h>
#include <SDL2/SDL_net.h>
#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>
#include "commands.h"
#include "draw.h"
#include "edit_enemy.h"

#define PORT 1234
#define MAX_SOCKETS 2  // server + 1 client
#define TRUE 1
#define FALSE 0

#define NUM_ENEMIES 16  // max # of enemy-edit windows

#define ASPECT_RATIO 1.5  // width of pixels relative to height

static SDL_Texture *picTex;
static SDL_Window *win;
static SDL_Renderer *renderer;
static SDL_Surface *screenSurf;

static struct EnemyEdit enemies[NUM_ENEMIES];

void redraw() {
	SDL_SetRenderTarget(renderer, NULL);
	SDL_SetRenderDrawColor(renderer, 0xff, 0xff, 0xff, 0xff);
	SDL_RenderClear(renderer);
	SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0xff);
	if (picTex != NULL) SDL_RenderCopy(renderer, picTex, NULL, NULL);
	SDL_RenderPresent(renderer);
}

void runcmd(char *cmd) {
	char *argv[32];
	int argc = 1;
	char *arg = strtok(cmd, " ");

	if (arg == NULL) return;
	argv[0] = arg;
	while ((arg = strtok(NULL, " ")) != NULL) {
		argv[argc++] = arg;
	}
	if (strncmp(argv[0], "setpic", sizeof("setpic")) == 0) {
		picTex = setpic(renderer, argv[1]);
	} else if (strncmp(argv[0], "addenemy", sizeof("addenemy")) == 0) {
		int i;
		if (argc != 2) {
			return;
		}
		for (i = 0; i < NUM_ENEMIES; ++i) {
			if (!enemies[i].active) {
				NewEnemyEdit(&enemies[i], argv[1]);
				break;
			}
		}
	} else {
		printf("?\n");
	}
}

int init() {
	if (SDL_Init(SDL_INIT_EVERYTHING) < 0) {
		printf("SDL_Error: %s\n", SDL_GetError());
		return -1;
	}
	if ((SDLNet_Init) < 0) {
		printf("SDLNet_Init error: %s\n", SDL_GetError());
		return -2;
	}

	win = SDL_CreateWindow("Edit", SDL_WINDOWPOS_UNDEFINED,
			       SDL_WINDOWPOS_UNDEFINED, 640, 480,
			       SDL_WINDOW_RESIZABLE);
	if (win == NULL) {
		printf("SDL_Error: %s\n", SDL_GetError());
		return -2;
	}
	renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);
	if (renderer == NULL) {
		printf("SDL Error: %s\n", SDL_GetError());
		return -3;
	}
	if (SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE) != 0) {
		printf("SDL Error: %s\n", SDL_GetError());
		return -4;
	}
	SDL_RenderSetLogicalSize(renderer, 96 * 1.5, 112);

	return 0;
}

void run(TCPsocket serversock) {
	TCPsocket sock = NULL;
	char recvBuff[1024];
	int quit = FALSE;
	SDLNet_SocketSet sockset = SDLNet_AllocSocketSet(MAX_SOCKETS);
	SDLNet_TCP_AddSocket(sockset, serversock);

	redraw();
	while (!quit) {
		SDL_Event evt;

		/* handle SDL events for all active windows */
		while (SDL_PollEvent(&evt) != 0) {
			int i;
			if (evt.type == SDL_QUIT) {
				quit = TRUE;
				break;
			}
			if (evt.type == SDL_WINDOWEVENT &&
			    evt.window.windowID == SDL_GetWindowID(win)) {
				if (evt.window.event == SDL_WINDOWEVENT_CLOSE) {
					SDL_DestroyWindow(win);
					quit = TRUE;
				}
			}
			for (i = 0; i < NUM_ENEMIES; ++i) {
				EnemyEditUpdate(&enemies[i], &evt);
			}
		}
		redraw();

		/* check socket & recv commands */
		if (sock == NULL) {
			sock = SDLNet_TCP_Accept(serversock);
			if (sock != NULL) {
				printf("client connected\n");
				SDLNet_TCP_AddSocket(sockset, sock);
			}
			continue;
		}
		if (SDLNet_CheckSockets(sockset, 0) == -1) {
			printf("net error: %s\n", SDLNet_GetError());
		}
		if (!SDLNet_SocketReady(sock)) continue;
		if (SDLNet_TCP_Recv(sock, recvBuff, sizeof(recvBuff)) <= 0) {
			printf("client disconnected\n");
			SDLNet_TCP_Close(sock);
			SDLNet_TCP_DelSocket(sockset, sock);
			sock = NULL;
			continue;
		}
		puts(recvBuff);
		runcmd(recvBuff);
	}

	if (sock != NULL) SDLNet_TCP_Close(sock);
}

void initconn(TCPsocket *socket) {
	IPaddress ip;

	if (SDLNet_ResolveHost(&ip, NULL, PORT) == -1) {
		fprintf(stderr, "ER: SDLNet_ResolveHost: %s\n",
			SDLNet_GetError());
		exit(-1);
	}
	*socket = SDLNet_TCP_Open(&ip);
	if (*socket == NULL) {
		printf("SDLNet_TCP_Open: %s\n", SDLNet_GetError());
		exit(-1);
	}
}

void quit() {
	if (win != NULL) SDL_DestroyWindow(win);
	SDL_Quit();
}

int main(int argc, char *argv[]) {
	TCPsocket sock = NULL;

	if (init() != 0) {
		return -1;
	}
	DrawInit();
	initconn(&sock);
	run(sock);
	SDLNet_TCP_Close(sock);

	quit();
	return 0;
}
