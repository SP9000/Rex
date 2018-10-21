#ifndef UTIL_H
#define UTIL_H

#include <SDL2/SDL.h>
#include <stdio.h>
#include <stdlib.h>

#define WHITE 0xffffff
#define BLACK 0x000000

void convert(uint8_t *, uint8_t *, int);
SDL_Surface *loadimg(char *, int, int, int);

#endif
