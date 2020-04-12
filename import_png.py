import sys, os
from PIL import Image

def importFile(filename, exportname, address):
    out = open(exportname, "wb")
    outbuff = bytearray()

    outbuff.append(address % 0x100)
    outbuff.append(int(address / 0x100))

    img = Image.open(filename)
    pixels = img.load()
    width, height = img.size
    for x in range(int(width/8)):
        for y in range(height):
            pix = 0
            for px in range(8):
                color = (1, 0)[pixels[x*8+px, y] == 0] # 1 if black
                pix = pix | (color << (7-px))
            outbuff.append(pix)
    width, height = img.size
    out.write(outbuff)

print("usage: infile outfile <hex address (0x1100)>")
importFile(sys.argv[1], sys.argv[2], int(sys.argv[3], 16))
