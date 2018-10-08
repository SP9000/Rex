#include <SDL2/SDL.h>
#include "util.h"

SDL_Texture *setpic(SDL_Renderer *r, char *filename) {
	static char pic[112 * (96 / 8)];
	int x, y;
	void *optimized;
	SDL_Surface *surf;
	SDL_Texture *tex;

	FILE *file = fopen(filename, "rb");
	if (file == NULL) {
		printf("failed to open file %s\n", filename);
		return NULL;
	}

	printf("setpic: %s\n", filename);
	fseek(file, 0x0f + 2, SEEK_CUR);
	for (x = 0; x < 96 / 8; ++x) {
		for (y = 0; y < 112; ++y) {
			// read column
			fread(pic + (y * (96 / 8)) + x, 1, 1, file);
		}
		fseek(file, 192 - 112, SEEK_CUR);
	}
	fclose(file);

	optimized = malloc(3 * 112 * 96);
	if (optimized == NULL) {
		printf("failed to optimize image\n");
		return NULL;
	}
	convert(pic, optimized, 112 * 96 / 8);
	surf = SDL_CreateRGBSurfaceFrom(optimized, 96, 112, 24, 96 * 3, 0, 0, 0,
					0);
	if (surf == NULL) {
		printf("failed to create pic surface %s\n", SDL_GetError());
		return NULL;
	}
	free(optimized);
	printf("loaded pic\n");

	tex = SDL_CreateTextureFromSurface(r, surf);
	if (tex == NULL) {
		printf("SDL_Error: %s\n", SDL_GetError());
	}
	SDL_FreeSurface(surf);
	return tex;
}
