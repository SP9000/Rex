## Building
Rooms are assembled via a Python script (`rooms.py`).
Each room is defined by subclassing `Room` and adding it to the `rooms`
list.

### Rooms
A few variables need to be defined to create the room:
* `pic`: this is the path to the PNG file for the room. This will be exported to a binary format and saved with the room metadata.
* `exportAs`: this is simply used as the path for the intermediate file that is exported before the game file is written.
* `name`: this is the room name. It should be less than 16 characters
* `description`: a string that is displayed the first time the player enters the room
* `exits`: this is a dictionary of directions (the strings `W`, `E`, `N`, `S`, `U`, and `D` to the rooms that they lead to.
Note that the rooms are in PETSCII format, therefore if you've exported a room as `room.prg`, the name in the exits dictionary should be `ROOM.PRG`
* `handler`: not required, but an assembly file may be provided to-be-executed upon entering the room.
* `things`: a list of objects in the room. This should be instances of subclasses of `Thing`.

### Things
A Thing is anything that exists within a room. Like Rooms, they are defined by subclassing a `Thing` class.  The member variables that need to be defined for a Thing are:
`name`: the thing's name (this will be how it is referred to the player as)
`description`: the text displayed when the player "looks" at the thing
`pic`: the path to the PNG file containing the picture data for the thing. This should be black and white with alpha- it will be exported as two 1 bit layers (color and alpha)
`handler`: an assembly file (or assembly code) that will run when the player clicks the object.

### Writing a Thing Handler
Handlers are executed whenever a Thing is clicked. The handler itself will look at the player's action to determine what to do.
A few convienience macros exists for common behaviors. 
* `ontake <func>`: this will run _func_ when the player clicks the Thing with the `take` action.
* `onuse <func>`: this will run _func_ when the player clicks the Thing with the `use` action.
* `asitem`: this single macro will provide the common functionality to treat the thing as an item.

In addition, a few constants are exported and prepended to the assembly file, which may be referred to within the script.
* `name` is the address of the name of the thing.
* `description` is the address of the thing's description
* `sprite` is the address of the sprite data for the thing
* `ID` is the unique identifier for the thing.

### Build Notes
Rooms must be re-exported when a change is made to the engine.  This is because the room/thing handlers reference routines within the engine code.
Any change to the engine will require the handlers to be recompiled to reference the updated addresses.
Changes to the room code, on the other hand, _shouldn't_ require rebuilding the engine, as the start of the room data is linked to a specific place as defined in the `link.config` file.