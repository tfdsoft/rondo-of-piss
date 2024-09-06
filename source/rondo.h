extern unsigned char pad;
extern unsigned char pad_new;

#pragma zpsym("pad")
#pragma zpsym("pad_new")


#pragma bss-name(push, "ZEROPAGE")
unsigned char funny;

#pragma bss-name("BSS")