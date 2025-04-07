#   keccak-xrv  --  Keccak instruction testing

2025-04-07  Markku-Juhani Saarinen -- markku-juhani.saarinen@tuni.fi

Hi,

In the last TG meeting I mentioned the branch of Spike with Keccak support, orignially from Nicolas (I have merely kept it in sync with the development of Spike.)

This exists in the "dev-keccak" branch of my own fork of Spike at:
https://github.com/mjosaarinen/riscv-isa-sim/tree/dev-keccak

I just synced it with master and tested it,

You can build it like a regular spike (please see spike README
for dependencies):
```
git clone https://github.com/mjosaarinen/riscv-isa-sim.git
cd riscv-isa-sim
git checkout dev-keccak
mkdir build
cd build
../configure --prefix=$RISCV --with-target=riscv64-unknown-linux-gnu
time make
make install
```

#   What the patch does?

There is an additional spike flag `zvkk` that enables the Keccak instruction.

In practice one would invoke a test program `xtest` as:
```
spike --isa=rv64gcv_zvl256b_zvkk_zicntr_zihpm  pk xtest
```

Here's a wrapper function that executes the instruction (see `keccak_insn.c` in the repo below):
```C
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
```


#   Testing

There is a repository with a Makefile and some elementary unit tests at

https://github.com/mjosaarinen/keccak-xrv

Please take a look at the `Makefile`. Once it and your compiler is set up to support everything needed you should be able to just say `make` to run a bunch of unit tests:
```
$ make
riscv64-unknown-linux-gnu-clang -march=rv64gcv_zvl256b -Wall -c keccak_insn.c -o keccak_insn.o
riscv64-unknown-linux-gnu-clang -march=rv64gcv_zvl256b -Wall -c sha3_api.c -o sha3_api.o
riscv64-unknown-linux-gnu-clang -march=rv64gcv_zvl256b -Wall -c test_main.c -o test_main.o
riscv64-unknown-linux-gnu-clang -march=rv64gcv_zvl256b -Wall -c test_rvkat_sio.c -o test_rvkat_sio.o
riscv64-unknown-linux-gnu-clang -march=rv64gcv_zvl256b -Wall -c test_sha3.c -o test_sha3.o
riscv64-unknown-linux-gnu-clang -static -march=rv64gcv_zvl256b -Wall -o xtest keccak_insn.o sha3_api.o test_main.o test_rvkat_sio.o test_sha3.o
spike --isa=rv64gcv_zvl256b_zvkk_zicntr_zihpm  pk xtest
           PLAT_ARCH_STR = PLAT_ARCH_RV64
               PLAT_XLEN = 64
              0x01020304 = 04 03 02 01
      0x0102030405060708 = 08 07 06 05 04 03 02 01
            sizeof(char) = 1
           sizeof(short) = 2
             sizeof(int) = 4
          sizeof(void *) = 8
            sizeof(long) = 8
       sizeof(long long) = 8
          sizeof(size_t) = 8
           ((char) 0xFF) = 255
  ((unsigned char) 0xFF) = 255
                    vlen = 256
                   cycle = 330399
                 instret = 332030
[INFO]  === SHA3 ===
[PASS]  KECCAK-P 1581ED5252B07483009456B676A6F71D7D79518A4B1965F7450576D1437B47206A60F6F3A48B5FD193D48D7C4F14D7A13FFD38519693D130BEE31B9572947E485A7ADACB58A8F30C887FB19B384EE52F8F269F0DDE38730B7F6D258BF5DFEF556A3E2CEB943E35C8111F908C94F62A2EA69D30CA0CDE73E8E2314D946CC2AFF7D715C48C80EAF5A0CFD83E7E4331F55321D2A4433B1F7F7785E999B43CA60CFD3023D1C5C055C0D4DFA7E0A68AE52FA7A348997C93F51A42880834713010165E334A7E293AF453D1
[PASS]  SHA3-224 6B4E03423667DBB73B6E15454F0EB1ABD4597F9A1B078E3F5B5A6BC7
[PASS]  SHA3-256 64537B87892835FF0963EF9AD5145AB4CFCE5D303A0CB0415B3B03F9D16E7D6B
[PASS]  SHA3-384 D1C0FA85C8D183BEFF99AD9D752B263E286B477F79F0710B010317017397813344B99DAF3BB7B1BC5E8D722BAC85943A
[PASS]  SHA3-512 6E8B8BD195BDD560689AF2348BDC74AB7CD05ED8B9A57711E9BE71E9726FDA4591FEE12205EDACAF82FFBBAF16DFF9E702A708862080166C2FF6BA379BC7FFC2
[PASS]  SHAKE128 9DE6FFACF3E59693A3DE81B02F7DB77A
[PASS]  SHAKE256 89F2373E131A899B4BA27F6DA606716A5E289FD530AE066BB8B11DC023DACBD6
[PASS]  SHAKE128 43E41B45A653F2A5C4492C1ADD544512DDA2529833462B71A41A45BE97290B6F
[PASS]  SHAKE256 AB0BAE316339894304E35877B0C28A9B1FD166C796B9CC258A064A8F57E27F2A
[PASS]  SHAKE128 44C9FB359FD56AC0A9A75A743CFF6862F17D7259AB075216C0699511643B6439
[PASS]  SHAKE256 6A1A9D7846436E4DCA5728B6F760EEF0CA92BF0BE5615E96959D767197A0BEEB
[INFO] fail= 0
```

ps. You may also want to try the Rijndael-256 stuff at: https://github.com/mjosaarinen/rij256-rv
