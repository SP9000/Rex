#include "file.h"

void saveroom(char *filename, struct Room *room) {
	int i;
	FILE *file;
	struct json_object *jobj = json_object_new_object();
	struct json_object *enemies = json_object_new_array();
	struct json_object *doors = json_object_new_array();
	struct json_object *items = json_object_new_array();

	for (i = 0; i < room->numEnemies; ++i) {
		json_object *enemy = json_object_new_object();
		struct json_object *name =
		    json_object_new_string(room->enemies[i].name);
		struct json_object *weakness =
		    json_object_new_int(room->enemies[i].weakness);
		struct json_object *id =
		    json_object_new_int(room->enemies[i].id);
		struct json_object *desc =
		    json_object_new_string(room->enemies[i].desc);
		struct json_object *img =
		    json_object_new_string(room->enemies[i].imgfile);
		json_object_object_add(enemy, "name", name);
		json_object_object_add(enemy, "id", id);
		json_object_object_add(enemy, "weak", weakness);
		json_object_object_add(enemy, "desc", desc);
		json_object_object_add(enemy, "img", img);
		json_object_array_add(enemies, enemy);
	}

	for (i = 0; i < room->numItems; ++i) {
		json_object *item = json_object_new_object();
		struct json_object *name =
		    json_object_new_string(room->items[i].name);
		struct json_object *id = json_object_new_int(room->items[i].id);
		struct json_object *desc =
		    json_object_new_string(room->items[i].desc);
		struct json_object *img =
		    json_object_new_string(room->enemies[i].imgfile);
		json_object_object_add(item, "name", name);
		json_object_object_add(item, "id", id);
		json_object_object_add(item, "desc", desc);
		json_object_object_add(item, "img", img);
		json_object_array_add(enemies, item);
	}

	for (i = 0; i < room->numDoors; ++i) {
		json_object *door = json_object_new_object();
		struct json_object *name =
		    json_object_new_string(room->doors[i].name);
		struct json_object *key =
		    json_object_new_int(room->doors[i].key);
		struct json_object *desc =
		    json_object_new_string(room->doors[i].desc);
		struct json_object *img =
		    json_object_new_string(room->enemies[i].imgfile);
		json_object_object_add(door, "name", name);
		json_object_object_add(door, "id", key);
		json_object_object_add(door, "desc", desc);
		json_object_object_add(door, "img", img);
		json_object_array_add(enemies, door);
	}
	json_object_object_add(jobj, "enemies", enemies);
	json_object_object_add(jobj, "doors", doors);
	json_object_object_add(jobj, "items", items);

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

void loadroom(char *filename, struct Room *r) {
	FILE *f = fopen(filename, "r");
	struct json_object *jobj, *enemies, *doors, *items;
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

	json_object_object_get_ex(jobj, "enemies", &enemies);
	json_object_object_get_ex(jobj, "doors", &enemies);
	json_object_object_get_ex(jobj, "items", &enemies);

	r->numDoors = 0;
	r->numItems = 0;
	r->numEnemies = 0;

	json_object_object_foreach(enemies, key, val) {
		json_object *weakness, *name, *id, *desc;
		json_object_object_get_ex(val, "weak", &weakness);
		json_object_object_get_ex(val, "desc", &desc);
		json_object_object_get_ex(val, "name", &name);
		json_object_object_get_ex(val, "id", &id);
		strcpy(r->enemies[r->numEnemies].desc,
		       json_object_get_string(desc));
		strcpy(r->enemies[r->numEnemies].name,
		       json_object_get_string(name));
		r->enemies[r->numEnemies].id = json_object_get_int(id);
		r->enemies[r->numEnemies].weakness =
		    json_object_get_int(weakness);
	}
	json_object_object_foreach(doors, dkey, dval) {
		json_object *name, *key, *desc;
		json_object_object_get_ex(dval, "desc", &desc);
		json_object_object_get_ex(dval, "name", &name);
		json_object_object_get_ex(dval, "key", &key);
		strcpy(r->enemies[r->numDoors].desc,
		       json_object_get_string(desc));
		strcpy(r->enemies[r->numDoors].name,
		       json_object_get_string(name));
		r->doors[r->numDoors].key = json_object_get_int(key);
	}
	json_object_object_foreach(items, ikey, ival) {
		json_object *name, *id, *desc;
		json_object_object_get_ex(ival, "desc", &desc);
		json_object_object_get_ex(ival, "name", &name);
		json_object_object_get_ex(ival, "id", &id);
		strcpy(r->items[r->numItems].desc,
		       json_object_get_string(desc));
		strcpy(r->items[r->numItems].name,
		       json_object_get_string(name));
		r->items[r->numItems].id = json_object_get_int(id);
	}
}
