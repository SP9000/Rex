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
#include "file.h"

#define PORT 1234
#define MAX_SOCKETS 128  // server + 1 client
#define TRUE 1
#define FALSE 0

#define NUM_THINGS 16  // max # of enemy-edit windows

#define ASPECT_RATIO 1.5  // width of pixels relative to height

static SDL_Texture *picTex;
static SDL_Window *win;
static SDL_Renderer *renderer;

static struct Room room;
static struct ThingEdit things[NUM_THINGS];

static void help() {
	puts("setpic <image filepath>");
	puts("addthing <name> <image filepath>");
	puts("load <JSON filepath>");
	puts("save <JSON filepath>");
}

void redraw() {
	int i;
	SDL_SetRenderTarget(renderer, NULL);
	SDL_SetRenderDrawColor(renderer, 0xff, 0xff, 0xff, 0xff);
	SDL_RenderClear(renderer);
	if (picTex != NULL) SDL_RenderCopy(renderer, picTex, NULL, NULL);
	for (i = 0; i < NUM_THINGS; ++i) {
		if (things[i].active && things[i].tex != NULL) {
			struct ThingEdit *ee = &things[i];
			int w, h;
			SDL_GetWindowSize(win, &w, &h);
			SDL_Rect dstRect = {
			    .x = ee->x, .y = ee->y, .w = ee->w, .h = ee->h};
			if (SDL_RenderCopy(renderer, ee->tex, NULL, &dstRect) !=
			    0)
				printf("SDL_Error: %s\n", SDL_GetError());
		}
	}
	SDL_RenderPresent(renderer);
}

void addthing(char *name, char *img) {
	int i;
	for (i = 0; i < NUM_THINGS; ++i) {
		if (!things[i].active) {
			NewThingEdit(&things[i], renderer, name, img);
			room.things[room.numThings].id = 0;
			room.numThings++;
			break;
		}
	}
}
void load(char *filename) {
	int i;
	loadroom(filename, &room);

	memset(things, 0, sizeof(things));
	for (i = 0; i < room.numThings; ++i)
		addthing(
		    getthing(room.things[i].id)->name,
		    getsprite(getthing(room.things[i].id)->sprite)->imgfile);
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
	} else if (strncmp(argv[0], "addthing", sizeof("addthing")) == 0) {
		if (argc != 3) {
			printf("addthing <name> <imgfile>\n");
			return;
		}
		addthing(argv[1], argv[2]);
	} else if (strncmp(argv[0], "load", sizeof("load")) == 0) {
		if (argc != 2) {
			printf("load <filename>\n");
			return;
		}
		loadroom(argv[1], &room);
	} else if (strncmp(argv[0], "save", sizeof("save")) == 0) {
		if (argc != 2) {
			printf("save <filename>\n");
			return;
		}
		saveroom(argv[1], &room);
	} else if (strncmp(argv[0], "help", sizeof("help")) == 0) {
		help();
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
	static TCPsocket sockets[MAX_SOCKETS];
	char recvBuff[1024];
	int i;
	int quit = FALSE;
	SDLNet_SocketSet sockset = SDLNet_AllocSocketSet(MAX_SOCKETS);
	SDLNet_TCP_AddSocket(sockset, serversock);

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
			for (i = 0; i < NUM_THINGS; ++i) {
				ThingEditUpdate(&things[i], &evt);
			}
		}
		redraw();

		/* check socket & recv commands */
		TCPsocket newClient = SDLNet_TCP_Accept(serversock);
		if (newClient != NULL) {
			for (i = 0; i < MAX_SOCKETS; ++i) {
				if (sockets[i] == NULL) {
					printf("client connected\n");
					sockets[i] = newClient;
					SDLNet_TCP_AddSocket(sockset,
							     newClient);
					break;
				}
			}
			if (newClient == NULL) {
				printf("max clients already connected");
			}
		}
		if (SDLNet_CheckSockets(sockset, 0) == -1) {
			printf("net error: %s\n", SDLNet_GetError());
		}
		for (i = 0; i < MAX_SOCKETS; ++i) {
			if (sockets[i] == NULL) continue;
			if (!SDLNet_SocketReady(sockets[i])) continue;
			if (SDLNet_TCP_Recv(sockets[i], recvBuff,
					    sizeof(recvBuff)) <= 0) {
				printf("client disconnected\n");
				SDLNet_TCP_Close(sockets[i]);
				SDLNet_TCP_DelSocket(sockset, sockets[i]);
				sockets[i] = NULL;
				continue;
			}
			puts(recvBuff);
			runcmd(recvBuff);
		}
	}
	for (i = 0; i < MAX_SOCKETS; ++i) {
		if (sockets[i] != NULL) SDLNet_TCP_Close(sockets[i]);
	}
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
