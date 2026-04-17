
#include <stdint.h>
#include <stdio.h>


__attribute__((section(".text._start"), naked)) void _start() {
    __asm__ volatile (
        "la sp, _estack\n"
        "call main\n"
    );
    while (1);
}

static inline void putch(char c)
{
    *(volatile uint32_t *)0x0000c000 = (uint32_t)c;
    //putchar(c);
}

void print_str(const char *s)
{
    while (*s) {
        putch(*s++);
    }
}

void print_dec(int x)
{
    unsigned int u;
    int started = 0;

    /* handle sign safely */
    if (x < 0) {
        putch('-');
        u = (unsigned int)(-(x + 1)) + 1;  // safe for INT_MIN
    } else {
        u = (unsigned int)x;
    }

    /* special case zero */
    if (u == 0) {
        putch('0');
        return;
    }

    /* powers of 10, from 10^9 down to 10^0 */
    static const unsigned int p10[] = {
        1000000000u,
        100000000u,
        10000000u,
        1000000u,
        100000u,
        10000u,
        1000u,
        100u,
        10u,
        1u
    };

    for (int i = 0; i < 10; i++) {
        unsigned int p = p10[i];
        unsigned int digit = 0;

        while (u >= p) {
            u -= p;
            digit++;
        }

        if (digit || started) {
            putch('0' + digit);
            started = 1;
        }
    }
}


static inline void putnl(void)
{
    putch('\n');
}


#define GPIO_DIR   (*(volatile unsigned int*)0x8000)
#define GPIO_OUT   (*(volatile unsigned int*)0x8004)
#define GPIO_IN    (*(volatile unsigned int*)0x8008)

#define MAX_LEN 20

#define UP    0
#define DOWN  1
#define LEFT  2
#define RIGHT 3

unsigned char snake[MAX_LEN];
unsigned char head = 3;
unsigned char tail = 0;
unsigned char length = 4;

unsigned char dir = RIGHT;

unsigned char food = 12;

unsigned int occupied = 0;


// Compute next cell (NO division)
int next_pos(int pos, unsigned char d)
{
    int r = pos >> 3;   // row
    int c = pos & 7;    // col

    if (d == RIGHT) {
        if (c == 7)
            return (r << 3);      // wrap to col 0
        return pos + 1;
    }

    if (d == LEFT) {
        if (c == 0)
            return (r << 3) | 7;  // wrap to col 7
        return pos - 1;
    }

    if (d == DOWN) {
        if (r == 3)
            return c;             // wrap to row 0
        return pos + 8;
    }

    if (d == UP) {
        if (r == 0)
            return (3 << 3) | c;  // wrap to row 3
        return pos - 8;
    }

    return pos;
}

void spawn_food()
{
    food += 5;
    if (food >= 32)
        food -= 32;

    while (occupied & (1 << food)) {
        food++;
        if (food >= 32)
            food = 0;
    }
}


void read_input()
{
    unsigned int in = GPIO_IN;

    // prevent 180-degree reverse
    if ((in & 1) && dir != DOWN) dir = UP;
    else if ((in & 2) && dir != UP) dir = DOWN;
    else if ((in & 4) && dir != RIGHT) dir = LEFT;
    else if ((in & 8) && dir != LEFT) dir = RIGHT;
}


void step()
{
    int next = next_pos(snake[head], dir);

    /*if (next < 0)
        return;   // wall collision*/

    if (occupied & (1 << next))
        return;   // self collision

    head++;
    if (head >= MAX_LEN)
        head = 0;

    snake[head] = next;
    occupied |= (1 << next);

    if (next == food) {
        if (length < MAX_LEN)
            length++;
        spawn_food();
    }
    else {
        occupied &= ~(1 << snake[tail]);
        tail++;
        if (tail >= MAX_LEN)
            tail = 0;
    }
}


void render()
{
    GPIO_OUT = occupied | (1 << food);
}


void init_game()
{
   for (int i = 0; i < MAX_LEN; i++)
        snake[i] = 0;

    head = 3;
    tail = 0;
    length = 4;
    dir = RIGHT;
    food = 12;

    snake[0] = 1;
    snake[1] = 2;
    snake[2] = 3;
    snake[3] = 4;

    occupied = (1<<1)|(1<<2)|(1<<3)|(1<<4);

    GPIO_OUT = 0;   // clear LEDs
}



int main()
{   
    print_str("Starting Snek Game Ptsssssss");
    putnl();
	
   GPIO_DIR = 0xFFFFFFFF;   // LEDs as output

    init_game();

    while (1)
    {
        read_input();
        step();
        render();
    }
        return 0;
}

