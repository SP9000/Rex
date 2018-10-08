#include "draw.h"
#include <SDL2/SDL_ttf.h>

#define FONTNAME "font.ttf"

static TTF_Font* font;

void DrawInit() {
	if (TTF_Init() != 0) {
		printf("failed to init TTF library: %s\n", SDL_GetError());
	}
	font = TTF_OpenFont(FONTNAME, 12);
	if (font == NULL) {
		printf("failed to load font " FONTNAME "\n");
	}
}

void DrawText(SDL_Renderer* r, char* text, int x, int y) {
	SDL_Color White = {255, 255, 255, 255};
	SDL_Surface* surf = TTF_RenderText_Solid(font, text, White);
	SDL_Texture* Message = SDL_CreateTextureFromSurface(r, surf);
	SDL_Rect Message_rect = {.x = x, .y = y, .w = 100, .h = 100};
	SDL_RenderCopy(r, Message, NULL, &Message_rect);
}
