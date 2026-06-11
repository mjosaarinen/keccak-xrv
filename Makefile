#	Makefile
#	2023-06-16	Markku-Juhani O. Saarinen <mjos@iki.com>

XBIN	=	xtest
CC		=	riscv64-unknown-linux-gnu-gcc
#RVKISA	=	rv64gcv_zbb_zvbb_zvbc_zvkg_zvkned_zvknhb_zvksed_zvksh_zvl256b
RVKISA	=	rv64gcv_zvl256b
SPIKE	=	spike
SPIKEFL	=	--isa=$(RVKISA)_zvkk_zicntr_zihpm
CFLAGS	=	-march=$(RVKISA) -mabi=lp64d -Wall
LDFLAGS	=	-static --sysroot=$(RISCV)/sysroot/usr
CSRC	= 	$(wildcard *.c)
SSRC	= 	$(wildcard *.s *.S)
OBJS	=	$(CSRC:.c=.o) $(SSRC:.s=.o)
LDLIBS	=

run:	$(XBIN)
	$(SPIKE) $(SPIKEFL)  pk $(XBIN)

$(XBIN): $(OBJS) Makefile
	$(CC) $(LDFLAGS) $(CFLAGS) -o $(XBIN) $(OBJS) $(LDLIBS)

#	not used currently
%.o:	%.[csS]
	$(CC) $(CFLAGS) -c $^ -o $@

#	Cleanup
clean:
	$(RM) -f $(XBIN) $(OBJS)

