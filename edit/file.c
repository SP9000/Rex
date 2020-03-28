#include "file.h"
#include <string.h>

const char *thingsPrefix = "things/";
const char *spritesPrefix = "sprites/";

static struct Sprite globalSprites[MAX_SPRITES];
static struct Thing globalThings[MAX_THINGS];

void savesprites() {
	int i;
	FILE *file;
	struct json_object *jobj = json_object_new_object();
	struct json_object *sprites = json_object_new_array();
	for (i = 0; i < MAX_THINGS; ++i) {
		if (strlen(globalSprites[i].imgfile) > 0) {
			json_object *sprite = json_object_new_object();
			struct json_object *img =
			    json_object_new_string(globalSprites[i].imgfile);
			struct json_object *w =
			    json_object_new_int(globalSprites[i].w);
			struct json_object *h =
			    json_object_new_int(globalSprites[i].h);
			json_object_object_add(sprite, "w", w);
			json_object_object_add(sprite, "h", h);
			json_object_object_add(sprite, "img", img);
			json_object_array_add(sprites, sprite);
		}
	}
	json_object_object_add(jobj, "sprites", sprites);
	file = fopen("sprites.json", "w");
	if (file) {
		const char *s = json_object_to_json_string_ext(
		    jobj, JSON_C_TO_STRING_PRETTY);
		fprintf(file, "%s", s);
		fclose(file);
	} else {
		printf("could not open file %s for writing\n", "sprites.json");
	}
}

void savethings() {
	int i;
	FILE *file;
	struct json_object *jobj = json_object_new_object();
	struct json_object *things = json_object_new_array();
	for (i = 0; i < MAX_THINGS; ++i) {
		if (strlen(globalThings[i].name) > 0) {
			json_object *thing = json_object_new_object();
			struct json_object *name =
			    json_object_new_string(globalThings[i].name);
			struct json_object *desc =
			    json_object_new_string(globalThings[i].desc);
			struct json_object *callback =
			    json_object_new_string(globalThings[i].callback);
			struct json_object *id = json_object_new_int(i);
			json_object_object_add(thing, "id", id);
			json_object_object_add(thing, "name", name);
			json_object_object_add(thing, "desc", desc);
			json_object_object_add(thing, "callback", callback);
			json_object_array_add(things, thing);
		}
	}
	json_object_object_add(jobj, "things", things);
	file = fopen("things.json", "w");
	if (file) {
		const char *s = json_object_to_json_string_ext(
		    jobj, JSON_C_TO_STRING_PRETTY);
		fprintf(file, "%s", s);
		fclose(file);
	} else {
		printf("could not open file %s for writing\n", "things.json");
	}
}

void saveroom(char *filename, struct Room *room) {
	int i;
	FILE *file;
	struct json_object *jobj = json_object_new_object();
	struct json_object *things = json_object_new_array();
	for (i = 0; i < room->numThings; ++i) {
		json_object *thing = json_object_new_object();
		struct json_object *id =
		    json_object_new_int(room->things[i].id);
		struct json_object *x = json_object_new_int(room->things[i].x);
		struct json_object *y = json_object_new_int(room->things[i].y);
		json_object_object_add(thing, "x", x);
		json_object_object_add(thing, "y", y);
		json_object_object_add(thing, "id", id);
		json_object_array_add(things, thing);
	}

	json_object_object_add(jobj, "things", things);
	file = fopen(filename, "w");
	if (file) {
		const char *s = json_object_to_json_string_ext(
		    jobj, JSON_C_TO_STRING_PRETTY);
		fprintf(file, "%s", s);
		fclose(file);
	} else {
		printf("could not open file %s for writing\n", filename);
	}

	/* write thing index */
	jobj = json_object_new_object();
	file = fopen("thing_index.json", "w");
	if (file) {
		for (i = 0; i < MAX_THINGS; ++i) {
			if (strlen(globalThings[i].name) > 0) {
				struct json_object *id = json_object_new_int(i);
				json_object_object_add(
				    jobj, globalThings[i].name, id);
			}
		}
	}

	/* write sprite index */
	jobj = json_object_new_object();
	file = fopen("sprite_index.json", "w");
	if (file) {
		for (i = 0; i < MAX_SPRITES; ++i) {
			if (strlen(globalSprites[i].imgfile) > 0) {
				struct json_object *id = json_object_new_int(i);
				json_object_object_add(
				    jobj, globalSprites[i].imgfile, id);
			}
		}
	}
}

void savespritesbin() {
	int i, x, y;
	FILE *file, *out;
	out = fopen("sprites.bin", "w");
	for (i = 0; i < MAX_SPRITES; ++i) {
		uint8_t w, h;
		if (strlen(globalSprites[i].imgfile) == 0) break;

		w = globalSprites[i].w;
		h = globalSprites[i].h;
		file = fopen(globalSprites[i].imgfile, "r");
		fseek(file, 0x0f + 2, SEEK_CUR);
		fwrite(&w, 1, w / 8, out);
		fwrite(&h, 1, h, out);
		for (x = 0; x < w / 8; ++x) {
			char col[112];
			for (y = 0; y < h; ++y) {
				/* read column */
				fread(col + y, 1, 1, file);
			}
			fwrite(col, 1, h, out);
			fseek(file, 192 - h, SEEK_CUR);
		}
		fclose(file);
	}
	fclose(out);
}

void asmcallbacks() {
	int i, j;
	const char *cmd = "ca65 -o ___tmpfile --start-addr";
	const long org = 0x2000;
	FILE *out = fopen("things.bin", "w");
	for (i = 0;; ++i) {
		char asmCmd[128];
		char addr[128];
		FILE *file;
		if (strlen(globalThings[i].name) == 0) break;

		/* assemble callback */
		asmCmd[0] = '\0';
		strcpy(asmCmd, cmd);
		sprintf(addr, "%x", (unsigned)(org + ftell(out)));
		strcat(asmCmd, addr);

		/* write callback code */
		file = fopen("__tmpfile", "r");
		if (file == NULL) {
			fprintf(stderr, "failed to open callback binary\n");
			return;
		}
		char c = fgetc(file);
		for (j = 0; c != EOF; ++j) {
			globalThings[i].callback[j] = c;
			c = fgetc(file);
		}
		fclose(file);
	}
	remove("__tmpfile");
}

void savesthingsbin() {
	int i;
	FILE *out = fopen("things.bin", "w");
	if (out == NULL) {
		fprintf(stderr, "failed to open file things.bin for writing\n");
		return;
	}
	for (i = 0; i < MAX_THINGS; ++i) {
		int spriteLo = globalThings[i].sprite & 0xff;
		int spriteHi = globalThings[i].sprite & 0xff00 >> 8;
		if (strlen(globalThings[i].name) == 0) break;

		fwrite(&spriteLo, 1, 1, out);
		fwrite(&spriteHi, 1, 1, out);
		fwrite(globalThings[i].name, 1,
		       strlen(globalThings[i].name) + 1, out);
		fwrite(globalThings[i].desc, 1,
		       strlen(globalThings[i].desc) + 1, out);
		fwrite(globalThings[i].callback, 1,
		       strlen(globalThings[i].callback) + 1, out);
	}
	fclose(out);
}

void savebin(char *filename, struct Room *r) {
	int i, x, y;
	FILE *file, *out;

	/* write the image graphic for the room */
	out = fopen(filename, "w");
	file = fopen(r->imgfile, "r");
	fseek(file, 0x0f + 2, SEEK_CUR);
	for (x = 0; x < 96 / 8; ++x) {
		char col[112];
		for (y = 0; y < 112; ++y) {
			/* read column */
			fread(col + y, 1, 1, file);
		}
		fwrite(col, 1, 112, out);
		fseek(file, 192 - 112, SEEK_CUR);
	}
	/* write name */
	fwrite(r->name, 1, strlen(r->name) + 1, out);
	/* write description */
	fwrite(r->desc, 1, strlen(r->desc) + 1, out);

	/* write the things for the room */
	fwrite(&r->numThings, 1, 1, out);
	for (i = 0; i < r->numThings; ++i) {
		int idLo = r->things[i].id & 0xff;
		int idHi = r->things[i].id & 0xff00 >> 8;
		int x = r->things[i].x;
		int y = r->things[i].y;

		/* write "thing" ID */
		fwrite(&idLo, 1, 1, out);
		fwrite(&idHi, 1, 1, out);
		fwrite(&x, 1, 1, out);
		fwrite(&y, 1, 1, out);
	}
	fclose(out);
}

void loadroom(char *filename, struct Room *r) {
	FILE *f = fopen(filename, "r");
	struct json_object *jobj, *things;
	char *buffer;

	if (f) {
		long len;
		fseek(f, 0, SEEK_END);
		len = ftell(f);
		fseek(f, 0, SEEK_SET);
		buffer = malloc(len);
		if (buffer) {
			fread(buffer, 1, len, f);
		}
		fclose(f);
	}
	jobj = json_tokener_parse(buffer);

	json_object_object_get_ex(jobj, "things", &things);
	r->numThings = 0;
	json_object_object_foreach(things, key, val) {
		json_object *name, *id, *x, *y, *w, *h;
		json_object_object_get_ex(val, "x", &x);
		json_object_object_get_ex(val, "y", &y);
		json_object_object_get_ex(val, "w", &w);
		json_object_object_get_ex(val, "h", &h);
		json_object_object_get_ex(val, "name", &name);
		json_object_object_get_ex(val, "id", &id);
		r->things[r->numThings].id = json_object_get_int(id);
		r->things[r->numThings].x = json_object_get_int(x);
		r->things[r->numThings].y = json_object_get_int(y);
	}
}

struct Sprite *getsprite(uint16_t thing_id) {
	return &globalSprites[thing_id];
}
struct Thing *getthing(uint16_t roomthing_id) {
	return &globalThings[roomthing_id];
}

int getThingID() {
	int i;
	for (i = 0; i < MAX_THINGS; ++i) {
		if (strlen(globalThings[i].name) > 0) break;
	}
	return i;
}

int getSpriteID() {
	int i;
	for (i = 0; i < MAX_THINGS; ++i) {
		if (strlen(globalSprites[i].imgfile) > 0) break;
	}
	return i;
}

void NewSpriteFile(char *imgfile, int w, int h, char *filename) {
	struct json_object *jobj = json_object_new_object();
	int id = getSpriteID();
	FILE *file;

	json_object_object_add(jobj, "img", json_object_new_string(imgfile));
	json_object_object_add(jobj, "id", json_object_new_int(w));
	json_object_object_add(jobj, "w", json_object_new_int(w));
	json_object_object_add(jobj, "h", json_object_new_int(h));

	strcpy(globalSprites[id].imgfile, imgfile);
	globalSprites[id].w = w;
	globalSprites[id].h = h;
	globalSprites[id].id = id;

	strcpy(filename, "sprites/");
	strcat(filename, imgfile);
	file = fopen(filename, "w");
	if (file) {
		const char *s = json_object_to_json_string_ext(
		    jobj, JSON_C_TO_STRING_PRETTY);
		fprintf(file, "%s", s);
		fclose(file);
	} else {
		printf("could not open file %s for writing\n", filename);
	}
}

void NewThingFile(char *name, char *filename) {
	struct json_object *jobj = json_object_new_object();
	int id = getThingID();
	FILE *file;

	json_object_object_add(jobj, "name", json_object_new_string(name));
	json_object_object_add(jobj, "desc", json_object_new_string(""));
	json_object_object_add(jobj, "callback", json_object_new_string(""));
	json_object_object_add(jobj, "src", json_object_new_string(""));
	json_object_object_add(jobj, "sprite", json_object_new_string(""));

	strcpy(globalThings[id].name, name);
	strcpy(globalThings[id].desc, "");
	strcpy(globalThings[id].callback, "");
	strcpy(globalThings[id].src, "");
	globalThings[id].sprite = 0;

	strcpy(filename, "things/");
	strcat(filename, name);
	file = fopen(filename, "w");
	if (file) {
		const char *s = json_object_to_json_string_ext(
		    jobj, JSON_C_TO_STRING_PRETTY);
		fprintf(file, "%s", s);
		fclose(file);
	} else {
		printf("could not open file %s for writing\n", filename);
	}
}
