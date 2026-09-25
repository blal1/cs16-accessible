// Plays every cue left / center / right / behind and exports each one as a WAV file.
// Includes the .cpp directly to reach the synthesized buffers.
#include "access_audio.cpp"
#include <stdio.h>

static const char *kNames[CUE_COUNT] = { "wall_tap", "wall_front", "ledge", "step", "beacon", "arrived", "enemy",
	"teammate", "aim", "aim_lock", "objective", "north", "scan", "opening", "damage", "grenade", "heartbeat",
	"ammo_low", "enemy_spotted" };

static void WriteWav( const char *path, const std::vector<float> &pcm )
{
	FILE *f = fopen( path, "wb" );
	if( !f ) return;
	const unsigned dataBytes = (unsigned)pcm.size() * 2, rate = SAMPLE_RATE, byteRate = SAMPLE_RATE * 2, riff = 36 + dataBytes, fmtLen = 16;
	const unsigned short pcmTag = 1, ch = 1, align = 2, bits = 16;
	fwrite( "RIFF", 1, 4, f ); fwrite( &riff, 4, 1, f ); fwrite( "WAVEfmt ", 1, 8, f ); fwrite( &fmtLen, 4, 1, f );
	fwrite( &pcmTag, 2, 1, f ); fwrite( &ch, 2, 1, f ); fwrite( &rate, 4, 1, f ); fwrite( &byteRate, 4, 1, f );
	fwrite( &align, 2, 1, f ); fwrite( &bits, 2, 1, f ); fwrite( "data", 1, 4, f ); fwrite( &dataBytes, 4, 1, f );
	for( float s : pcm ) { short v = (short)( ( s > 1 ? 1 : ( s < -1 ? -1 : s ) ) * 32767 ); fwrite( &v, 2, 1, f ); }
	fclose( f );
}

int main( int argc, char **argv )
{
	const bool play = argc < 2 || strcmp( argv[1], "--wav-only" );
	if( !AccessAudio_Init() ) { printf( "XAudio2 init FAILED\n" ); return 1; }
	printf( "XAudio2 OK, %d cues\n", CUE_COUNT );
	for( int c = 0; c < CUE_COUNT; c++ )
	{
		char path[64];
		snprintf( path, sizeof( path ), "cue_%02d_%s.wav", c, kNames[c] );
		WriteWav( path, s_Cues[c] );
		printf( "%-14s %5.0f ms  -> %s\n", kNames[c], s_Cues[c].size() * 1000.0 / SAMPLE_RATE, path );
		if( !play ) continue;
		const AccessCueParams positions[4] = { { -1, 0.8f, 1, 0 }, { 0, 0.8f, 1, 0 }, { 1, 0.8f, 1, 0 }, { 0, 0.8f, 1, 1 } };
		for( const AccessCueParams &p : positions ) { AccessAudio_Play( (AccessCue)c, p ); Sleep( 450 ); }
	}
	Sleep( 500 );
	AccessAudio_Shutdown();
	return 0;
}
