#ifndef EDIT_ENEMY_H
#define EDIT_ENEMY_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_net.h>

struct ThingEdit {
	SDL_Texture *tex;
	uint8_t hp;
	uint8_t weakness;  // ID of item that will kill
	char desc[256];
	char name[16];

	int x, y, w, h;

	int active;
	int drag;

	TCPsocket socket;
};

struct ThingEdit *NewThingEdit(struct ThingEdit *, SDL_Renderer *, char *,
			       char *);
void ThingEditUpdate(struct ThingEdit *, SDL_Event *);

#endif
