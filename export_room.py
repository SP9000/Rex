import sys
import rooms.py

def export(filename, exportname):
    out = open(exportname, "wb")
    with open(filename, "rb") as f:
        f.read(2)

        outbuff = bytearray()
        outbuff.append(0x00) 
        outbuff.append(0x60)
        for x in range(0, 96/8):
            for b in f.read(112):
                outbuff.append(b)
            f.read(192-112)
        out.write(bytes(outbuff))
        print("exported {} as {} ({} bytes)".format(filename, exportname, len(outbuff)))

if len(sys.argv) < 3:
    print("usage: {} <input-filename> <output-filename>".format(sys.argv[0]))
else:
    desc = input("Enter room description:\n")

    print("Exits:\n")
    exits = {}
    
    # read the IDs of the rooms from rooms.py
    exits["n"] = globals()[input("North: ")]
    exits["s"] = globals()[input("South: ")]
    exits["w"] = globals()[input("West: ")]
    exits["e"] = globals()[input("East: ")]
    exits["u"] = globals()[input("Up: ")]
    exits["d"] = globals()[input("Down: ")]

    export(sys.argv[1], sys.argv[2], desc, args)

