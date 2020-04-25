; Vic-20 Player 2 : 4mat/Orb 2007.
;
; Music data. Test tune is "Megademo: Bumpmap screen"
;
; Compiles with DASM.

.export songstart
.export songtab
.export songpos
.export tempo
.export tempotick
.export insttab
.export volamount
.export volbyte
.export inststart
.export notelen
.export patttab
.export pattpos
.export ticks

rest = $00
cn1  = $01
cs1  = $02
dn1  = $03
ds1  = $04
en1  = $05
fn1  = $06
fs1  = $07
gn1  = $08
gs1  = $09
an1  = $0a
as1  = $0b
bn1  = $0c
cn2  = $0d
cs2  = $0e
dn2  = $0f
ds2  = $10
en2  = $11
fn2  = $12
fs2  = $13
gn2  = $14
gs2  = $15
an2  = $16
as2  = $17
bn2  = $18
cn3  = $19
cs3  = $1a
dn3  = $1b
ds3  = $1c
en3  = $1d
fn3  = $1e
fs3  = $1f
gn3  = $20
gs3  = $21
an3  = $22
as3  = $23
bn3  = $24
cn4  = $25
cs4  = $26
dn4  = $27
stop_pattern = $7f
nl1 = $80
nl2 = $81
nl3 = $82
nl4 = $83
nl5 = $84
nl6 = $85
nl7 = $86
nl8 = $87
nl9 = $88
nla = $89
nlb = $8a
nlc = $8b
nld = $8c
nle = $8d
nlf = $8e
nl10 = $8f
in0 = $f0
in1 = $f1
in2 = $f2
in3 = $f3
in4 = $f4
in5 = $f5
in6 = $f6
in7 = $f7
in8 = $f8
in9 = $f9
ina = $fa
inb = $fb
;inc = $fc
ind = $fd
ine = $fe
inf = $ff
rp1 = $e0
rp2 = $e1
rp3 = $e2
rp4 = $e3
rp5 = $e4
rp6 = $e5
rp7 = $e6
rp8 = $e7
rp9 = $e8
rpa = $e9
rpb = $ea
rpc = $eb
rpd = $ec
rpe = $ed
rpf = $ee
rp10 = $ef
tr0 = $f0
tr1 = $f1
tr2 = $f2
tr3 = $f3
tr4 = $f4
tr5 = $f5
tr6 = $f6
tr7 = $f7
tr8 = $f8
tr9 = $f9
tra = $fa
trb = $fb
trc = $fc
trd = $fd
tre = $fe
song_end = $ff
note = $00
arp1 = $01
arp2 = $02
arp3 = $03
arp4 = $04
arp5 = $05
arp6 = $06
arp7 = $07
arp8 = $08
arp9 = $09
arpa = $0a
arpb = $0b
arpc = $0c
arpd = $0d
arpe = $0e
arpf = $0f
wav = $10
wav1 = $11
wav2 = $12
wav3 = $13
wav4 = $14
wav5 = $15
wav6 = $16
wav7 = $17
wav8 = $18
wav9 = $19
wava = $1a
wavb = $1b
wavc = $1c
wavd = $1d
wave = $1e
wavf = $1f
loopback1 = $60
loopback2 = $61
loopback3 = $62
loopback4 = $63
loopback5 = $64
loopback6 = $65
loopback7 = $66
loopback8 = $67
loopback9 = $68
loopbacka = $69
loopbackb = $6a
loopbackc = $6b
loopbackd = $6c
loopbacke = $6d
loopbackf = $6e
loopback10 = $6f
off = $7f

patttab:
	; blank (used for song startup)
pat_off=*-patttab
        .byte rest
        .byte stop_pattern

pat_melody=*-patttab
	.byte in2
	.byte nl2
	.byte en2
	.byte en2
	.byte nl4
	.byte en2

	.byte nl2
	.byte en2
	.byte en2
	.byte nl4
	.byte en2

	.byte nl2
	.byte en2
	.byte gn2
	.byte cn2
	.byte dn2
	.byte nl8
	.byte en2

	.byte nl2
	.byte fn2
	.byte fn2
	.byte fn2
	.byte nl1
	.byte fn2

	.byte nl2
	.byte fn2
	.byte en2
	.byte en2
	.byte nl1
	.byte en2
	.byte en2

        .byte stop_pattern

        ; drums (just bdrum and hihat)
        .byte nl2
        .byte in1
        .byte en1
        .byte nl1
        .byte in3
        .byte en1
        .byte en1
        .byte in1
        .byte en1
        .byte nl2
        .byte in3
        .byte en1
        .byte nl1
        .byte en1
        .byte stop_pattern

        ; bass
        .byte nl10
        .byte cn1
        .byte nl8
        .byte cn1
        .byte dn1
        .byte nl10
        .byte ds1
        .byte nl8
        .byte ds1
        .byte fn1
        .byte nl10
        .byte gn1
        .byte nl8
        .byte gn1
        .byte gs1
        .byte nl10
        .byte as1
        .byte nl8
        .byte as1
        .byte bn1
        .byte stop_pattern

        ; chords
        .byte nl10
        .byte in4
        .byte cn2
        .byte nl8
        .byte cn2
        .byte in5
        .byte as1
        .byte nl10
        .byte in6
        .byte as1
        .byte nl8
        .byte as1
        .byte in5
        .byte as1
        .byte nl10
        .byte in6
        .byte as1
        .byte nl8
        .byte as1
        .byte in5
        .byte gs1
        .byte nl10
        .byte in5
        .byte ds1
        .byte nl8
        .byte ds1
        .byte in6
        .byte dn1
        .byte stop_pattern

        ; intro cowbells
        .byte nl10
        .byte in0
        .byte cn3
        .byte cn3
        .byte cn3
        .byte cn3
        .byte stop_pattern

        ; bass intro
        .byte nl10
        .byte in2
        .byte cn1
        .byte cn1
        .byte cn2
        .byte cn2
        .byte stop_pattern

        ; drums with snare
        .byte nl2
        .byte in1
        .byte en1
        .byte nl1
        .byte in3
        .byte en1
        .byte en1
        .byte in7
        .byte en1
        .byte nl2
        .byte in3
        .byte en1
        .byte nl1
        .byte en1
        .byte stop_pattern

        ; bass outro
        .byte nl10
        .byte in8
        .byte cn1
        .byte stop_pattern

;--------------------------------------
songtab:
song1=0
	.byte pat_off
	.byte song_end

	; channel 2
song2=*-songtab
	.byte pat_off
        .byte song_end

        ; channel 3
song3=*-songtab
	.byte pat_melody
        .byte song_end

pattpos: .byte $01,$01,$01
songpos: .byte song1,song2,song3
songstart: .byte song1, song2, song3

tempo: .byte $06,$06
ticks: .byte $06
tempotick: .byte $01

; Inst number:    0   1   2   3   4   5   6   7   8
inststart: .byte $45,$02,$0c,$17,$1f,$29,$33,$3d,$56
notelen:   .byte $2f,$85,$1f,$82,$7f,$7f,$7f,$85,$3f
volbyte:   .byte $f0,$2f,$6f,$28,$37,$37,$37,$2f,$0f
volamount: .byte $0f,$03,$03,$01,$02,$02,$02,$03,$20

insttab:
        ; Channel switched off, repeating on previous frame.
        .byte off
        .byte loopback1

        ; Bass drum, using the noise channel so 2 bytes for each frame tick.
        ; Also you can see I'm setting the pitch of the tone channel with bytes >$80
        .byte $fe
        .byte $ca
        .byte $dd
        .byte $a8
        .byte $a0
        .byte $97
        .byte off
        .byte off
        .byte note
        .byte loopback3

        ; Bass sound, using arpeggios, goes back 7 frames every time it loops.
        .byte note
        .byte note
        .byte note
        .byte loopback3

        ; The 'hihat' sound, uses noise channel.
        .byte $fe
        .byte $ef
        .byte $f8
        .byte $f5
        .byte $fe
        .byte $ef
        .byte note
        .byte loopback5

        ; Arpeggios, with wave fx.
        .byte wavc
        .byte wavc
        .byte wav7
        .byte arp7
        .byte arp3
        .byte arp3
        .byte note
        .byte wav
        .byte note
        .byte loopback9

        .byte wavc
        .byte wavc
        .byte wav7
        .byte arp7
        .byte arp4
        .byte arp4
        .byte note
        .byte wav
        .byte note
        .byte loopback9

        .byte wavc
        .byte wavc
        .byte wav9
        .byte arp9
        .byte arp5
        .byte arp5
        .byte note
        .byte wav
        .byte note
        .byte loopback9

        ; Snare drum, using noise channel, ends on the highest noise pitch with the tone
        ; channel switched off. (off)
        .byte $fd
        .byte $ca
        .byte $dd
        .byte $a8
        .byte $fe
        .byte off
        .byte note
        .byte loopback3

        ; Other sounds, using off to turn off the note for an echo effect.
        .byte note
        .byte note
        .byte 235
        .byte 235
        .byte note
        .byte note
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte loopback10

	.byte arpc
	.byte arpc
	.byte arpc
	.byte arpc
	.byte note
	.byte note
	.byte note
	.byte note
	.byte note
	.byte off
	.byte off
	.byte note
	.byte note
	.byte note
	.byte note
	.byte note
	.byte loopback10
