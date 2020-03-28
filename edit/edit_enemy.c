#include <stdio.h>
#include <unistd.h>

#include "draw.h"
#include "edit_enemy.h"
#include "file.h"
#include "server.h"
#include "util.h"

void openfile(char *filename) {
	char *argv[2];
	argv[0] = filename;
	argv[1] = NULL;
	execvp("open", argv);
}

struct ThingEdit *NewThingEdit(struct ThingEdit *ee, SDL_Renderer *r,
			       char *name, char *imgfile) {
	char filename[256];

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

	/* create/open the JSON file to edit the thing */
	NewThingFile(name, filename);
	openfile(filename);

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

int ThingEditContains(struct ThingEdit *ee, int x, int y) {
	return ((x > ee->x) && (x < ee->x + ee->w) && (y > ee->y) &&
		(y < ee->y + ee->h));
}

void ThingEditUpdate(struct ThingEdit *ee, SDL_Event *e) {
	if (e->type == SDL_MOUSEBUTTONDOWN) {
		if (ThingEditContains(ee, e->button.x, e->button.y)) {
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
