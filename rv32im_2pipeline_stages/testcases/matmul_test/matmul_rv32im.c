#include <stdio.h>
#include <stdint.h>

#define VEC_SIZE 128

// Macro to generate 32 incrementing values starting from x
#define SEQ_32(x) \
    x,    x+1,  x+2,  x+3,  x+4,  x+5,  x+6,  x+7,  \
    x+8,  x+9,  x+10, x+11, x+12, x+13, x+14, x+15, \
    x+16, x+17, x+18, x+19, x+20, x+21, x+22, x+23, \
    x+24, x+25, x+26, x+27, x+28, x+29, x+30, x+31

#define SEQ_16(x) \
    x,    x+1,  x+2,  x+3,  x+4,  x+5,  x+6,  x+7,  \
    x+8,  x+9,  x+10, x+11, x+12, x+13, x+14, x+15   

// 1. Pre-loaded Inputs: Sequence 0 to 127
static const int8_t weights[VEC_SIZE] = {
    SEQ_16(0), SEQ_16(0), SEQ_16(0), SEQ_16(0)
};

// 2. Pre-loaded Weights for Neuron 1: All 2s
static const int8_t activation_n1[VEC_SIZE] = { [0 ... 127] = 20 };

// 3. Pre-loaded Weights for Neuron 2: All 3s
static const int8_t activation_n2[VEC_SIZE] = { [0 ... 127] = 40 };


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



int main() {
    int32_t acc1 = 0;
    int32_t acc2 = 0;

    // Calculate both neurons in a single pass
    for (int i = 0; i < VEC_SIZE; i++) {
        acc1 += (int32_t)weights[i] * (int32_t)activation_n1[i];
        acc2 += (int32_t)weights[i] * (int32_t)activation_n2[i];
    }

    // Print results for verification
    print_str("--- Neural Layer Test ---");
    putnl();
    print_str("Neuron 1 Result (Expected 9600):");
    putnl();
    print_dec(acc1);
    putnl();
    print_str("Neuron 2 Result (Expected 19200):");
    putnl();
    print_dec(acc2);
    putnl();
    while(1);
}