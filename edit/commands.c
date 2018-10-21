#include <SDL2/SDL.h>
#include "util.h"

SDL_Texture *setpic(SDL_Renderer *r, char *filename) {
	SDL_Texture *tex;
	SDL_Surface *surf = loadimg(filename, 96, 112, 0);
	if (surf == NULL) return NULL;

	tex = SDL_CreateTextureFromSurface(r, surf);
	if (tex == NULL) {
		printf("SDL_Error: %s\n", SDL_GetError());
	}
	SDL_FreeSurface(surf);
	return tex;
}
