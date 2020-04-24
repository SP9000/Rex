import os
import tempfile
import subprocess
from PIL import Image

def makeIncludeFile(filename):
    infile = open(filename, "r")
    out = open("engine.inc", "w")
    for line in infile.readlines():
        # input looks like: al 0022A3 .label
        # output: label = $22A3
        parts = line.split()
        out.write(parts[2][1:] + " = $" + parts[1][2:] + "\n")
    infile.close()
    out.close()
    return os.path.basename(out.name)

idsByName = {}

def makeItemFile(items):
    f = open("items.inc", 'w')
    for i, thing in enumerate(items):
        handle = i + 1
        f.write('ITEM_' + thing.name + " = " + str(handle) + '\n')
        idsByName[thing.name] = handle
    f.close()

#######################################
# Things
class Thing:
    def __init__(self):
        self.name = ""        # the name of the thing
        self.description = "" # the description of the thing
        self.pic = ""         # the filename of the thing's picture file
        self.handler = ""     # the filename of the handler binary
        self.setup = ""     # the filename of the setup binary
        self.height = 0       # height of the picture (# rows)
        self.width = 0        # width of the picture in chars (# of columns / 8)
        self.x = 0
        self.y = 0

    def writeSpriteData(self, out):
        outbuff = bytearray()
        outbuff.append(self.x)
        outbuff.append(self.y)
        out.write(bytes(outbuff))
        return len(outbuff)

    def writePic(self, out):
        img = Image.open(self.pic)
        pixels = img.load()
        width, height = img.size
        pixmap = bytearray()
        alphamap = bytearray()
        outbuff = bytearray()
        outbuff.append(0x00)    # flags (unused)
        outbuff.append(0x00)    # 2 bytes for ptr to gfx
        outbuff.append(0x00)
        outbuff.append(int(width/8))
        outbuff.append(height)
        out.write(outbuff)

        backup = bytearray() # TODO: should not write this
        for x in range(int(width/8)):
            for y in range(height):
                alpha = 0
                pix = 0
                for px in range(8):
                    color = (0, 1)[pixels[x*8+px, y][0] == 0] # 1 if black
                    a = 1
                    # alpha is always 1 for unset pixels
                    if color == 0:
                        a = (0, 1)[pixels[x*8+px, y][3] == 0] # 1 if not-trans
                    pix = pix | (color << (7-px))
                    alpha = alpha | (a << (7-px))
                alphamap.append(alpha)
                pixmap.append(pix)
                backup.append(0x00)
        for y in range(height):
            backup.append(0x00)

        out.write(bytes(pixmap))
        out.write(bytes(alphamap))
        out.write(bytes(backup))
        return 5+len(pixmap)+len(alphamap)+len(backup) # the +5 is for sprite data

    def writeIncfile(self, nameAddr, descAddr, spriteAddr):
        # write an include file for the handler to use
        strs = [
                "name = $" + hex(nameAddr)[2:] + '\n',
                "description = $" + hex(descAddr)[2:] + '\n',
                "sprite = $" + hex(spriteAddr)[2:] + '\n'
        ]
        out = open("__handler.inc", "w")
        out.writelines(strs)
        return "__handler.inc"

    def writeAsm(self, sourceFile, out, addr, incfile):
        if sourceFile == "":
            length = bytearray()
            length.append(0x00)
            length.append(0x00)
            out.write(length)
            return len(length)

        if not os.path.isfile(sourceFile):
            # treat string as assembly code
            f = open("__handler.asm",'w+t')
            f.write(sourceFile)
            sourceFile = f.name
            f.close()
        if sourceFile[-4:] == ".asm":
            # assemble the handler and write the binary with cl65
            # cl65 --startaddr 0xaaaa -O -t none __handler.asm
            # the +2 is because the length will prefix the handler code
            proc = subprocess.call('cl65 --start-addr ' + hex(addr+0x6000+2) + ' -t none -o __out.bin ' + sourceFile,
                    shell = True)
            try:
                outfile = open("__out.bin", "rb")
            except OSError:
                print("Could not open/read file __out.bin:")
                return 0
        else:
            # treat input file as output file (already assembled)
            outfile = open(sourceFile, "rb")

        handler = bytearray(outfile.read())
        if not handler:
            print('failed to read output file')
            return 0
        outfile.close()
        # write length of the handler binary (little endian)
        length = bytearray()
        l = len(handler).to_bytes(2, byteorder='little')
        length.append(l[0])
        length.append(l[1])
        out.write(length)
        out.write(handler)
        return len(handler)+len(length)

    def write(self, out, addr):
        self.id = idsByName[self.name]

        strings = bytearray()
        nameAddr = addr
        strings.extend(map(ord, self.name))
        strings.append(0x00)
        descAddr = addr + len(strings)
        strings.extend(map(ord, self.description))
        strings.append(0x00)
        out.write(strings)

        addr += len(strings)
        spriteAddr = addr

        incfile = self.writeIncfile(nameAddr, descAddr, spriteAddr)
        addr += self.writeSpriteData(out)
        addr += self.writePic(out)
        addr += self.writeAsm(self.setup, out, addr, incfile)
        addr += self.writeAsm(self.handler, out, addr, incfile)
        os.remove(incfile)

        return addr

class Rock(Thing):
    def __init__(self):
        super().__init__()
        self.name = "rock"
        self.description = "A rough piece of sediment"
        self.handler = "rock.bin"

class Gardener(Thing):
    def __init__(self):
        super().__init__()
        self.x = 65
        self.y = 50
        self.name = "gardener"
        self.pic = "sprites/gardener.png"
        self.description = "The menacing man snarls at you from the end of the gazebo"
        self.handler = "things/gardener_use.asm"

class Bone(Thing):
    def __init__(self):
        super().__init__()
        self.x = 65
        self.y = 95
        self.name = "bone"
        self.pic = "sprites/bone.png"
        self.description = "The bone has been licked clean"
        self.setup = ""
        self.handler = "things/rock.asm"

#######################################
# Rooms
class Room:
    def __init__(self):
        self.pic = ""
        self.exportAs = ""
        self.name = ""
        self.description = ""
        self.exits = {}
        self.things = []
        self.handler = ""

    def writePic(self, out):
        outbuff = bytearray()

        # write picture data (12x112 bytes)
        if self.pic.endswith(".prg"):
            img = Image.new(('RGB'), (96, 112), color = 'white')
            pixels = img.load()
            with open(self.pic, "rb") as f:
                f.read(2)
                for x in range(0, int(96/8)):
                    y = 0
                    for b in f.read(112):
                        outbuff.append(b)
                        for i in range(0,8):
                            p = ((255,255,255), (0,0,0))[(b & (1 << (7-i))) != 0]
                            pixels[8*x + i, y] = p
                        y = y + 1
                    f.read(192-112)
            # export a PNG of the file
            img.save(self.pic[:-4] + ".png")

        else:
            img = Image.open(self.pic)
            pixels = img.load()
            width, height = img.size
            for x in range(int(width/8)):
                for y in range(height):
                    pix = 0
                    for px in range(8):
                        color = (0, 1)[pixels[x*8+px, y][0] == 0] # 1 if black
                        pix = pix | (color << (7-px))
                    outbuff.append(pix)
        out.write(outbuff)
        return len(outbuff)   # size of image

    def writeExit(self, out, exitFile):
        # write length-prefixed file of exit
        outbuff = bytearray()
        if exitFile is None:
            outbuff.append(0x00)
        else:
            length = len(exitFile)
            outbuff.append(length)
            outbuff.extend(map(ord, exitFile))
        out.write(outbuff)
        return len(outbuff)

    def writeHandler(self, out):
        if self.handler == "":
            outbuff = bytearray()
            outbuff.append(0x00)
            outbuff.append(0x00)
            out.write(outbuff)
            return
        with open(self.handler, "rb") as binfile:
            handler = bytearray(binfile.read())
            out.write(handler)

    def write(self):
        # export the picture
        out = open(self.exportAs, "wb")

        loadAddr = bytearray()
        loadAddr.append(0x00)
        loadAddr.append(0x60)
        out.write(loadAddr)
        addr = self.writePic(out)

        # write the exits
        addr += self.writeExit(out, self.exits.get("N"))
        addr += self.writeExit(out, self.exits.get("S"))
        addr += self.writeExit(out, self.exits.get("E"))
        addr += self.writeExit(out, self.exits.get("W"))
        addr += self.writeExit(out, self.exits.get("D"))
        addr += self.writeExit(out, self.exits.get("U"))
        
        # write the name & description (0-terminated)
        strings = bytearray()
        strings.extend(map(ord, self.name))
        strings.append(0x00)
        strings.extend(map(ord, self.description))
        strings.append(0x00)
        out.write(strings)
        addr += len(strings)

        # write the number of things
        numThings = bytearray()
        numThings.append(len(self.things))
        out.write(numThings)
        addr += len(numThings)

        # export the things
        for t in self.things:
            addr += t.write(out, addr)

        terminator = bytearray()
        terminator.append(0x00)
        out.write(terminator)
        addr += len(terminator)

        self.writeHandler(out)
        print("exported {}".format(self.exportAs))

class Tunnel(Room):
    def __init__(self):
        super().__init__()
        self.pic = "rooms/tunnel.png"
        self.exportAs = "tunnel.prg"
        self.name = "tunnel"
        self.description = "a long wide tunnel stretches out ahead"
        self.exits = {}

class Garden(Room):
    def __init__(self):
        super().__init__()
        self.pic = "exports/garden.png"
        self.exportAs = "garden.prg"
        self.name = "garden"
        self.description = "a chilly lawn stretches before you. an old gazebo to the north creaks in the wind and the silhouette of an ancient cemetery in the east."
        self.exits = {
                "N": "GAZEBO.PRG",
                "E": "CEMETERY.PRG"
        }

class Gazebo(Room):
    def __init__(self):
        super().__init__()
        self.pic = "exports/gazebo.png"
        self.exportAs = "gazebo.prg"
        self.name = "gazebo"
        self.description = "the gazebo is in relatively good shape. it seems newly built compared to the other worn remains that dot the garden."
        self.exits = {"S": "GARDEN.PRG"}
        self.things = [
            #Bone(), 
            Gardener(),
        ]

class Cemetery(Room):
    def __init__(self):
        super().__init__()
        self.pic = "exports/cemetery.png"
        self.exportAs = "cemetery.prg"
        self.name = "cemetery"
        self.description = "the still cemetery air feels cold. you suppose that this was some royal family based on the small number of graves, but their inscriptions are illegible."
        self.exits = {"W": "GARDEN.PRG"}

rooms = [Garden(),
        Cemetery(),
        Gazebo(),
        Tunnel()]


makeItemFile([Bone(), Rock(), Gardener()])
makeIncludeFile("labels.txt")
for r in rooms:
    r.write()
