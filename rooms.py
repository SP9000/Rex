from PIL import Image

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
        if self.pic.endswith(".prg"):
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
        else:
            img = Image.open(self.pic)
            pixels = im.load()
            width, height = img.size
            pixmap = bytearray()
            alphamap = bytearray()
            for x in range(0, width/8):
                for y in range(0, height):
                    alpha = 0
                    pix = 0
                    for px in range(0, 8):
                        p = (1, 0) [pixels[x+px, y+py].r = 0] # 1 if black
                        a = (1, 0) [pixels[x+px, y+py].a > 0] # 1 if not-trans
                        pix = pix | (p << (7-px))
                        alpha = alpha | (a << (7-py))
                    alphamap.append(alpha)
                    pixmap.append(pix)
            out.write(bytes(pixmap))
            out.write(bytes(alphamap))

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
        outbuff = bytearray()
        outbuff.append(0x00) 
        outbuff.append(0x60)

        # write picture data (12x112 bytes)
        if self.pic.endswith(".prg"):
            img = Image.new('RGB', 96, 112), color = 'white')
            pixels = img.load()
            with open(self.pic, "rb") as f:
                f.read(2)
                for x in range(0, 96/8):
                    for b in f.read(112):
                        outbuff.append(b)
                        for i in range(0,8):
                            p = (rgb(255,255,255), rgb(0,0,0)) [(b & (i << 7) != 0]
                            pixels[112*x + i] = p
                    f.read(192-112)
            # export a PNG of the file
            img.save(self.pic[:-4])

        else:
            img = Image.open(self.pic)
            pixels = im.load()
            width, height = img.size
            for x in range(0, width/8):
                for y in range(0, height):
                    pix = 0
                    for px in range(0, 8):
                        color = (1, 0) [pixels[x+px, y+py].r = 0] # 1 if black
                        pix = pix | (color << (7-px))
                    outbuff.append(pix)
        out.write(outbuff)

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

    def write():
        # export the picture
        out = open(self.exportAs, "wb")
        handlerBin=bytearray(list(f.read()))
        out.writePic(out)

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
            t.write(out)
        print("exported {}".format(self.exportAs))

class Tunnel(Room):
    def __init__(self):
        super().__init__()
        self.pic = "tunnel.prg"
        self.exportAs = "tunnel.seq"
        self.name = "tunnel"
        self.description = "a long wide tunnel stretches out ahead"
        self.exits = {}

rooms = [Tunnel()]

for r in rooms:
    room.write()
