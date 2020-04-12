import sys, os
from PIL import Image

def export(filename, exportname):
    # write picture data (12x112 bytes)
    img = Image.new(('RGB'), (96, 112), color = 'white')
    pixels = img.load()
    with open(filename, "rb") as f:
        f.read(17)
        for x in range(0, int(96/8)):
            y = 0
            for b in f.read(112):
                for i in range(8):
                    p = ((255,255,255), (0,0,0))[(b & (1 << (7-i))) != 0]
                    pixels[8*x + i, y] = p
                y = y + 1
            f.read(192-112)
    # export a PNG of the file
    img.save(exportname)

infile = sys.argv[1]
if os.path.isdir(infile):
    for filename in os.listdir(infile):
        exportName = sys.argv[2] + "/" + filename[:-4]+".png"
        export(infile+"/"+filename, exportName)
else:
    export(infile, sys.argv[2])
