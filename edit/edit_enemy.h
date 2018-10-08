#ifndef EDIT_ENEMY_H
#define EDIT_ENEMY_H

#include <SDL2/SDL.h>

struct EnemyEdit {
	SDL_Window *win;
	SDL_Renderer *renderer;
	uint8_t hp;
	uint8_t weakness;  // ID of item that will kill
	char desc[256];
	char name[16];
	int active;
};

struct EnemyEdit *NewEnemyEdit();
void EnemyEditUpdate(struct EnemyEdit *, SDL_Event *);

#endif
