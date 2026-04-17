#define TTY (*(volatile unsigned char*)0xC000)
void print_str(const char*);
void test_jal_target();
void test_jalr_target();

void _start() {
    int a = 10, b = 10;
    if (a == b) {
        print_str("BNE: Success\n");
    }

    b = 20;
    if (a != b) {
        print_str("BEQ: Success\n");
    }

    int s1 = -5, s2 = 2;
    if (s1 < s2) {
        print_str("BGE: Success\n");
    }

    if (s2 >= s1) {
        print_str("BLT: Success\n");
    }

    unsigned int u1 = 1;
    unsigned int u2 = 0xFFFFFFFF; 
    if (u1 < u2) {
        print_str("BGEU: Success\n");
    }

    if (u2 >= u1) {
        print_str("BLTU: Success\n");
    }

    test_jal_target();

    void (*func_ptr)() = test_jalr_target;
    func_ptr();

    print_str("Done\n");

    while(1);
}


void print_str(const char* s) {
    while (*s) {
        TTY = *s++;
    }
}

void test_jal_target() {
    print_str("JAL: Success\n");
}

void test_jalr_target() {
    print_str("JALR: Success\n");
}

