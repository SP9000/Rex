#ifndef FILE_H
#define FILE_H

#include <json-c/json.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Item {
	uint8_t id;
	char name[32];
	char desc[256];
	char imgfile[64];
};

struct Enemy {
	uint8_t weakness;
	uint8_t id;
	char name[32];
	char desc[256];
	char imgfile[64];
};

struct Door {
	uint8_t key;
	char name[32];
	char desc[256];
	char imgfile[64];
};

/* Room contains the data needed to export room's data. */
struct Room {
	int numEnemies, numItems, numDoors;
	struct Enemy enemies[4];
	struct Item items[16];
	struct Door doors[16];
	char name[32];
	char desc[256];
	char imgfile[64];
};

void saveroom(char *, struct Room *);
void loadroom(char *, struct Room *);

#endif
