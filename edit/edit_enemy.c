#include "edit_enemy.h"
#include "draw.h"
#include "server.h"
#include "util.h"

struct EnemyEdit *NewEnemyEdit(struct EnemyEdit *ee, SDL_Renderer *r,
			       char *name, char *imgfile) {
	IPaddress ip;

	/* 1 means auto-detect the boundaries of the sprite */
	SDL_Surface *surf = loadimg(imgfile, 160, 192, 1);
	if (surf == NULL) {
		printf("Failed to load %s\n", imgfile);
		return NULL;
	}
	ee->w = surf->w;
	ee->h = surf->h;
	ee->tex = SDL_CreateTextureFromSurface(r, surf);
	if (ee->tex == NULL) {
		printf("Failed to create texture from %s\n", imgfile);
		return NULL;
	}
	SDL_FreeSurface(surf);

	/* connect to server */
	if (SDLNet_ResolveHost(&ip, "localhost", PORT) == -1) {
		printf("SDLNet_ResolveHost: %s\n", SDLNet_GetError());
		return NULL;
	}
	ee->socket = SDLNet_TCP_Open(&ip);
	if (ee->socket == NULL) {
		printf("SDLNet_TCP_Open: %s\n", SDLNet_GetError());
		return NULL;
	}

	ee->active = 1;
	ee->hp = 0;
	ee->weakness = 0;
	ee->x = 0;
	ee->y = 0;
	ee->drag = 0;
	memset(ee->desc, 0, sizeof(ee->desc));
	strcpy(ee->name, name);

	return ee;
}

int EnemyEditContains(struct EnemyEdit *ee, int x, int y) {
	return ((x > ee->x) && (x < ee->x + ee->w) && (y > ee->y) &&
		(y < ee->y + ee->h));
}

void EnemyEditUpdate(struct EnemyEdit *ee, SDL_Event *e) {
	if (e->type == SDL_MOUSEBUTTONDOWN) {
		if (EnemyEditContains(ee, e->button.x, e->button.y)) {
			ee->drag = 1;
		}
	}
	if (e->type == SDL_MOUSEMOTION && ee->drag) {
		ee->x = e->motion.x;
		ee->y = e->motion.y;
	}
	if (e->type == SDL_MOUSEBUTTONUP) {
		ee->drag = 0;
	}
}
