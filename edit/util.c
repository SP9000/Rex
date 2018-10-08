#include "util.h"

void convert(char *srcpixmap, char *dstpixmap, int size) {
	int i;
	for (i = 0; i < size; ++i) {
		uint8_t mask;
		for (mask = 0x80; mask != 0; mask >>= 1) {
			uint8_t c0 = (WHITE & 0xff0000) >> 16;
			uint8_t c1 = (WHITE & 0x00ff00) >> 8;
			uint8_t c2 = WHITE & 0x0000ff;
			if (srcpixmap[i] & mask) {
				c0 = (BLACK & 0xff0000) >> 16;
				c1 = (BLACK & 0x00ff00) >> 8;
				c2 = BLACK & 0x0000ff;
			}
			*dstpixmap++ = c0;
			*dstpixmap++ = c1;
			*dstpixmap++ = c2;
		}
	}
}
