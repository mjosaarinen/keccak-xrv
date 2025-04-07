//  keccak_insn.c
//  Markku-Juhani O. Saarinen <mjos@iki.fi>. Credit: Nicolas Brunie.
//  === Single-instruction Keccak-f1600

void keccak_f1600(void *state)
{
    unsigned long vl = 32;

    __asm volatile (
        "vsetivli x0, 25, e64, m8, tu, mu\n"
        "vle64.v v8, 0(%[state])\n"
        "vsetvli %[vl], %[vl], e64, m8, tu, mu\n"
        // .insn r opc, func3, func7, vd, vs1, vs2
        ".insn r 0x77, 0x2, 0x53, x8, x17, x24\n"
        "vsetivli x0, 25, e64, m8, tu, mu\n"
        "vse64.v v8, 0(%[state])\n"
        : [vl]"+r"(vl)
        : [state]"r"(state)
        :
    );
}

