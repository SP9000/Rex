#include "util.h"

const uint32_t RMASK = 0xff0000;
const uint32_t GMASK = 0x00ff00;
const uint32_t BMASK = 0x0000ff;

void convert(uint8_t *srcpixmap, uint8_t *dstpixmap, int size) {
	int i;
	for (i = 0; i < size; ++i) {
		uint8_t mask;
		for (mask = 0x80; mask != 0; mask >>= 1) {
			uint8_t c0 = (WHITE & RMASK) >> 16;
			uint8_t c1 = (WHITE & GMASK) >> 8;
			uint8_t c2 = WHITE & BMASK;
			if (srcpixmap[i] & mask) {
				c0 = (BLACK & RMASK) >> 16;
				c1 = (BLACK & GMASK) >> 8;
				c2 = BLACK & BMASK;
			}
			*dstpixmap++ = c0;
			*dstpixmap++ = c1;
			*dstpixmap++ = c2;
		}
	}
}

SDL_Surface *loadimg(char *filename, int w, int h, int detectBounds) {
	uint8_t *optimized;
	int x, y;
	SDL_Surface *surf;

	uint8_t *pic = malloc(h * (w / 8));
	memset(pic, 0x00, h * (w / 8));
	FILE *file = fopen(filename, "r");
	if (file == NULL) {
		printf("failed to open file %s\n", filename);
		return NULL;
	}

	rewind(file);
	fseek(file, 0x0f + 2, SEEK_CUR);
	for (x = 0; x < w / 8; ++x) {
		for (y = 0; y < h; ++y) {
			// read column
			fread(pic + (y * (w / 8)) + x, 1, 1, file);
		}
		fseek(file, 192 - h, SEEK_CUR);
	}

	if (detectBounds) {
		// find first non-empty row
		for (y = h - 1; y > 0; --y) {
			for (x = 0; x < w / 8; ++x) {
				if (pic[y * (w / 8) + x] != 0) {
					h = y;
					y = 0;
					break;
				}
			}
		}
		// find first non-empty col
		for (x = (w - 1) / 8; x > 0; --x) {
			for (y = 0; y < h; ++y) {
				if (pic[y * (w / 8) + x] != 0) {
					w = x * 8;
					x = 0;
					break;
				}
			}
		}
		fclose(file);
		free(pic);
		return loadimg(filename, w, h, 0);
	}

	optimized = malloc(3 * w * h);
	convert(pic, optimized, h * w / 8);
	surf = SDL_CreateRGBSurfaceFrom((void *)optimized, w, h, 24, w * 3,
					RMASK, GMASK, BMASK, 0);
	if (surf == NULL) {
		printf("failed to create pic surface %s\n", SDL_GetError());
		return NULL;
	}
	fclose(file);
	return surf;
}
