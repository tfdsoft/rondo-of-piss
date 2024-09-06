/**
 * @name famistudio_music_play
 *
 * @brief Plays a song from and loads the music data according to the bank.
 *
 * @param song Song index.
 *
 */
void __fastcall__ music_play(unsigned char song);

/**
 * @brief Plays a sound effect.
 * 
 * @param sfx_index Sound effect index (0...127)
 * @param channel Offset of sound effect channel, should be FAMISTUDIO_SFX_CH0..FAMISTUDIO_SFX_CH3
 *
 */
#define sfx_play(sfx_index, channel) (__AX__ = (unsigned short)(byte(channel))<<8|sfx_index, _sfx_play(__AX__))
void __fastcall__ _sfx_play(unsigned short args);

/**
 * @brief Main update function, should be called once per frame, ideally at the end of NMI.
 * Will update the tempo, advance the song if needed, update instrument and apply any change to the APU registers.
 * 
 */
void __fastcall__ music_update();

#define low_word(a) *((unsigned short*)&a)
#define high_word(a) *((unsigned short*)&a+1)

#define byte(x) (((x)&0xFF))
#define word(x) (((x)&0xFFFF))

// set palette color, index 0..31
// completely inlines and replaces neslib's
extern unsigned char PAL_UPDATE;
extern unsigned char PAL_BUF[32];
#pragma zpsym("PAL_UPDATE")
#define pal_col(index, color) do { PAL_BUF[index&0x1F] = (color); ++PAL_UPDATE; } while(0);



