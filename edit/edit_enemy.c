#include "edit_enemy.h"
#include "draw.h"

struct EnemyEdit *NewEnemyEdit(struct EnemyEdit *ee, char *name) {
	ee->hp = 0;
	ee->weakness = 0;
	memset(ee->desc, 0, sizeof(ee->desc));
	strcpy(ee->name, name);
	ee->win = SDL_CreateWindow(ee->name, SDL_WINDOWPOS_UNDEFINED,
				   SDL_WINDOWPOS_UNDEFINED, 640, 480,
				   SDL_WINDOW_RESIZABLE);
	if (ee->win == NULL) {
		printf("SDL_Error: %s\n", SDL_GetError());
	}
	ee->renderer =
	    SDL_CreateRenderer(ee->win, -1, SDL_RENDERER_ACCELERATED);
	if (ee->renderer == NULL) {
		printf("SDL_Error: %s\n", SDL_GetError());
	}
	ee->active = 1;
	return ee;
}

void EnemyEditUpdate(struct EnemyEdit *ee, SDL_Event *e) {
	if (!ee->active) {
		return;
	}
	if (e->type == SDL_WINDOWEVENT &&
	    e->window.windowID == SDL_GetWindowID(ee->win)) {
		if (e->window.event == SDL_WINDOWEVENT_CLOSE) {
			SDL_DestroyWindow(ee->win);
			ee->active = 0;
			return;
		}
	}
	SDL_SetRenderDrawColor(ee->renderer, 0x00, 0x00, 0x00, 0xff);
	SDL_RenderClear(ee->renderer);
	DrawText(ee->renderer, ee->name, 0, 0);
	SDL_RenderPresent(ee->renderer);
}
