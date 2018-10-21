#ifndef EDIT_ENEMY_H
#define EDIT_ENEMY_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_net.h>

struct EnemyEdit {
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

struct EnemyEdit *NewEnemyEdit(struct EnemyEdit *, SDL_Renderer *, char *,
			       char *);
void EnemyEditUpdate(struct EnemyEdit *, SDL_Event *);

#endif
