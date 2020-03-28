#ifndef FILE_H
#define FILE_H

#include <json-c/json.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SPRITES 1024
#define MAX_THINGS 2048

struct Sprite {
	uint8_t w, h;
	uint16_t id;
	char imgfile[64];
};

/* Thing is any kind of object that is interactable */
struct Thing {
	uint16_t sprite;
	char name[32];
	char desc[256];
	char callback[1024]; /* the assembled callback */
	char src[10000];     /* the unassembled callback */
};

/* RoomThing is a thing that is placed in a room (has position) */
struct RoomThing {
	uint8_t x, y;
	uint16_t id;
};

/* Room contains the data needed to export room's data. */
struct Room {
	int numEnemies, numItems, numDoors;
	uint8_t numThings;
	struct RoomThing things[32];
	char name[32];
	char desc[256];
	char imgfile[64];
};

void saveroom(char *, struct Room *);
void loadroom(char *, struct Room *);

struct Sprite *getsprite(uint16_t thing_id);
struct Thing *getthing(uint16_t roomthing_id);

void NewThingFile(char *name, char *filename);
void NewSpriteFile(char *imgfile, int w, int h, char *filename);

#endif
