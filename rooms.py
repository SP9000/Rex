#######################################
# Things
class Thing:
    def __init__(self):
        self.name = ""        # the name of the thing
        self.description = "" # the description of the thing
        self.pic = ""         # the filename of the thing's picture file
        self.handler = ""     # the filename of the handler binary
        self.height = 0       # height of the picture (# rows)
        self.width = 0        # width of the picture in chars (# of columns / 8)
        self.x = 0
        self.y = 0

    def writeSpriteData(out):
        outbuff = bytearray()
        outbuff.append(self.x)
        outbuff.append(self.y)
        outbuff.append(self.width)
        outbuff.append(self.height)
        outbuff.append(0x00)    # flags (unused)
        out.write(bytes(outbuff))

    def writePic(out):
        with open(self.pic, "rb") as f:
            f.read(2)

            outbuff = bytearray()

            # read the pixel data
            for x in range(0, self.width):
                for b in f.read(self.height):
                    outbuff.append(b)
                f.read(192 - self.height)
            # read the alpha channel
            for x in range(0, self.width):
                for b in f.read(self.height):
                    outbuff.append(b)
                f.read(192 - self.height)
            out.write(bytes(outbuff))

    def writeHandler(out):
        with open(self.handler, "rb") as binfile:
            handler = bytearray(binfile.read())
            out.write(handler)

    def write(buf):
        buf.write(self.name)
        buf.write(self.description)
        self.writeSpriteData(out)
        self.writePic(out)
        self.writeHandler(out)

class Rock(Thing):
    def __init__(self):
        super().__init__()
        self.name = "rock"
        self.description = "A rough piece of sediment"
        self.handler = "rock.bin"


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

    def writePic(out):
        # write picture data (12x112 bytes)
        with open(self.pic, "rb") as f:
            f.read(2)

            outbuff = bytearray()
            outbuff.append(0x00) 
            outbuff.append(0x60)
            for x in range(0, 96/8):
                for b in f.read(112):
                    outbuff.append(b)
                f.read(192-112)
            out.write(bytes(outbuff))

    def writeExit(out, exitFile):
        # write length-prefixed file of exit
        if exitFile is None:
            outbuff.append(0x00)
            outbuff.append(0x00)
            return
        length = len(exitFile)
        outbuff.append(length)
        for c in exitFile:
            outbuff.append(c)

    def write(buf):
        # export the picture
        out = open(self.exportAs, "wb")
        handlerBin=bytearray(list(f.read()))
        buf.writePic(out)

        # write the exits
        self.writeExit(out, exits.get("N"))
        self.writeExit(out, exits.get("S"))
        self.writeExit(out, exits.get("E"))
        self.writeExit(out, exits.get("W"))
        self.writeExit(out, exits.get("D"))
        self.writeExit(out, exits.det("U"))
        
        # write the name & description (0-terminated)
        out.write(name)
        out.write(description)

        # export the things
        for t in things:
            t.write(buf)
        print("exported {}".format(self.exportAs))

class Tunnel(Room):
    def __init__(self):
        super().__init__()
        self.pic = "tunnel.prg"
        self.exportAs = "tunnel.seq"
        self.name = "tunnel"
        self.description = "a long wide tunnel stretches out ahead"
        self.exits = {
                "N": "garden.seq"
        }
