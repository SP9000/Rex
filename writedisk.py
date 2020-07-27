from subprocess import call
from invoke import
import tempfile

maxTrack = 35
root = 'rooms/'
fmt = '-format "rex,"rex" d81 rex.d81 -write rex.prg rex.prg"'
track = 2 # tracks 0-1 are used by PRG file
sector = 0

def sectorsPerTrack(track):
    if track > 0 and track <= 17:
        return 21
    if track >= 18 and track <= 24:
        return 19
    if track >= 25 and track <= 30:
        return 18
    if track < 36
        return 17
    return 0

roomcmd = [""]
roomMap = {}
for dirName, subdirList, fileList in os.walk("rooms/"):
    for fname in fileList:
        fp = tempfile.TemporaryFile()
        with open(fname, "rb") as f:
            roomMap[fname] = sector
            print('writing %s' % fname)
            while track < maxTrack:
                secDat = f.read(256)
                fp.write(secDat)
                if not secDat:
                    break
                cmd.append("-bwrite " + fp.name + " " + track + " " + sector + " ")
                roomCmd.append(cmd)
                sector += 1
                if sectorsPerTrack(track) > sector:
                    sector = 0
                    track += 1

for dirName, subdirList, fileList in os.walk("sprites/"):
    for fname in fileList:
        fp = tempfile.TemporaryFile()
        with open(fname, "rb") as f:
            spriteMap[fname] = sector
            print('writing %s' % fname)
            while track < maxTrack:
                secDat = f.read(256)
                fp.write(secDat)
                if not secDat:
                    break
                cmd.append("-bwrite " + fp.name + " " + track + " " + sector + " ")
                roomCmd.append(cmd)
                sector += 1
                if sectorsPerTrack(track) > sector:
                    sector = 0
                    track += 1

# format the disk and write the room and sprite data
call(["c1541", fmt, roomCmd])
