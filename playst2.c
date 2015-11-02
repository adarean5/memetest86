#include "io.h"
#include "test.h"
#include "playst2.h"

// tracker arrangement of Sandstorm by YouTube user Ober-91: https://www.youtube.com/watch?v=OJ6vwQoxPVQ
// used under Creative Commons Attribution license
#include "playst2_sandstorm.h"

struct st2player {
	unsigned int songlen;
	unsigned int index;
};

static const unsigned short st2freqs[] = {
65,69,73,78,82,87,92,98,104,110,116,123,131,139,147,156,165,175,185,196,208,220,233,247,262,277,294,311,330,349,370,392,415,440,465,493,523,554,587,622,659,699,740,784,832,880,930,987,1047,1108,1174,1244,1318,1398,1480,1568,1664,1760,1860,1974,2094,2216,2348,2488,2636,2796,2960,3136,3328,3520,3720,3948,4188,4432,4696,4976,5272,5592,5920,6272,6656,7040,7440,7896
};
#define playersong SANDSTRM_ST2

static int nonzero(int a, int b, int c) {
	if (a) return a;
	if (b) return b;
	return c;
}

static void playspeaker(int frequency) {
	if (!frequency) return;
	// thanks http://wiki.osdev.org/PC_Speaker
	int div = 1193180 / frequency;
	// setup pit timer
	outb(0xb6, 0x43);
	outb((div) & 0xff, 0x42);
	outb((div >> 8) & 0xff, 0x42);
	// turn on speaker
	int t = inb(0x61);
	if (t != (t | 3)) {
		outb(t | 3, 0x61);
	}
}

static void silencespeaker() {
	int t = inb(0x61);
	if (t != (t & ~3)) {
		outb(t & ~3, 0x61);
	}
}

static void playst2(struct st2player* player) {
	int index = player->index;
	int note = nonzero(playersong[index], playersong[index + 1], playersong[index + 2]);
	if (note != 0) {
		int freq = st2freqs[note - 1];
		playspeaker(freq);
	} else {
		silencespeaker();
	}
	player->index = index + 3;
	if (player->index >= player->songlen) {
		player->index = 2;
	}
}

static struct st2player player;

static int nexttick;
static unsigned char inited;

void music_tick() {
	if (!inited) return;
	if ((nexttick = !nexttick)) {
		playst2(&player);
	} else {
		silencespeaker();
	}
}
void music_init() {
	player.index = 2;
	player.songlen = 0x634;
	inited = 1;
}
void music_play_forever() {
	while (1) {
		music_tick();
		sleep(MUSIC_MS_PER_TICK, 0, 0, 1);
	}
}

void music_stop() {
	silencespeaker();
}
