
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a2010113          	add	sp,sp,-1504 # 80008a20 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	add	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	89070713          	add	a4,a4,-1904 # 800088e0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	fae78793          	add	a5,a5,-82 # 80006010 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca97>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e2678793          	add	a5,a5,-474 # 80000ed2 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	6d6080e7          	jalr	1750(ra) # 80002800 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7e4080e7          	jalr	2020(ra) # 8000091e <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	add	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	add	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	add	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	89450513          	add	a0,a0,-1900 # 80010a20 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	aa4080e7          	jalr	-1372(ra) # 80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	88448493          	add	s1,s1,-1916 # 80010a20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00011917          	auipc	s2,0x11
    800001a8:	91490913          	add	s2,s2,-1772 # 80010ab8 <cons+0x98>
  while(n > 0){
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
      if(killed(myproc())){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	8a6080e7          	jalr	-1882(ra) # 80001a62 <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	486080e7          	jalr	1158(ra) # 8000264a <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	1b8080e7          	jalr	440(ra) # 8000238a <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00011717          	auipc	a4,0x11
    800001ec:	83870713          	add	a4,a4,-1992 # 80010a20 <cons>
    800001f0:	0017869b          	addw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	and	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	add	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	590080e7          	jalr	1424(ra) # 800027aa <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
      break;

    dst++;
    80000228:	0a05                	add	s4,s4,1
    --n;
    8000022a:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
        release(&cons.lock);
    80000236:	00010517          	auipc	a0,0x10
    8000023a:	7ea50513          	add	a0,a0,2026 # 80010a20 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	aae080e7          	jalr	-1362(ra) # 80000cec <release>
        return -1;
    80000246:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	add	sp,sp,96
    8000025a:	8082                	ret
      if(n < target){
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
        cons.r--;
    80000264:	00011717          	auipc	a4,0x11
    80000268:	84f72a23          	sw	a5,-1964(a4) # 80010ab8 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000027a:	00010517          	auipc	a0,0x10
    8000027e:	7a650513          	add	a0,a0,1958 # 80010a20 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	a6a080e7          	jalr	-1430(ra) # 80000cec <release>
  return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	add	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
    uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	59c080e7          	jalr	1436(ra) # 80000840 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	add	sp,sp,16
    800002b2:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	58a080e7          	jalr	1418(ra) # 80000840 <uartputc_sync>
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	57e080e7          	jalr	1406(ra) # 80000840 <uartputc_sync>
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	574080e7          	jalr	1396(ra) # 80000840 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d6:	1101                	add	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	add	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e2:	00010517          	auipc	a0,0x10
    800002e6:	73e50513          	add	a0,a0,1854 # 80010a20 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	94e080e7          	jalr	-1714(ra) # 80000c38 <acquire>

  switch(c){
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	54e080e7          	jalr	1358(ra) # 80002856 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00010517          	auipc	a0,0x10
    80000314:	71050513          	add	a0,a0,1808 # 80010a20 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	9d4080e7          	jalr	-1580(ra) # 80000cec <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	add	sp,sp,32
    80000328:	8082                	ret
  switch(c){
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000332:	00010717          	auipc	a4,0x10
    80000336:	6ee70713          	add	a4,a4,1774 # 80010a20 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
      consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00010797          	auipc	a5,0x10
    80000360:	6c478793          	add	a5,a5,1732 # 80010a20 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	and	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00010797          	auipc	a5,0x10
    8000038e:	72e7a783          	lw	a5,1838(a5) # 80010ab8 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a0:	00010717          	auipc	a4,0x10
    800003a4:	68070713          	add	a4,a4,1664 # 80010a20 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b0:	00010497          	auipc	s1,0x10
    800003b4:	67048493          	add	s1,s1,1648 # 80010a20 <cons>
    while(cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003be:	37fd                	addw	a5,a5,-1
    800003c0:	07f7f713          	and	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
      cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
    while(cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f6:	00010717          	auipc	a4,0x10
    800003fa:	62a70713          	add	a4,a4,1578 # 80010a20 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
      cons.e--;
    8000040a:	37fd                	addw	a5,a5,-1
    8000040c:	00010717          	auipc	a4,0x10
    80000410:	6af72a23          	sw	a5,1716(a4) # 80010ac0 <cons+0xa0>
      consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
      consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	5ee78793          	add	a5,a5,1518 # 80010a20 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	and	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000456:	00010797          	auipc	a5,0x10
    8000045a:	66c7a323          	sw	a2,1638(a5) # 80010abc <cons+0x9c>
        wakeup(&cons.r);
    8000045e:	00010517          	auipc	a0,0x10
    80000462:	65a50513          	add	a0,a0,1626 # 80010ab8 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	f88080e7          	jalr	-120(ra) # 800023ee <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void
consoleinit(void)
{
    80000470:	1141                	add	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b8858593          	add	a1,a1,-1144 # 80008000 <etext>
    80000480:	00010517          	auipc	a0,0x10
    80000484:	5a050513          	add	a0,a0,1440 # 80010a20 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	720080e7          	jalr	1824(ra) # 80000ba8 <initlock>

  uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	354080e7          	jalr	852(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000498:	00020797          	auipc	a5,0x20
    8000049c:	73878793          	add	a5,a5,1848 # 80020bd0 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	add	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	add	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	add	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	add	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	add	a3,s0,-48

  i = 0;
    800004d2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	26260613          	add	a2,a2,610 # 80008738 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	sll	a5,a5,0x20
    800004e8:	9381                	srl	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	add	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

  if(sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
    buf[i++] = '-';
    80000506:	fe070793          	add	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	add	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	add	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addw	a4,a4,-1
    80000532:	1702                	sll	a4,a4,0x20
    80000534:	9301                	srl	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
  while(--i >= 0)
    80000546:	14fd                	add	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	add	sp,sp,48
    80000556:	8082                	ret
    x = -xx;
    80000558:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
    x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000560:	1101                	add	sp,sp,-32
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	add	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056c:	00010797          	auipc	a5,0x10
    80000570:	5607aa23          	sw	zero,1396(a5) # 80010ae0 <pr+0x18>
  printf("panic: ");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	a9450513          	add	a0,a0,-1388 # 80008008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	a8250513          	add	a0,a0,-1406 # 80008010 <etext+0x10>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	00008717          	auipc	a4,0x8
    800005a4:	30f72023          	sw	a5,768(a4) # 800088a0 <panicked>
  for(;;)
    800005a8:	a001                	j	800005a8 <panic+0x48>

00000000800005aa <printf>:
{
    800005aa:	7131                	add	sp,sp,-192
    800005ac:	fc86                	sd	ra,120(sp)
    800005ae:	f8a2                	sd	s0,112(sp)
    800005b0:	e8d2                	sd	s4,80(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	0100                	add	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00010d17          	auipc	s10,0x10
    800005ce:	516d2d03          	lw	s10,1302(s10) # 80010ae0 <pr+0x18>
  if(locking)
    800005d2:	040d1463          	bnez	s10,8000061a <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0b63          	beqz	s4,8000062c <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	add	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	18050b63          	beqz	a0,8000077c <printf+0x1d2>
    800005ea:	f4a6                	sd	s1,104(sp)
    800005ec:	f0ca                	sd	s2,96(sp)
    800005ee:	ecce                	sd	s3,88(sp)
    800005f0:	e4d6                	sd	s5,72(sp)
    800005f2:	e0da                	sd	s6,64(sp)
    800005f4:	fc5e                	sd	s7,56(sp)
    800005f6:	f862                	sd	s8,48(sp)
    800005f8:	f466                	sd	s9,40(sp)
    800005fa:	ec6e                	sd	s11,24(sp)
    800005fc:	4981                	li	s3,0
    if(c != '%'){
    800005fe:	02500b13          	li	s6,37
    switch(c){
    80000602:	07000b93          	li	s7,112
  consputc('x');
    80000606:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000608:	00008a97          	auipc	s5,0x8
    8000060c:	130a8a93          	add	s5,s5,304 # 80008738 <digits>
    switch(c){
    80000610:	07300c13          	li	s8,115
    80000614:	06400d93          	li	s11,100
    80000618:	a0b1                	j	80000664 <printf+0xba>
    acquire(&pr.lock);
    8000061a:	00010517          	auipc	a0,0x10
    8000061e:	4ae50513          	add	a0,a0,1198 # 80010ac8 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	616080e7          	jalr	1558(ra) # 80000c38 <acquire>
    8000062a:	b775                	j	800005d6 <printf+0x2c>
    8000062c:	f4a6                	sd	s1,104(sp)
    8000062e:	f0ca                	sd	s2,96(sp)
    80000630:	ecce                	sd	s3,88(sp)
    80000632:	e4d6                	sd	s5,72(sp)
    80000634:	e0da                	sd	s6,64(sp)
    80000636:	fc5e                	sd	s7,56(sp)
    80000638:	f862                	sd	s8,48(sp)
    8000063a:	f466                	sd	s9,40(sp)
    8000063c:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	9e250513          	add	a0,a0,-1566 # 80008020 <etext+0x20>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c46080e7          	jalr	-954(ra) # 80000294 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	2985                	addw	s3,s3,1
    80000658:	013a07b3          	add	a5,s4,s3
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c0>
    if(c != '%'){
    80000664:	ff6515e3          	bne	a0,s6,8000064e <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	2985                	addw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c783          	lbu	a5,0(a5)
    80000672:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000676:	10078b63          	beqz	a5,8000078c <printf+0x1e2>
    switch(c){
    8000067a:	05778a63          	beq	a5,s7,800006ce <printf+0x124>
    8000067e:	02fbf663          	bgeu	s7,a5,800006aa <printf+0x100>
    80000682:	09878863          	beq	a5,s8,80000712 <printf+0x168>
    80000686:	07800713          	li	a4,120
    8000068a:	0ce79563          	bne	a5,a4,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	add	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85e6                	mv	a1,s9
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e1c080e7          	jalr	-484(ra) # 800004bc <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0xac>
    switch(c){
    800006aa:	09678f63          	beq	a5,s6,80000748 <printf+0x19e>
    800006ae:	0bb79363          	bne	a5,s11,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	add	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4605                	li	a2,1
    800006c0:	45a9                	li	a1,10
    800006c2:	4388                	lw	a0,0(a5)
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	df8080e7          	jalr	-520(ra) # 800004bc <printint>
      break;
    800006cc:	b769                	j	80000656 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	add	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	bb2080e7          	jalr	-1102(ra) # 80000294 <consputc>
  consputc('x');
    800006ea:	07800513          	li	a0,120
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	ba6080e7          	jalr	-1114(ra) # 80000294 <consputc>
    800006f6:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srl	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b92080e7          	jalr	-1134(ra) # 80000294 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	sll	s2,s2,0x4
    8000070c:	34fd                	addw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x14e>
    80000710:	b799                	j	80000656 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	add	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x190>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d905                	beqz	a0,80000656 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b6c080e7          	jalr	-1172(ra) # 80000294 <consputc>
      for(; *s; s++)
    80000730:	0485                	add	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x17e>
    80000738:	bf39                	j	80000656 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8de48493          	add	s1,s1,-1826 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x17e>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b4a080e7          	jalr	-1206(ra) # 80000294 <consputc>
      break;
    80000752:	b711                	j	80000656 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b3e080e7          	jalr	-1218(ra) # 80000294 <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b34080e7          	jalr	-1228(ra) # 80000294 <consputc>
      break;
    80000768:	b5fd                	j	80000656 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	6de2                	ld	s11,24(sp)
  if(locking)
    8000077c:	020d1263          	bnez	s10,800007a0 <printf+0x1f6>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	7d02                	ld	s10,32(sp)
    80000788:	6129                	add	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	6de2                	ld	s11,24(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d2>
    release(&pr.lock);
    800007a0:	00010517          	auipc	a0,0x10
    800007a4:	32850513          	add	a0,a0,808 # 80010ac8 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	544080e7          	jalr	1348(ra) # 80000cec <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d6>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1101                	add	sp,sp,-32
    800007b4:	ec06                	sd	ra,24(sp)
    800007b6:	e822                	sd	s0,16(sp)
    800007b8:	e426                	sd	s1,8(sp)
    800007ba:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    800007bc:	00010497          	auipc	s1,0x10
    800007c0:	30c48493          	add	s1,s1,780 # 80010ac8 <pr>
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	86c58593          	add	a1,a1,-1940 # 80008030 <etext+0x30>
    800007cc:	8526                	mv	a0,s1
    800007ce:	00000097          	auipc	ra,0x0
    800007d2:	3da080e7          	jalr	986(ra) # 80000ba8 <initlock>
  pr.locking = 1;
    800007d6:	4785                	li	a5,1
    800007d8:	cc9c                	sw	a5,24(s1)
}
    800007da:	60e2                	ld	ra,24(sp)
    800007dc:	6442                	ld	s0,16(sp)
    800007de:	64a2                	ld	s1,8(sp)
    800007e0:	6105                	add	sp,sp,32
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	add	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	10000737          	lui	a4,0x10000
    80000816:	461d                	li	a2,7
    80000818:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000820:	00008597          	auipc	a1,0x8
    80000824:	81858593          	add	a1,a1,-2024 # 80008038 <etext+0x38>
    80000828:	00010517          	auipc	a0,0x10
    8000082c:	2c050513          	add	a0,a0,704 # 80010ae8 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	378080e7          	jalr	888(ra) # 80000ba8 <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	add	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000840:	1101                	add	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	1000                	add	s0,sp,32
    8000084a:	84aa                	mv	s1,a0
  push_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	3a0080e7          	jalr	928(ra) # 80000bec <push_off>

  if(panicked){
    80000854:	00008797          	auipc	a5,0x8
    80000858:	04c7a783          	lw	a5,76(a5) # 800088a0 <panicked>
    8000085c:	eb85                	bnez	a5,8000088c <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	0715                	add	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000864:	00074783          	lbu	a5,0(a4)
    80000868:	0207f793          	and	a5,a5,32
    8000086c:	dfe5                	beqz	a5,80000864 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086e:	0ff4f513          	zext.b	a0,s1
    80000872:	100007b7          	lui	a5,0x10000
    80000876:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	412080e7          	jalr	1042(ra) # 80000c8c <pop_off>
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	add	sp,sp,32
    8000088a:	8082                	ret
    for(;;)
    8000088c:	a001                	j	8000088c <uartputc_sync+0x4c>

000000008000088e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088e:	00008797          	auipc	a5,0x8
    80000892:	01a7b783          	ld	a5,26(a5) # 800088a8 <uart_tx_r>
    80000896:	00008717          	auipc	a4,0x8
    8000089a:	01a73703          	ld	a4,26(a4) # 800088b0 <uart_tx_w>
    8000089e:	06f70f63          	beq	a4,a5,8000091c <uartstart+0x8e>
{
    800008a2:	7139                	add	sp,sp,-64
    800008a4:	fc06                	sd	ra,56(sp)
    800008a6:	f822                	sd	s0,48(sp)
    800008a8:	f426                	sd	s1,40(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	ec4e                	sd	s3,24(sp)
    800008ae:	e852                	sd	s4,16(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	e05a                	sd	s6,0(sp)
    800008b4:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b6:	10000937          	lui	s2,0x10000
    800008ba:	0915                	add	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008bc:	00010a97          	auipc	s5,0x10
    800008c0:	22ca8a93          	add	s5,s5,556 # 80010ae8 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	00008497          	auipc	s1,0x8
    800008c8:	fe448493          	add	s1,s1,-28 # 800088a8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	00008997          	auipc	s3,0x8
    800008d4:	fe098993          	add	s3,s3,-32 # 800088b0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d8:	00094703          	lbu	a4,0(s2)
    800008dc:	02077713          	and	a4,a4,32
    800008e0:	c705                	beqz	a4,80000908 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e2:	01f7f713          	and	a4,a5,31
    800008e6:	9756                	add	a4,a4,s5
    800008e8:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ec:	0785                	add	a5,a5,1
    800008ee:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	afc080e7          	jalr	-1284(ra) # 800023ee <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3)
    80000904:	fcf71ae3          	bne	a4,a5,800008d8 <uartstart+0x4a>
  }
}
    80000908:	70e2                	ld	ra,56(sp)
    8000090a:	7442                	ld	s0,48(sp)
    8000090c:	74a2                	ld	s1,40(sp)
    8000090e:	7902                	ld	s2,32(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6aa2                	ld	s5,8(sp)
    80000916:	6b02                	ld	s6,0(sp)
    80000918:	6121                	add	sp,sp,64
    8000091a:	8082                	ret
    8000091c:	8082                	ret

000000008000091e <uartputc>:
{
    8000091e:	7179                	add	sp,sp,-48
    80000920:	f406                	sd	ra,40(sp)
    80000922:	f022                	sd	s0,32(sp)
    80000924:	ec26                	sd	s1,24(sp)
    80000926:	e84a                	sd	s2,16(sp)
    80000928:	e44e                	sd	s3,8(sp)
    8000092a:	e052                	sd	s4,0(sp)
    8000092c:	1800                	add	s0,sp,48
    8000092e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000930:	00010517          	auipc	a0,0x10
    80000934:	1b850513          	add	a0,a0,440 # 80010ae8 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	300080e7          	jalr	768(ra) # 80000c38 <acquire>
  if(panicked){
    80000940:	00008797          	auipc	a5,0x8
    80000944:	f607a783          	lw	a5,-160(a5) # 800088a0 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	00008717          	auipc	a4,0x8
    8000094e:	f6673703          	ld	a4,-154(a4) # 800088b0 <uart_tx_w>
    80000952:	00008797          	auipc	a5,0x8
    80000956:	f567b783          	ld	a5,-170(a5) # 800088a8 <uart_tx_r>
    8000095a:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00010997          	auipc	s3,0x10
    80000962:	18a98993          	add	s3,s3,394 # 80010ae8 <uart_tx_lock>
    80000966:	00008497          	auipc	s1,0x8
    8000096a:	f4248493          	add	s1,s1,-190 # 800088a8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	00008917          	auipc	s2,0x8
    80000972:	f4290913          	add	s2,s2,-190 # 800088b0 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00002097          	auipc	ra,0x2
    80000982:	a0c080e7          	jalr	-1524(ra) # 8000238a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	add	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00010497          	auipc	s1,0x10
    80000998:	15448493          	add	s1,s1,340 # 80010ae8 <uart_tx_lock>
    8000099c:	01f77793          	and	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	add	a4,a4,1
    800009a8:	00008797          	auipc	a5,0x8
    800009ac:	f0e7b423          	sd	a4,-248(a5) # 800088b0 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	332080e7          	jalr	818(ra) # 80000cec <release>
}
    800009c2:	70a2                	ld	ra,40(sp)
    800009c4:	7402                	ld	s0,32(sp)
    800009c6:	64e2                	ld	s1,24(sp)
    800009c8:	6942                	ld	s2,16(sp)
    800009ca:	69a2                	ld	s3,8(sp)
    800009cc:	6a02                	ld	s4,0(sp)
    800009ce:	6145                	add	sp,sp,48
    800009d0:	8082                	ret
    for(;;)
    800009d2:	a001                	j	800009d2 <uartputc+0xb4>

00000000800009d4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d4:	1141                	add	sp,sp,-16
    800009d6:	e422                	sd	s0,8(sp)
    800009d8:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0795                	add	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009e0:	0007c783          	lbu	a5,0(a5)
    800009e4:	8b85                	and	a5,a5,1
    800009e6:	cb81                	beqz	a5,800009f6 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009e8:	100007b7          	lui	a5,0x10000
    800009ec:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f0:	6422                	ld	s0,8(sp)
    800009f2:	0141                	add	sp,sp,16
    800009f4:	8082                	ret
    return -1;
    800009f6:	557d                	li	a0,-1
    800009f8:	bfe5                	j	800009f0 <uartgetc+0x1c>

00000000800009fa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009fa:	1101                	add	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a04:	54fd                	li	s1,-1
    80000a06:	a029                	j	80000a10 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	8ce080e7          	jalr	-1842(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	fc4080e7          	jalr	-60(ra) # 800009d4 <uartgetc>
    if(c == -1)
    80000a18:	fe9518e3          	bne	a0,s1,80000a08 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1c:	00010497          	auipc	s1,0x10
    80000a20:	0cc48493          	add	s1,s1,204 # 80010ae8 <uart_tx_lock>
    80000a24:	8526                	mv	a0,s1
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	212080e7          	jalr	530(ra) # 80000c38 <acquire>
  uartstart();
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	e60080e7          	jalr	-416(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2b4080e7          	jalr	692(ra) # 80000cec <release>
}
    80000a40:	60e2                	ld	ra,24(sp)
    80000a42:	6442                	ld	s0,16(sp)
    80000a44:	64a2                	ld	s1,8(sp)
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret

0000000080000a4a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4a:	1101                	add	sp,sp,-32
    80000a4c:	ec06                	sd	ra,24(sp)
    80000a4e:	e822                	sd	s0,16(sp)
    80000a50:	e426                	sd	s1,8(sp)
    80000a52:	e04a                	sd	s2,0(sp)
    80000a54:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a56:	03451793          	sll	a5,a0,0x34
    80000a5a:	ebb9                	bnez	a5,80000ab0 <kfree+0x66>
    80000a5c:	84aa                	mv	s1,a0
    80000a5e:	00021797          	auipc	a5,0x21
    80000a62:	30a78793          	add	a5,a5,778 # 80021d68 <end>
    80000a66:	04f56563          	bltu	a0,a5,80000ab0 <kfree+0x66>
    80000a6a:	47c5                	li	a5,17
    80000a6c:	07ee                	sll	a5,a5,0x1b
    80000a6e:	04f57163          	bgeu	a0,a5,80000ab0 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a72:	6605                	lui	a2,0x1
    80000a74:	4585                	li	a1,1
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2be080e7          	jalr	702(ra) # 80000d34 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7e:	00010917          	auipc	s2,0x10
    80000a82:	0a290913          	add	s2,s2,162 # 80010b20 <kmem>
    80000a86:	854a                	mv	a0,s2
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	1b0080e7          	jalr	432(ra) # 80000c38 <acquire>
  r->next = kmem.freelist;
    80000a90:	01893783          	ld	a5,24(s2)
    80000a94:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a96:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	250080e7          	jalr	592(ra) # 80000cec <release>
}
    80000aa4:	60e2                	ld	ra,24(sp)
    80000aa6:	6442                	ld	s0,16(sp)
    80000aa8:	64a2                	ld	s1,8(sp)
    80000aaa:	6902                	ld	s2,0(sp)
    80000aac:	6105                	add	sp,sp,32
    80000aae:	8082                	ret
    panic("kfree");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	59050513          	add	a0,a0,1424 # 80008040 <etext+0x40>
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	aa8080e7          	jalr	-1368(ra) # 80000560 <panic>

0000000080000ac0 <freerange>:
{
    80000ac0:	7179                	add	sp,sp,-48
    80000ac2:	f406                	sd	ra,40(sp)
    80000ac4:	f022                	sd	s0,32(sp)
    80000ac6:	ec26                	sd	s1,24(sp)
    80000ac8:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aca:	6785                	lui	a5,0x1
    80000acc:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad0:	00e504b3          	add	s1,a0,a4
    80000ad4:	777d                	lui	a4,0xfffff
    80000ad6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad8:	94be                	add	s1,s1,a5
    80000ada:	0295e463          	bltu	a1,s1,80000b02 <freerange+0x42>
    80000ade:	e84a                	sd	s2,16(sp)
    80000ae0:	e44e                	sd	s3,8(sp)
    80000ae2:	e052                	sd	s4,0(sp)
    80000ae4:	892e                	mv	s2,a1
    kfree(p);
    80000ae6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	6985                	lui	s3,0x1
    kfree(p);
    80000aea:	01448533          	add	a0,s1,s4
    80000aee:	00000097          	auipc	ra,0x0
    80000af2:	f5c080e7          	jalr	-164(ra) # 80000a4a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af6:	94ce                	add	s1,s1,s3
    80000af8:	fe9979e3          	bgeu	s2,s1,80000aea <freerange+0x2a>
    80000afc:	6942                	ld	s2,16(sp)
    80000afe:	69a2                	ld	s3,8(sp)
    80000b00:	6a02                	ld	s4,0(sp)
}
    80000b02:	70a2                	ld	ra,40(sp)
    80000b04:	7402                	ld	s0,32(sp)
    80000b06:	64e2                	ld	s1,24(sp)
    80000b08:	6145                	add	sp,sp,48
    80000b0a:	8082                	ret

0000000080000b0c <kinit>:
{
    80000b0c:	1141                	add	sp,sp,-16
    80000b0e:	e406                	sd	ra,8(sp)
    80000b10:	e022                	sd	s0,0(sp)
    80000b12:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b14:	00007597          	auipc	a1,0x7
    80000b18:	53458593          	add	a1,a1,1332 # 80008048 <etext+0x48>
    80000b1c:	00010517          	auipc	a0,0x10
    80000b20:	00450513          	add	a0,a0,4 # 80010b20 <kmem>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	084080e7          	jalr	132(ra) # 80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	sll	a1,a1,0x1b
    80000b30:	00021517          	auipc	a0,0x21
    80000b34:	23850513          	add	a0,a0,568 # 80021d68 <end>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	f88080e7          	jalr	-120(ra) # 80000ac0 <freerange>
}
    80000b40:	60a2                	ld	ra,8(sp)
    80000b42:	6402                	ld	s0,0(sp)
    80000b44:	0141                	add	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b48:	1101                	add	sp,sp,-32
    80000b4a:	ec06                	sd	ra,24(sp)
    80000b4c:	e822                	sd	s0,16(sp)
    80000b4e:	e426                	sd	s1,8(sp)
    80000b50:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b52:	00010497          	auipc	s1,0x10
    80000b56:	fce48493          	add	s1,s1,-50 # 80010b20 <kmem>
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	0dc080e7          	jalr	220(ra) # 80000c38 <acquire>
  r = kmem.freelist;
    80000b64:	6c84                	ld	s1,24(s1)
  if(r)
    80000b66:	c885                	beqz	s1,80000b96 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b68:	609c                	ld	a5,0(s1)
    80000b6a:	00010517          	auipc	a0,0x10
    80000b6e:	fb650513          	add	a0,a0,-74 # 80010b20 <kmem>
    80000b72:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	178080e7          	jalr	376(ra) # 80000cec <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7c:	6605                	lui	a2,0x1
    80000b7e:	4595                	li	a1,5
    80000b80:	8526                	mv	a0,s1
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	1b2080e7          	jalr	434(ra) # 80000d34 <memset>
  return (void*)r;
}
    80000b8a:	8526                	mv	a0,s1
    80000b8c:	60e2                	ld	ra,24(sp)
    80000b8e:	6442                	ld	s0,16(sp)
    80000b90:	64a2                	ld	s1,8(sp)
    80000b92:	6105                	add	sp,sp,32
    80000b94:	8082                	ret
  release(&kmem.lock);
    80000b96:	00010517          	auipc	a0,0x10
    80000b9a:	f8a50513          	add	a0,a0,-118 # 80010b20 <kmem>
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	14e080e7          	jalr	334(ra) # 80000cec <release>
  if(r)
    80000ba6:	b7d5                	j	80000b8a <kalloc+0x42>

0000000080000ba8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba8:	1141                	add	sp,sp,-16
    80000baa:	e422                	sd	s0,8(sp)
    80000bac:	0800                	add	s0,sp,16
  lk->name = name;
    80000bae:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb4:	00053823          	sd	zero,16(a0)
}
    80000bb8:	6422                	ld	s0,8(sp)
    80000bba:	0141                	add	sp,sp,16
    80000bbc:	8082                	ret

0000000080000bbe <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbe:	411c                	lw	a5,0(a0)
    80000bc0:	e399                	bnez	a5,80000bc6 <holding+0x8>
    80000bc2:	4501                	li	a0,0
  return r;
}
    80000bc4:	8082                	ret
{
    80000bc6:	1101                	add	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd0:	6904                	ld	s1,16(a0)
    80000bd2:	00001097          	auipc	ra,0x1
    80000bd6:	e74080e7          	jalr	-396(ra) # 80001a46 <mycpu>
    80000bda:	40a48533          	sub	a0,s1,a0
    80000bde:	00153513          	seqz	a0,a0
}
    80000be2:	60e2                	ld	ra,24(sp)
    80000be4:	6442                	ld	s0,16(sp)
    80000be6:	64a2                	ld	s1,8(sp)
    80000be8:	6105                	add	sp,sp,32
    80000bea:	8082                	ret

0000000080000bec <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bec:	1101                	add	sp,sp,-32
    80000bee:	ec06                	sd	ra,24(sp)
    80000bf0:	e822                	sd	s0,16(sp)
    80000bf2:	e426                	sd	s1,8(sp)
    80000bf4:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf6:	100024f3          	csrr	s1,sstatus
    80000bfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfe:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c00:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c04:	00001097          	auipc	ra,0x1
    80000c08:	e42080e7          	jalr	-446(ra) # 80001a46 <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	cf89                	beqz	a5,80000c28 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	e36080e7          	jalr	-458(ra) # 80001a46 <mycpu>
    80000c18:	5d3c                	lw	a5,120(a0)
    80000c1a:	2785                	addw	a5,a5,1
    80000c1c:	dd3c                	sw	a5,120(a0)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	add	sp,sp,32
    80000c26:	8082                	ret
    mycpu()->intena = old;
    80000c28:	00001097          	auipc	ra,0x1
    80000c2c:	e1e080e7          	jalr	-482(ra) # 80001a46 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c30:	8085                	srl	s1,s1,0x1
    80000c32:	8885                	and	s1,s1,1
    80000c34:	dd64                	sw	s1,124(a0)
    80000c36:	bfe9                	j	80000c10 <push_off+0x24>

0000000080000c38 <acquire>:
{
    80000c38:	1101                	add	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	add	s0,sp,32
    80000c42:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	fa8080e7          	jalr	-88(ra) # 80000bec <push_off>
  if(holding(lk))
    80000c4c:	8526                	mv	a0,s1
    80000c4e:	00000097          	auipc	ra,0x0
    80000c52:	f70080e7          	jalr	-144(ra) # 80000bbe <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c56:	4705                	li	a4,1
  if(holding(lk))
    80000c58:	e115                	bnez	a0,80000c7c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5a:	87ba                	mv	a5,a4
    80000c5c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c60:	2781                	sext.w	a5,a5
    80000c62:	ffe5                	bnez	a5,80000c5a <acquire+0x22>
  __sync_synchronize();
    80000c64:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c68:	00001097          	auipc	ra,0x1
    80000c6c:	dde080e7          	jalr	-546(ra) # 80001a46 <mycpu>
    80000c70:	e888                	sd	a0,16(s1)
}
    80000c72:	60e2                	ld	ra,24(sp)
    80000c74:	6442                	ld	s0,16(sp)
    80000c76:	64a2                	ld	s1,8(sp)
    80000c78:	6105                	add	sp,sp,32
    80000c7a:	8082                	ret
    panic("acquire");
    80000c7c:	00007517          	auipc	a0,0x7
    80000c80:	3d450513          	add	a0,a0,980 # 80008050 <etext+0x50>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8dc080e7          	jalr	-1828(ra) # 80000560 <panic>

0000000080000c8c <pop_off>:

void
pop_off(void)
{
    80000c8c:	1141                	add	sp,sp,-16
    80000c8e:	e406                	sd	ra,8(sp)
    80000c90:	e022                	sd	s0,0(sp)
    80000c92:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c94:	00001097          	auipc	ra,0x1
    80000c98:	db2080e7          	jalr	-590(ra) # 80001a46 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca0:	8b89                	and	a5,a5,2
  if(intr_get())
    80000ca2:	e78d                	bnez	a5,80000ccc <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ca4:	5d3c                	lw	a5,120(a0)
    80000ca6:	02f05b63          	blez	a5,80000cdc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000caa:	37fd                	addw	a5,a5,-1
    80000cac:	0007871b          	sext.w	a4,a5
    80000cb0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb2:	eb09                	bnez	a4,80000cc4 <pop_off+0x38>
    80000cb4:	5d7c                	lw	a5,124(a0)
    80000cb6:	c799                	beqz	a5,80000cc4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbc:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc4:	60a2                	ld	ra,8(sp)
    80000cc6:	6402                	ld	s0,0(sp)
    80000cc8:	0141                	add	sp,sp,16
    80000cca:	8082                	ret
    panic("pop_off - interruptible");
    80000ccc:	00007517          	auipc	a0,0x7
    80000cd0:	38c50513          	add	a0,a0,908 # 80008058 <etext+0x58>
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	88c080e7          	jalr	-1908(ra) # 80000560 <panic>
    panic("pop_off");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	39450513          	add	a0,a0,916 # 80008070 <etext+0x70>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	87c080e7          	jalr	-1924(ra) # 80000560 <panic>

0000000080000cec <release>:
{
    80000cec:	1101                	add	sp,sp,-32
    80000cee:	ec06                	sd	ra,24(sp)
    80000cf0:	e822                	sd	s0,16(sp)
    80000cf2:	e426                	sd	s1,8(sp)
    80000cf4:	1000                	add	s0,sp,32
    80000cf6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	ec6080e7          	jalr	-314(ra) # 80000bbe <holding>
    80000d00:	c115                	beqz	a0,80000d24 <release+0x38>
  lk->cpu = 0;
    80000d02:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d06:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d0a:	0f50000f          	fence	iorw,ow
    80000d0e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	f7a080e7          	jalr	-134(ra) # 80000c8c <pop_off>
}
    80000d1a:	60e2                	ld	ra,24(sp)
    80000d1c:	6442                	ld	s0,16(sp)
    80000d1e:	64a2                	ld	s1,8(sp)
    80000d20:	6105                	add	sp,sp,32
    80000d22:	8082                	ret
    panic("release");
    80000d24:	00007517          	auipc	a0,0x7
    80000d28:	35450513          	add	a0,a0,852 # 80008078 <etext+0x78>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	834080e7          	jalr	-1996(ra) # 80000560 <panic>

0000000080000d34 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d34:	1141                	add	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3a:	ca19                	beqz	a2,80000d50 <memset+0x1c>
    80000d3c:	87aa                	mv	a5,a0
    80000d3e:	1602                	sll	a2,a2,0x20
    80000d40:	9201                	srl	a2,a2,0x20
    80000d42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4a:	0785                	add	a5,a5,1
    80000d4c:	fee79de3          	bne	a5,a4,80000d46 <memset+0x12>
  }
  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d56:	1141                	add	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d5c:	ca05                	beqz	a2,80000d8c <memcmp+0x36>
    80000d5e:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d62:	1682                	sll	a3,a3,0x20
    80000d64:	9281                	srl	a3,a3,0x20
    80000d66:	0685                	add	a3,a3,1
    80000d68:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d6a:	00054783          	lbu	a5,0(a0)
    80000d6e:	0005c703          	lbu	a4,0(a1)
    80000d72:	00e79863          	bne	a5,a4,80000d82 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d76:	0505                	add	a0,a0,1
    80000d78:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d7a:	fed518e3          	bne	a0,a3,80000d6a <memcmp+0x14>
  }

  return 0;
    80000d7e:	4501                	li	a0,0
    80000d80:	a019                	j	80000d86 <memcmp+0x30>
      return *s1 - *s2;
    80000d82:	40e7853b          	subw	a0,a5,a4
}
    80000d86:	6422                	ld	s0,8(sp)
    80000d88:	0141                	add	sp,sp,16
    80000d8a:	8082                	ret
  return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	bfe5                	j	80000d86 <memcmp+0x30>

0000000080000d90 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d90:	1141                	add	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d96:	c205                	beqz	a2,80000db6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d98:	02a5e263          	bltu	a1,a0,80000dbc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9c:	1602                	sll	a2,a2,0x20
    80000d9e:	9201                	srl	a2,a2,0x20
    80000da0:	00c587b3          	add	a5,a1,a2
{
    80000da4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da6:	0585                	add	a1,a1,1
    80000da8:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd299>
    80000daa:	fff5c683          	lbu	a3,-1(a1)
    80000dae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000db2:	feb79ae3          	bne	a5,a1,80000da6 <memmove+0x16>

  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	add	sp,sp,16
    80000dba:	8082                	ret
  if(s < d && s + n > d){
    80000dbc:	02061693          	sll	a3,a2,0x20
    80000dc0:	9281                	srl	a3,a3,0x20
    80000dc2:	00d58733          	add	a4,a1,a3
    80000dc6:	fce57be3          	bgeu	a0,a4,80000d9c <memmove+0xc>
    d += n;
    80000dca:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dcc:	fff6079b          	addw	a5,a2,-1
    80000dd0:	1782                	sll	a5,a5,0x20
    80000dd2:	9381                	srl	a5,a5,0x20
    80000dd4:	fff7c793          	not	a5,a5
    80000dd8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dda:	177d                	add	a4,a4,-1
    80000ddc:	16fd                	add	a3,a3,-1
    80000dde:	00074603          	lbu	a2,0(a4)
    80000de2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de6:	fef71ae3          	bne	a4,a5,80000dda <memmove+0x4a>
    80000dea:	b7f1                	j	80000db6 <memmove+0x26>

0000000080000dec <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dec:	1141                	add	sp,sp,-16
    80000dee:	e406                	sd	ra,8(sp)
    80000df0:	e022                	sd	s0,0(sp)
    80000df2:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000df4:	00000097          	auipc	ra,0x0
    80000df8:	f9c080e7          	jalr	-100(ra) # 80000d90 <memmove>
}
    80000dfc:	60a2                	ld	ra,8(sp)
    80000dfe:	6402                	ld	s0,0(sp)
    80000e00:	0141                	add	sp,sp,16
    80000e02:	8082                	ret

0000000080000e04 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e04:	1141                	add	sp,sp,-16
    80000e06:	e422                	sd	s0,8(sp)
    80000e08:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e0a:	ce11                	beqz	a2,80000e26 <strncmp+0x22>
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	cf89                	beqz	a5,80000e2a <strncmp+0x26>
    80000e12:	0005c703          	lbu	a4,0(a1)
    80000e16:	00f71a63          	bne	a4,a5,80000e2a <strncmp+0x26>
    n--, p++, q++;
    80000e1a:	367d                	addw	a2,a2,-1
    80000e1c:	0505                	add	a0,a0,1
    80000e1e:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e20:	f675                	bnez	a2,80000e0c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e22:	4501                	li	a0,0
    80000e24:	a801                	j	80000e34 <strncmp+0x30>
    80000e26:	4501                	li	a0,0
    80000e28:	a031                	j	80000e34 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e2a:	00054503          	lbu	a0,0(a0)
    80000e2e:	0005c783          	lbu	a5,0(a1)
    80000e32:	9d1d                	subw	a0,a0,a5
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	add	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e3a:	1141                	add	sp,sp,-16
    80000e3c:	e422                	sd	s0,8(sp)
    80000e3e:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e40:	87aa                	mv	a5,a0
    80000e42:	86b2                	mv	a3,a2
    80000e44:	367d                	addw	a2,a2,-1
    80000e46:	02d05563          	blez	a3,80000e70 <strncpy+0x36>
    80000e4a:	0785                	add	a5,a5,1
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	fee78fa3          	sb	a4,-1(a5)
    80000e54:	0585                	add	a1,a1,1
    80000e56:	f775                	bnez	a4,80000e42 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e58:	873e                	mv	a4,a5
    80000e5a:	9fb5                	addw	a5,a5,a3
    80000e5c:	37fd                	addw	a5,a5,-1
    80000e5e:	00c05963          	blez	a2,80000e70 <strncpy+0x36>
    *s++ = 0;
    80000e62:	0705                	add	a4,a4,1
    80000e64:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e68:	40e786bb          	subw	a3,a5,a4
    80000e6c:	fed04be3          	bgtz	a3,80000e62 <strncpy+0x28>
  return os;
}
    80000e70:	6422                	ld	s0,8(sp)
    80000e72:	0141                	add	sp,sp,16
    80000e74:	8082                	ret

0000000080000e76 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e76:	1141                	add	sp,sp,-16
    80000e78:	e422                	sd	s0,8(sp)
    80000e7a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e7c:	02c05363          	blez	a2,80000ea2 <safestrcpy+0x2c>
    80000e80:	fff6069b          	addw	a3,a2,-1
    80000e84:	1682                	sll	a3,a3,0x20
    80000e86:	9281                	srl	a3,a3,0x20
    80000e88:	96ae                	add	a3,a3,a1
    80000e8a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e8c:	00d58963          	beq	a1,a3,80000e9e <safestrcpy+0x28>
    80000e90:	0585                	add	a1,a1,1
    80000e92:	0785                	add	a5,a5,1
    80000e94:	fff5c703          	lbu	a4,-1(a1)
    80000e98:	fee78fa3          	sb	a4,-1(a5)
    80000e9c:	fb65                	bnez	a4,80000e8c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e9e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ea2:	6422                	ld	s0,8(sp)
    80000ea4:	0141                	add	sp,sp,16
    80000ea6:	8082                	ret

0000000080000ea8 <strlen>:

int
strlen(const char *s)
{
    80000ea8:	1141                	add	sp,sp,-16
    80000eaa:	e422                	sd	s0,8(sp)
    80000eac:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eae:	00054783          	lbu	a5,0(a0)
    80000eb2:	cf91                	beqz	a5,80000ece <strlen+0x26>
    80000eb4:	0505                	add	a0,a0,1
    80000eb6:	87aa                	mv	a5,a0
    80000eb8:	86be                	mv	a3,a5
    80000eba:	0785                	add	a5,a5,1
    80000ebc:	fff7c703          	lbu	a4,-1(a5)
    80000ec0:	ff65                	bnez	a4,80000eb8 <strlen+0x10>
    80000ec2:	40a6853b          	subw	a0,a3,a0
    80000ec6:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	add	sp,sp,16
    80000ecc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ece:	4501                	li	a0,0
    80000ed0:	bfe5                	j	80000ec8 <strlen+0x20>

0000000080000ed2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ed2:	1141                	add	sp,sp,-16
    80000ed4:	e406                	sd	ra,8(sp)
    80000ed6:	e022                	sd	s0,0(sp)
    80000ed8:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	b5c080e7          	jalr	-1188(ra) # 80001a36 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee2:	00008717          	auipc	a4,0x8
    80000ee6:	9d670713          	add	a4,a4,-1578 # 800088b8 <started>
  if(cpuid() == 0){
    80000eea:	c139                	beqz	a0,80000f30 <main+0x5e>
    while(started == 0)
    80000eec:	431c                	lw	a5,0(a4)
    80000eee:	2781                	sext.w	a5,a5
    80000ef0:	dff5                	beqz	a5,80000eec <main+0x1a>
      ;
    __sync_synchronize();
    80000ef2:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ef6:	00001097          	auipc	ra,0x1
    80000efa:	b40080e7          	jalr	-1216(ra) # 80001a36 <cpuid>
    80000efe:	85aa                	mv	a1,a0
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	19850513          	add	a0,a0,408 # 80008098 <etext+0x98>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	6a2080e7          	jalr	1698(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	0d8080e7          	jalr	216(ra) # 80000fe8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f18:	00002097          	auipc	ra,0x2
    80000f1c:	a80080e7          	jalr	-1408(ra) # 80002998 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f20:	00005097          	auipc	ra,0x5
    80000f24:	134080e7          	jalr	308(ra) # 80006054 <plicinithart>
  }

  scheduler();        
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	2b0080e7          	jalr	688(ra) # 800021d8 <scheduler>
    consoleinit();
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	540080e7          	jalr	1344(ra) # 80000470 <consoleinit>
    printfinit();
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	87a080e7          	jalr	-1926(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f40:	00007517          	auipc	a0,0x7
    80000f44:	0d050513          	add	a0,a0,208 # 80008010 <etext+0x10>
    80000f48:	fffff097          	auipc	ra,0xfffff
    80000f4c:	662080e7          	jalr	1634(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	13050513          	add	a0,a0,304 # 80008080 <etext+0x80>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	652080e7          	jalr	1618(ra) # 800005aa <printf>
    printf("\n");
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	0b050513          	add	a0,a0,176 # 80008010 <etext+0x10>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	642080e7          	jalr	1602(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	b9c080e7          	jalr	-1124(ra) # 80000b0c <kinit>
    kvminit();       // create kernel page table
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	326080e7          	jalr	806(ra) # 8000129e <kvminit>
    kvminithart();   // turn on paging
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	068080e7          	jalr	104(ra) # 80000fe8 <kvminithart>
    procinit();      // process table
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	9d4080e7          	jalr	-1580(ra) # 8000195c <procinit>
    trapinit();      // trap vectors
    80000f90:	00002097          	auipc	ra,0x2
    80000f94:	9e0080e7          	jalr	-1568(ra) # 80002970 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	00002097          	auipc	ra,0x2
    80000f9c:	a00080e7          	jalr	-1536(ra) # 80002998 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	09a080e7          	jalr	154(ra) # 8000603a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa8:	00005097          	auipc	ra,0x5
    80000fac:	0ac080e7          	jalr	172(ra) # 80006054 <plicinithart>
    binit();         // buffer cache
    80000fb0:	00002097          	auipc	ra,0x2
    80000fb4:	17a080e7          	jalr	378(ra) # 8000312a <binit>
    iinit();         // inode table
    80000fb8:	00003097          	auipc	ra,0x3
    80000fbc:	830080e7          	jalr	-2000(ra) # 800037e8 <iinit>
    fileinit();      // file table
    80000fc0:	00003097          	auipc	ra,0x3
    80000fc4:	7e0080e7          	jalr	2016(ra) # 800047a0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	194080e7          	jalr	404(ra) # 8000615c <virtio_disk_init>
    userinit();      // first user process
    80000fd0:	00001097          	auipc	ra,0x1
    80000fd4:	dda080e7          	jalr	-550(ra) # 80001daa <userinit>
    __sync_synchronize();
    80000fd8:	0ff0000f          	fence
    started = 1;
    80000fdc:	4785                	li	a5,1
    80000fde:	00008717          	auipc	a4,0x8
    80000fe2:	8cf72d23          	sw	a5,-1830(a4) # 800088b8 <started>
    80000fe6:	b789                	j	80000f28 <main+0x56>

0000000080000fe8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fe8:	1141                	add	sp,sp,-16
    80000fea:	e422                	sd	s0,8(sp)
    80000fec:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ff2:	00008797          	auipc	a5,0x8
    80000ff6:	8ce7b783          	ld	a5,-1842(a5) # 800088c0 <kernel_pagetable>
    80000ffa:	83b1                	srl	a5,a5,0xc
    80000ffc:	577d                	li	a4,-1
    80000ffe:	177e                	sll	a4,a4,0x3f
    80001000:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001002:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001006:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000100a:	6422                	ld	s0,8(sp)
    8000100c:	0141                	add	sp,sp,16
    8000100e:	8082                	ret

0000000080001010 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001010:	7139                	add	sp,sp,-64
    80001012:	fc06                	sd	ra,56(sp)
    80001014:	f822                	sd	s0,48(sp)
    80001016:	f426                	sd	s1,40(sp)
    80001018:	f04a                	sd	s2,32(sp)
    8000101a:	ec4e                	sd	s3,24(sp)
    8000101c:	e852                	sd	s4,16(sp)
    8000101e:	e456                	sd	s5,8(sp)
    80001020:	e05a                	sd	s6,0(sp)
    80001022:	0080                	add	s0,sp,64
    80001024:	84aa                	mv	s1,a0
    80001026:	89ae                	mv	s3,a1
    80001028:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000102a:	57fd                	li	a5,-1
    8000102c:	83e9                	srl	a5,a5,0x1a
    8000102e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001030:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001032:	04b7f263          	bgeu	a5,a1,80001076 <walk+0x66>
    panic("walk");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	07a50513          	add	a0,a0,122 # 800080b0 <etext+0xb0>
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	522080e7          	jalr	1314(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001046:	060a8663          	beqz	s5,800010b2 <walk+0xa2>
    8000104a:	00000097          	auipc	ra,0x0
    8000104e:	afe080e7          	jalr	-1282(ra) # 80000b48 <kalloc>
    80001052:	84aa                	mv	s1,a0
    80001054:	c529                	beqz	a0,8000109e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001056:	6605                	lui	a2,0x1
    80001058:	4581                	li	a1,0
    8000105a:	00000097          	auipc	ra,0x0
    8000105e:	cda080e7          	jalr	-806(ra) # 80000d34 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001062:	00c4d793          	srl	a5,s1,0xc
    80001066:	07aa                	sll	a5,a5,0xa
    80001068:	0017e793          	or	a5,a5,1
    8000106c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001070:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd28f>
    80001072:	036a0063          	beq	s4,s6,80001092 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001076:	0149d933          	srl	s2,s3,s4
    8000107a:	1ff97913          	and	s2,s2,511
    8000107e:	090e                	sll	s2,s2,0x3
    80001080:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001082:	00093483          	ld	s1,0(s2)
    80001086:	0014f793          	and	a5,s1,1
    8000108a:	dfd5                	beqz	a5,80001046 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108c:	80a9                	srl	s1,s1,0xa
    8000108e:	04b2                	sll	s1,s1,0xc
    80001090:	b7c5                	j	80001070 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001092:	00c9d513          	srl	a0,s3,0xc
    80001096:	1ff57513          	and	a0,a0,511
    8000109a:	050e                	sll	a0,a0,0x3
    8000109c:	9526                	add	a0,a0,s1
}
    8000109e:	70e2                	ld	ra,56(sp)
    800010a0:	7442                	ld	s0,48(sp)
    800010a2:	74a2                	ld	s1,40(sp)
    800010a4:	7902                	ld	s2,32(sp)
    800010a6:	69e2                	ld	s3,24(sp)
    800010a8:	6a42                	ld	s4,16(sp)
    800010aa:	6aa2                	ld	s5,8(sp)
    800010ac:	6b02                	ld	s6,0(sp)
    800010ae:	6121                	add	sp,sp,64
    800010b0:	8082                	ret
        return 0;
    800010b2:	4501                	li	a0,0
    800010b4:	b7ed                	j	8000109e <walk+0x8e>

00000000800010b6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010b6:	57fd                	li	a5,-1
    800010b8:	83e9                	srl	a5,a5,0x1a
    800010ba:	00b7f463          	bgeu	a5,a1,800010c2 <walkaddr+0xc>
    return 0;
    800010be:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010c0:	8082                	ret
{
    800010c2:	1141                	add	sp,sp,-16
    800010c4:	e406                	sd	ra,8(sp)
    800010c6:	e022                	sd	s0,0(sp)
    800010c8:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ca:	4601                	li	a2,0
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	f44080e7          	jalr	-188(ra) # 80001010 <walk>
  if(pte == 0)
    800010d4:	c105                	beqz	a0,800010f4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010d6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010d8:	0117f693          	and	a3,a5,17
    800010dc:	4745                	li	a4,17
    return 0;
    800010de:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010e0:	00e68663          	beq	a3,a4,800010ec <walkaddr+0x36>
}
    800010e4:	60a2                	ld	ra,8(sp)
    800010e6:	6402                	ld	s0,0(sp)
    800010e8:	0141                	add	sp,sp,16
    800010ea:	8082                	ret
  pa = PTE2PA(*pte);
    800010ec:	83a9                	srl	a5,a5,0xa
    800010ee:	00c79513          	sll	a0,a5,0xc
  return pa;
    800010f2:	bfcd                	j	800010e4 <walkaddr+0x2e>
    return 0;
    800010f4:	4501                	li	a0,0
    800010f6:	b7fd                	j	800010e4 <walkaddr+0x2e>

00000000800010f8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010f8:	715d                	add	sp,sp,-80
    800010fa:	e486                	sd	ra,72(sp)
    800010fc:	e0a2                	sd	s0,64(sp)
    800010fe:	fc26                	sd	s1,56(sp)
    80001100:	f84a                	sd	s2,48(sp)
    80001102:	f44e                	sd	s3,40(sp)
    80001104:	f052                	sd	s4,32(sp)
    80001106:	ec56                	sd	s5,24(sp)
    80001108:	e85a                	sd	s6,16(sp)
    8000110a:	e45e                	sd	s7,8(sp)
    8000110c:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000110e:	c639                	beqz	a2,8000115c <mappages+0x64>
    80001110:	8aaa                	mv	s5,a0
    80001112:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001114:	777d                	lui	a4,0xfffff
    80001116:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000111a:	fff58993          	add	s3,a1,-1
    8000111e:	99b2                	add	s3,s3,a2
    80001120:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001124:	893e                	mv	s2,a5
    80001126:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000112a:	6b85                	lui	s7,0x1
    8000112c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001130:	4605                	li	a2,1
    80001132:	85ca                	mv	a1,s2
    80001134:	8556                	mv	a0,s5
    80001136:	00000097          	auipc	ra,0x0
    8000113a:	eda080e7          	jalr	-294(ra) # 80001010 <walk>
    8000113e:	cd1d                	beqz	a0,8000117c <mappages+0x84>
    if(*pte & PTE_V)
    80001140:	611c                	ld	a5,0(a0)
    80001142:	8b85                	and	a5,a5,1
    80001144:	e785                	bnez	a5,8000116c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001146:	80b1                	srl	s1,s1,0xc
    80001148:	04aa                	sll	s1,s1,0xa
    8000114a:	0164e4b3          	or	s1,s1,s6
    8000114e:	0014e493          	or	s1,s1,1
    80001152:	e104                	sd	s1,0(a0)
    if(a == last)
    80001154:	05390063          	beq	s2,s3,80001194 <mappages+0x9c>
    a += PGSIZE;
    80001158:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115a:	bfc9                	j	8000112c <mappages+0x34>
    panic("mappages: size");
    8000115c:	00007517          	auipc	a0,0x7
    80001160:	f5c50513          	add	a0,a0,-164 # 800080b8 <etext+0xb8>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3fc080e7          	jalr	1020(ra) # 80000560 <panic>
      panic("mappages: remap");
    8000116c:	00007517          	auipc	a0,0x7
    80001170:	f5c50513          	add	a0,a0,-164 # 800080c8 <etext+0xc8>
    80001174:	fffff097          	auipc	ra,0xfffff
    80001178:	3ec080e7          	jalr	1004(ra) # 80000560 <panic>
      return -1;
    8000117c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000117e:	60a6                	ld	ra,72(sp)
    80001180:	6406                	ld	s0,64(sp)
    80001182:	74e2                	ld	s1,56(sp)
    80001184:	7942                	ld	s2,48(sp)
    80001186:	79a2                	ld	s3,40(sp)
    80001188:	7a02                	ld	s4,32(sp)
    8000118a:	6ae2                	ld	s5,24(sp)
    8000118c:	6b42                	ld	s6,16(sp)
    8000118e:	6ba2                	ld	s7,8(sp)
    80001190:	6161                	add	sp,sp,80
    80001192:	8082                	ret
  return 0;
    80001194:	4501                	li	a0,0
    80001196:	b7e5                	j	8000117e <mappages+0x86>

0000000080001198 <kvmmap>:
{
    80001198:	1141                	add	sp,sp,-16
    8000119a:	e406                	sd	ra,8(sp)
    8000119c:	e022                	sd	s0,0(sp)
    8000119e:	0800                	add	s0,sp,16
    800011a0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011a2:	86b2                	mv	a3,a2
    800011a4:	863e                	mv	a2,a5
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f52080e7          	jalr	-174(ra) # 800010f8 <mappages>
    800011ae:	e509                	bnez	a0,800011b8 <kvmmap+0x20>
}
    800011b0:	60a2                	ld	ra,8(sp)
    800011b2:	6402                	ld	s0,0(sp)
    800011b4:	0141                	add	sp,sp,16
    800011b6:	8082                	ret
    panic("kvmmap");
    800011b8:	00007517          	auipc	a0,0x7
    800011bc:	f2050513          	add	a0,a0,-224 # 800080d8 <etext+0xd8>
    800011c0:	fffff097          	auipc	ra,0xfffff
    800011c4:	3a0080e7          	jalr	928(ra) # 80000560 <panic>

00000000800011c8 <kvmmake>:
{
    800011c8:	1101                	add	sp,sp,-32
    800011ca:	ec06                	sd	ra,24(sp)
    800011cc:	e822                	sd	s0,16(sp)
    800011ce:	e426                	sd	s1,8(sp)
    800011d0:	e04a                	sd	s2,0(sp)
    800011d2:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	974080e7          	jalr	-1676(ra) # 80000b48 <kalloc>
    800011dc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011de:	6605                	lui	a2,0x1
    800011e0:	4581                	li	a1,0
    800011e2:	00000097          	auipc	ra,0x0
    800011e6:	b52080e7          	jalr	-1198(ra) # 80000d34 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ea:	4719                	li	a4,6
    800011ec:	6685                	lui	a3,0x1
    800011ee:	10000637          	lui	a2,0x10000
    800011f2:	100005b7          	lui	a1,0x10000
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	fa0080e7          	jalr	-96(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	6685                	lui	a3,0x1
    80001204:	10001637          	lui	a2,0x10001
    80001208:	100015b7          	lui	a1,0x10001
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f8a080e7          	jalr	-118(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001216:	4719                	li	a4,6
    80001218:	004006b7          	lui	a3,0x400
    8000121c:	0c000637          	lui	a2,0xc000
    80001220:	0c0005b7          	lui	a1,0xc000
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f72080e7          	jalr	-142(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000122e:	00007917          	auipc	s2,0x7
    80001232:	dd290913          	add	s2,s2,-558 # 80008000 <etext>
    80001236:	4729                	li	a4,10
    80001238:	80007697          	auipc	a3,0x80007
    8000123c:	dc868693          	add	a3,a3,-568 # 8000 <_entry-0x7fff8000>
    80001240:	4605                	li	a2,1
    80001242:	067e                	sll	a2,a2,0x1f
    80001244:	85b2                	mv	a1,a2
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f50080e7          	jalr	-176(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001250:	46c5                	li	a3,17
    80001252:	06ee                	sll	a3,a3,0x1b
    80001254:	4719                	li	a4,6
    80001256:	412686b3          	sub	a3,a3,s2
    8000125a:	864a                	mv	a2,s2
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8526                	mv	a0,s1
    80001260:	00000097          	auipc	ra,0x0
    80001264:	f38080e7          	jalr	-200(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001268:	4729                	li	a4,10
    8000126a:	6685                	lui	a3,0x1
    8000126c:	00006617          	auipc	a2,0x6
    80001270:	d9460613          	add	a2,a2,-620 # 80007000 <_trampoline>
    80001274:	040005b7          	lui	a1,0x4000
    80001278:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000127a:	05b2                	sll	a1,a1,0xc
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f1a080e7          	jalr	-230(ra) # 80001198 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001286:	8526                	mv	a0,s1
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	630080e7          	jalr	1584(ra) # 800018b8 <proc_mapstacks>
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6902                	ld	s2,0(sp)
    8000129a:	6105                	add	sp,sp,32
    8000129c:	8082                	ret

000000008000129e <kvminit>:
{
    8000129e:	1141                	add	sp,sp,-16
    800012a0:	e406                	sd	ra,8(sp)
    800012a2:	e022                	sd	s0,0(sp)
    800012a4:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	f22080e7          	jalr	-222(ra) # 800011c8 <kvmmake>
    800012ae:	00007797          	auipc	a5,0x7
    800012b2:	60a7b923          	sd	a0,1554(a5) # 800088c0 <kernel_pagetable>
}
    800012b6:	60a2                	ld	ra,8(sp)
    800012b8:	6402                	ld	s0,0(sp)
    800012ba:	0141                	add	sp,sp,16
    800012bc:	8082                	ret

00000000800012be <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012be:	715d                	add	sp,sp,-80
    800012c0:	e486                	sd	ra,72(sp)
    800012c2:	e0a2                	sd	s0,64(sp)
    800012c4:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c6:	03459793          	sll	a5,a1,0x34
    800012ca:	e39d                	bnez	a5,800012f0 <uvmunmap+0x32>
    800012cc:	f84a                	sd	s2,48(sp)
    800012ce:	f44e                	sd	s3,40(sp)
    800012d0:	f052                	sd	s4,32(sp)
    800012d2:	ec56                	sd	s5,24(sp)
    800012d4:	e85a                	sd	s6,16(sp)
    800012d6:	e45e                	sd	s7,8(sp)
    800012d8:	8a2a                	mv	s4,a0
    800012da:	892e                	mv	s2,a1
    800012dc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012de:	0632                	sll	a2,a2,0xc
    800012e0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012e4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e6:	6b05                	lui	s6,0x1
    800012e8:	0935fb63          	bgeu	a1,s3,8000137e <uvmunmap+0xc0>
    800012ec:	fc26                	sd	s1,56(sp)
    800012ee:	a8a9                	j	80001348 <uvmunmap+0x8a>
    800012f0:	fc26                	sd	s1,56(sp)
    800012f2:	f84a                	sd	s2,48(sp)
    800012f4:	f44e                	sd	s3,40(sp)
    800012f6:	f052                	sd	s4,32(sp)
    800012f8:	ec56                	sd	s5,24(sp)
    800012fa:	e85a                	sd	s6,16(sp)
    800012fc:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800012fe:	00007517          	auipc	a0,0x7
    80001302:	de250513          	add	a0,a0,-542 # 800080e0 <etext+0xe0>
    80001306:	fffff097          	auipc	ra,0xfffff
    8000130a:	25a080e7          	jalr	602(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    8000130e:	00007517          	auipc	a0,0x7
    80001312:	dea50513          	add	a0,a0,-534 # 800080f8 <etext+0xf8>
    80001316:	fffff097          	auipc	ra,0xfffff
    8000131a:	24a080e7          	jalr	586(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    8000131e:	00007517          	auipc	a0,0x7
    80001322:	dea50513          	add	a0,a0,-534 # 80008108 <etext+0x108>
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	23a080e7          	jalr	570(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    8000132e:	00007517          	auipc	a0,0x7
    80001332:	df250513          	add	a0,a0,-526 # 80008120 <etext+0x120>
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	22a080e7          	jalr	554(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000133e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001342:	995a                	add	s2,s2,s6
    80001344:	03397c63          	bgeu	s2,s3,8000137c <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001348:	4601                	li	a2,0
    8000134a:	85ca                	mv	a1,s2
    8000134c:	8552                	mv	a0,s4
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	cc2080e7          	jalr	-830(ra) # 80001010 <walk>
    80001356:	84aa                	mv	s1,a0
    80001358:	d95d                	beqz	a0,8000130e <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    8000135a:	6108                	ld	a0,0(a0)
    8000135c:	00157793          	and	a5,a0,1
    80001360:	dfdd                	beqz	a5,8000131e <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001362:	3ff57793          	and	a5,a0,1023
    80001366:	fd7784e3          	beq	a5,s7,8000132e <uvmunmap+0x70>
    if(do_free){
    8000136a:	fc0a8ae3          	beqz	s5,8000133e <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000136e:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001370:	0532                	sll	a0,a0,0xc
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	6d8080e7          	jalr	1752(ra) # 80000a4a <kfree>
    8000137a:	b7d1                	j	8000133e <uvmunmap+0x80>
    8000137c:	74e2                	ld	s1,56(sp)
    8000137e:	7942                	ld	s2,48(sp)
    80001380:	79a2                	ld	s3,40(sp)
    80001382:	7a02                	ld	s4,32(sp)
    80001384:	6ae2                	ld	s5,24(sp)
    80001386:	6b42                	ld	s6,16(sp)
    80001388:	6ba2                	ld	s7,8(sp)
  }
}
    8000138a:	60a6                	ld	ra,72(sp)
    8000138c:	6406                	ld	s0,64(sp)
    8000138e:	6161                	add	sp,sp,80
    80001390:	8082                	ret

0000000080001392 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001392:	1101                	add	sp,sp,-32
    80001394:	ec06                	sd	ra,24(sp)
    80001396:	e822                	sd	s0,16(sp)
    80001398:	e426                	sd	s1,8(sp)
    8000139a:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000139c:	fffff097          	auipc	ra,0xfffff
    800013a0:	7ac080e7          	jalr	1964(ra) # 80000b48 <kalloc>
    800013a4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013a6:	c519                	beqz	a0,800013b4 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	988080e7          	jalr	-1656(ra) # 80000d34 <memset>
  return pagetable;
}
    800013b4:	8526                	mv	a0,s1
    800013b6:	60e2                	ld	ra,24(sp)
    800013b8:	6442                	ld	s0,16(sp)
    800013ba:	64a2                	ld	s1,8(sp)
    800013bc:	6105                	add	sp,sp,32
    800013be:	8082                	ret

00000000800013c0 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c0:	7179                	add	sp,sp,-48
    800013c2:	f406                	sd	ra,40(sp)
    800013c4:	f022                	sd	s0,32(sp)
    800013c6:	ec26                	sd	s1,24(sp)
    800013c8:	e84a                	sd	s2,16(sp)
    800013ca:	e44e                	sd	s3,8(sp)
    800013cc:	e052                	sd	s4,0(sp)
    800013ce:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d0:	6785                	lui	a5,0x1
    800013d2:	04f67863          	bgeu	a2,a5,80001422 <uvmfirst+0x62>
    800013d6:	8a2a                	mv	s4,a0
    800013d8:	89ae                	mv	s3,a1
    800013da:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	76c080e7          	jalr	1900(ra) # 80000b48 <kalloc>
    800013e4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013e6:	6605                	lui	a2,0x1
    800013e8:	4581                	li	a1,0
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	94a080e7          	jalr	-1718(ra) # 80000d34 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f2:	4779                	li	a4,30
    800013f4:	86ca                	mv	a3,s2
    800013f6:	6605                	lui	a2,0x1
    800013f8:	4581                	li	a1,0
    800013fa:	8552                	mv	a0,s4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	cfc080e7          	jalr	-772(ra) # 800010f8 <mappages>
  memmove(mem, src, sz);
    80001404:	8626                	mv	a2,s1
    80001406:	85ce                	mv	a1,s3
    80001408:	854a                	mv	a0,s2
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	986080e7          	jalr	-1658(ra) # 80000d90 <memmove>
}
    80001412:	70a2                	ld	ra,40(sp)
    80001414:	7402                	ld	s0,32(sp)
    80001416:	64e2                	ld	s1,24(sp)
    80001418:	6942                	ld	s2,16(sp)
    8000141a:	69a2                	ld	s3,8(sp)
    8000141c:	6a02                	ld	s4,0(sp)
    8000141e:	6145                	add	sp,sp,48
    80001420:	8082                	ret
    panic("uvmfirst: more than a page");
    80001422:	00007517          	auipc	a0,0x7
    80001426:	d1650513          	add	a0,a0,-746 # 80008138 <etext+0x138>
    8000142a:	fffff097          	auipc	ra,0xfffff
    8000142e:	136080e7          	jalr	310(ra) # 80000560 <panic>

0000000080001432 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001432:	1101                	add	sp,sp,-32
    80001434:	ec06                	sd	ra,24(sp)
    80001436:	e822                	sd	s0,16(sp)
    80001438:	e426                	sd	s1,8(sp)
    8000143a:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000143c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000143e:	00b67d63          	bgeu	a2,a1,80001458 <uvmdealloc+0x26>
    80001442:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001444:	6785                	lui	a5,0x1
    80001446:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001448:	00f60733          	add	a4,a2,a5
    8000144c:	76fd                	lui	a3,0xfffff
    8000144e:	8f75                	and	a4,a4,a3
    80001450:	97ae                	add	a5,a5,a1
    80001452:	8ff5                	and	a5,a5,a3
    80001454:	00f76863          	bltu	a4,a5,80001464 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001458:	8526                	mv	a0,s1
    8000145a:	60e2                	ld	ra,24(sp)
    8000145c:	6442                	ld	s0,16(sp)
    8000145e:	64a2                	ld	s1,8(sp)
    80001460:	6105                	add	sp,sp,32
    80001462:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001464:	8f99                	sub	a5,a5,a4
    80001466:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001468:	4685                	li	a3,1
    8000146a:	0007861b          	sext.w	a2,a5
    8000146e:	85ba                	mv	a1,a4
    80001470:	00000097          	auipc	ra,0x0
    80001474:	e4e080e7          	jalr	-434(ra) # 800012be <uvmunmap>
    80001478:	b7c5                	j	80001458 <uvmdealloc+0x26>

000000008000147a <uvmalloc>:
  if(newsz < oldsz)
    8000147a:	0ab66b63          	bltu	a2,a1,80001530 <uvmalloc+0xb6>
{
    8000147e:	7139                	add	sp,sp,-64
    80001480:	fc06                	sd	ra,56(sp)
    80001482:	f822                	sd	s0,48(sp)
    80001484:	ec4e                	sd	s3,24(sp)
    80001486:	e852                	sd	s4,16(sp)
    80001488:	e456                	sd	s5,8(sp)
    8000148a:	0080                	add	s0,sp,64
    8000148c:	8aaa                	mv	s5,a0
    8000148e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	77fd                	lui	a5,0xfffff
    80001498:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149c:	08c9fc63          	bgeu	s3,a2,80001534 <uvmalloc+0xba>
    800014a0:	f426                	sd	s1,40(sp)
    800014a2:	f04a                	sd	s2,32(sp)
    800014a4:	e05a                	sd	s6,0(sp)
    800014a6:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014a8:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	69c080e7          	jalr	1692(ra) # 80000b48 <kalloc>
    800014b4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b6:	c915                	beqz	a0,800014ea <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014b8:	6605                	lui	a2,0x1
    800014ba:	4581                	li	a1,0
    800014bc:	00000097          	auipc	ra,0x0
    800014c0:	878080e7          	jalr	-1928(ra) # 80000d34 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014c4:	875a                	mv	a4,s6
    800014c6:	86a6                	mv	a3,s1
    800014c8:	6605                	lui	a2,0x1
    800014ca:	85ca                	mv	a1,s2
    800014cc:	8556                	mv	a0,s5
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	c2a080e7          	jalr	-982(ra) # 800010f8 <mappages>
    800014d6:	ed05                	bnez	a0,8000150e <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014d8:	6785                	lui	a5,0x1
    800014da:	993e                	add	s2,s2,a5
    800014dc:	fd4968e3          	bltu	s2,s4,800014ac <uvmalloc+0x32>
  return newsz;
    800014e0:	8552                	mv	a0,s4
    800014e2:	74a2                	ld	s1,40(sp)
    800014e4:	7902                	ld	s2,32(sp)
    800014e6:	6b02                	ld	s6,0(sp)
    800014e8:	a821                	j	80001500 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800014ea:	864e                	mv	a2,s3
    800014ec:	85ca                	mv	a1,s2
    800014ee:	8556                	mv	a0,s5
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	f42080e7          	jalr	-190(ra) # 80001432 <uvmdealloc>
      return 0;
    800014f8:	4501                	li	a0,0
    800014fa:	74a2                	ld	s1,40(sp)
    800014fc:	7902                	ld	s2,32(sp)
    800014fe:	6b02                	ld	s6,0(sp)
}
    80001500:	70e2                	ld	ra,56(sp)
    80001502:	7442                	ld	s0,48(sp)
    80001504:	69e2                	ld	s3,24(sp)
    80001506:	6a42                	ld	s4,16(sp)
    80001508:	6aa2                	ld	s5,8(sp)
    8000150a:	6121                	add	sp,sp,64
    8000150c:	8082                	ret
      kfree(mem);
    8000150e:	8526                	mv	a0,s1
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	53a080e7          	jalr	1338(ra) # 80000a4a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001518:	864e                	mv	a2,s3
    8000151a:	85ca                	mv	a1,s2
    8000151c:	8556                	mv	a0,s5
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	f14080e7          	jalr	-236(ra) # 80001432 <uvmdealloc>
      return 0;
    80001526:	4501                	li	a0,0
    80001528:	74a2                	ld	s1,40(sp)
    8000152a:	7902                	ld	s2,32(sp)
    8000152c:	6b02                	ld	s6,0(sp)
    8000152e:	bfc9                	j	80001500 <uvmalloc+0x86>
    return oldsz;
    80001530:	852e                	mv	a0,a1
}
    80001532:	8082                	ret
  return newsz;
    80001534:	8532                	mv	a0,a2
    80001536:	b7e9                	j	80001500 <uvmalloc+0x86>

0000000080001538 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001538:	7179                	add	sp,sp,-48
    8000153a:	f406                	sd	ra,40(sp)
    8000153c:	f022                	sd	s0,32(sp)
    8000153e:	ec26                	sd	s1,24(sp)
    80001540:	e84a                	sd	s2,16(sp)
    80001542:	e44e                	sd	s3,8(sp)
    80001544:	e052                	sd	s4,0(sp)
    80001546:	1800                	add	s0,sp,48
    80001548:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000154a:	84aa                	mv	s1,a0
    8000154c:	6905                	lui	s2,0x1
    8000154e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001550:	4985                	li	s3,1
    80001552:	a829                	j	8000156c <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001554:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001556:	00c79513          	sll	a0,a5,0xc
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	fde080e7          	jalr	-34(ra) # 80001538 <freewalk>
      pagetable[i] = 0;
    80001562:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001566:	04a1                	add	s1,s1,8
    80001568:	03248163          	beq	s1,s2,8000158a <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000156c:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000156e:	00f7f713          	and	a4,a5,15
    80001572:	ff3701e3          	beq	a4,s3,80001554 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001576:	8b85                	and	a5,a5,1
    80001578:	d7fd                	beqz	a5,80001566 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000157a:	00007517          	auipc	a0,0x7
    8000157e:	bde50513          	add	a0,a0,-1058 # 80008158 <etext+0x158>
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	fde080e7          	jalr	-34(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    8000158a:	8552                	mv	a0,s4
    8000158c:	fffff097          	auipc	ra,0xfffff
    80001590:	4be080e7          	jalr	1214(ra) # 80000a4a <kfree>
}
    80001594:	70a2                	ld	ra,40(sp)
    80001596:	7402                	ld	s0,32(sp)
    80001598:	64e2                	ld	s1,24(sp)
    8000159a:	6942                	ld	s2,16(sp)
    8000159c:	69a2                	ld	s3,8(sp)
    8000159e:	6a02                	ld	s4,0(sp)
    800015a0:	6145                	add	sp,sp,48
    800015a2:	8082                	ret

00000000800015a4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015a4:	1101                	add	sp,sp,-32
    800015a6:	ec06                	sd	ra,24(sp)
    800015a8:	e822                	sd	s0,16(sp)
    800015aa:	e426                	sd	s1,8(sp)
    800015ac:	1000                	add	s0,sp,32
    800015ae:	84aa                	mv	s1,a0
  if(sz > 0)
    800015b0:	e999                	bnez	a1,800015c6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015b2:	8526                	mv	a0,s1
    800015b4:	00000097          	auipc	ra,0x0
    800015b8:	f84080e7          	jalr	-124(ra) # 80001538 <freewalk>
}
    800015bc:	60e2                	ld	ra,24(sp)
    800015be:	6442                	ld	s0,16(sp)
    800015c0:	64a2                	ld	s1,8(sp)
    800015c2:	6105                	add	sp,sp,32
    800015c4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015c6:	6785                	lui	a5,0x1
    800015c8:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015ca:	95be                	add	a1,a1,a5
    800015cc:	4685                	li	a3,1
    800015ce:	00c5d613          	srl	a2,a1,0xc
    800015d2:	4581                	li	a1,0
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	cea080e7          	jalr	-790(ra) # 800012be <uvmunmap>
    800015dc:	bfd9                	j	800015b2 <uvmfree+0xe>

00000000800015de <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015de:	c679                	beqz	a2,800016ac <uvmcopy+0xce>
{
    800015e0:	715d                	add	sp,sp,-80
    800015e2:	e486                	sd	ra,72(sp)
    800015e4:	e0a2                	sd	s0,64(sp)
    800015e6:	fc26                	sd	s1,56(sp)
    800015e8:	f84a                	sd	s2,48(sp)
    800015ea:	f44e                	sd	s3,40(sp)
    800015ec:	f052                	sd	s4,32(sp)
    800015ee:	ec56                	sd	s5,24(sp)
    800015f0:	e85a                	sd	s6,16(sp)
    800015f2:	e45e                	sd	s7,8(sp)
    800015f4:	0880                	add	s0,sp,80
    800015f6:	8b2a                	mv	s6,a0
    800015f8:	8aae                	mv	s5,a1
    800015fa:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015fc:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015fe:	4601                	li	a2,0
    80001600:	85ce                	mv	a1,s3
    80001602:	855a                	mv	a0,s6
    80001604:	00000097          	auipc	ra,0x0
    80001608:	a0c080e7          	jalr	-1524(ra) # 80001010 <walk>
    8000160c:	c531                	beqz	a0,80001658 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000160e:	6118                	ld	a4,0(a0)
    80001610:	00177793          	and	a5,a4,1
    80001614:	cbb1                	beqz	a5,80001668 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001616:	00a75593          	srl	a1,a4,0xa
    8000161a:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000161e:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001622:	fffff097          	auipc	ra,0xfffff
    80001626:	526080e7          	jalr	1318(ra) # 80000b48 <kalloc>
    8000162a:	892a                	mv	s2,a0
    8000162c:	c939                	beqz	a0,80001682 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162e:	6605                	lui	a2,0x1
    80001630:	85de                	mv	a1,s7
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	75e080e7          	jalr	1886(ra) # 80000d90 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000163a:	8726                	mv	a4,s1
    8000163c:	86ca                	mv	a3,s2
    8000163e:	6605                	lui	a2,0x1
    80001640:	85ce                	mv	a1,s3
    80001642:	8556                	mv	a0,s5
    80001644:	00000097          	auipc	ra,0x0
    80001648:	ab4080e7          	jalr	-1356(ra) # 800010f8 <mappages>
    8000164c:	e515                	bnez	a0,80001678 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000164e:	6785                	lui	a5,0x1
    80001650:	99be                	add	s3,s3,a5
    80001652:	fb49e6e3          	bltu	s3,s4,800015fe <uvmcopy+0x20>
    80001656:	a081                	j	80001696 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b1050513          	add	a0,a0,-1264 # 80008168 <etext+0x168>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	f00080e7          	jalr	-256(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001668:	00007517          	auipc	a0,0x7
    8000166c:	b2050513          	add	a0,a0,-1248 # 80008188 <etext+0x188>
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	ef0080e7          	jalr	-272(ra) # 80000560 <panic>
      kfree(mem);
    80001678:	854a                	mv	a0,s2
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	3d0080e7          	jalr	976(ra) # 80000a4a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001682:	4685                	li	a3,1
    80001684:	00c9d613          	srl	a2,s3,0xc
    80001688:	4581                	li	a1,0
    8000168a:	8556                	mv	a0,s5
    8000168c:	00000097          	auipc	ra,0x0
    80001690:	c32080e7          	jalr	-974(ra) # 800012be <uvmunmap>
  return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6161                	add	sp,sp,80
    800016aa:	8082                	ret
  return 0;
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret

00000000800016b0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016b0:	1141                	add	sp,sp,-16
    800016b2:	e406                	sd	ra,8(sp)
    800016b4:	e022                	sd	s0,0(sp)
    800016b6:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016b8:	4601                	li	a2,0
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	956080e7          	jalr	-1706(ra) # 80001010 <walk>
  if(pte == 0)
    800016c2:	c901                	beqz	a0,800016d2 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016c4:	611c                	ld	a5,0(a0)
    800016c6:	9bbd                	and	a5,a5,-17
    800016c8:	e11c                	sd	a5,0(a0)
}
    800016ca:	60a2                	ld	ra,8(sp)
    800016cc:	6402                	ld	s0,0(sp)
    800016ce:	0141                	add	sp,sp,16
    800016d0:	8082                	ret
    panic("uvmclear");
    800016d2:	00007517          	auipc	a0,0x7
    800016d6:	ad650513          	add	a0,a0,-1322 # 800081a8 <etext+0x1a8>
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	e86080e7          	jalr	-378(ra) # 80000560 <panic>

00000000800016e2 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	c6bd                	beqz	a3,80001750 <copyout+0x6e>
{
    800016e4:	715d                	add	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	add	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8c2e                	mv	s8,a1
    80001700:	8a32                	mv	s4,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a015                	j	8000172c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000170a:	9562                	add	a0,a0,s8
    8000170c:	0004861b          	sext.w	a2,s1
    80001710:	85d2                	mv	a1,s4
    80001712:	41250533          	sub	a0,a0,s2
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	67a080e7          	jalr	1658(ra) # 80000d90 <memmove>

    len -= n;
    8000171e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001722:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001724:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001728:	02098263          	beqz	s3,8000174c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000172c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001730:	85ca                	mv	a1,s2
    80001732:	855a                	mv	a0,s6
    80001734:	00000097          	auipc	ra,0x0
    80001738:	982080e7          	jalr	-1662(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    8000173c:	cd01                	beqz	a0,80001754 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000173e:	418904b3          	sub	s1,s2,s8
    80001742:	94d6                	add	s1,s1,s5
    if(n > len)
    80001744:	fc99f3e3          	bgeu	s3,s1,8000170a <copyout+0x28>
    80001748:	84ce                	mv	s1,s3
    8000174a:	b7c1                	j	8000170a <copyout+0x28>
  }
  return 0;
    8000174c:	4501                	li	a0,0
    8000174e:	a021                	j	80001756 <copyout+0x74>
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret
      return -1;
    80001754:	557d                	li	a0,-1
}
    80001756:	60a6                	ld	ra,72(sp)
    80001758:	6406                	ld	s0,64(sp)
    8000175a:	74e2                	ld	s1,56(sp)
    8000175c:	7942                	ld	s2,48(sp)
    8000175e:	79a2                	ld	s3,40(sp)
    80001760:	7a02                	ld	s4,32(sp)
    80001762:	6ae2                	ld	s5,24(sp)
    80001764:	6b42                	ld	s6,16(sp)
    80001766:	6ba2                	ld	s7,8(sp)
    80001768:	6c02                	ld	s8,0(sp)
    8000176a:	6161                	add	sp,sp,80
    8000176c:	8082                	ret

000000008000176e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000176e:	caa5                	beqz	a3,800017de <copyin+0x70>
{
    80001770:	715d                	add	sp,sp,-80
    80001772:	e486                	sd	ra,72(sp)
    80001774:	e0a2                	sd	s0,64(sp)
    80001776:	fc26                	sd	s1,56(sp)
    80001778:	f84a                	sd	s2,48(sp)
    8000177a:	f44e                	sd	s3,40(sp)
    8000177c:	f052                	sd	s4,32(sp)
    8000177e:	ec56                	sd	s5,24(sp)
    80001780:	e85a                	sd	s6,16(sp)
    80001782:	e45e                	sd	s7,8(sp)
    80001784:	e062                	sd	s8,0(sp)
    80001786:	0880                	add	s0,sp,80
    80001788:	8b2a                	mv	s6,a0
    8000178a:	8a2e                	mv	s4,a1
    8000178c:	8c32                	mv	s8,a2
    8000178e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001790:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001792:	6a85                	lui	s5,0x1
    80001794:	a01d                	j	800017ba <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001796:	018505b3          	add	a1,a0,s8
    8000179a:	0004861b          	sext.w	a2,s1
    8000179e:	412585b3          	sub	a1,a1,s2
    800017a2:	8552                	mv	a0,s4
    800017a4:	fffff097          	auipc	ra,0xfffff
    800017a8:	5ec080e7          	jalr	1516(ra) # 80000d90 <memmove>

    len -= n;
    800017ac:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017b0:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017b2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017b6:	02098263          	beqz	s3,800017da <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017ba:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017be:	85ca                	mv	a1,s2
    800017c0:	855a                	mv	a0,s6
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	8f4080e7          	jalr	-1804(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    800017ca:	cd01                	beqz	a0,800017e2 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017cc:	418904b3          	sub	s1,s2,s8
    800017d0:	94d6                	add	s1,s1,s5
    if(n > len)
    800017d2:	fc99f2e3          	bgeu	s3,s1,80001796 <copyin+0x28>
    800017d6:	84ce                	mv	s1,s3
    800017d8:	bf7d                	j	80001796 <copyin+0x28>
  }
  return 0;
    800017da:	4501                	li	a0,0
    800017dc:	a021                	j	800017e4 <copyin+0x76>
    800017de:	4501                	li	a0,0
}
    800017e0:	8082                	ret
      return -1;
    800017e2:	557d                	li	a0,-1
}
    800017e4:	60a6                	ld	ra,72(sp)
    800017e6:	6406                	ld	s0,64(sp)
    800017e8:	74e2                	ld	s1,56(sp)
    800017ea:	7942                	ld	s2,48(sp)
    800017ec:	79a2                	ld	s3,40(sp)
    800017ee:	7a02                	ld	s4,32(sp)
    800017f0:	6ae2                	ld	s5,24(sp)
    800017f2:	6b42                	ld	s6,16(sp)
    800017f4:	6ba2                	ld	s7,8(sp)
    800017f6:	6c02                	ld	s8,0(sp)
    800017f8:	6161                	add	sp,sp,80
    800017fa:	8082                	ret

00000000800017fc <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017fc:	cacd                	beqz	a3,800018ae <copyinstr+0xb2>
{
    800017fe:	715d                	add	sp,sp,-80
    80001800:	e486                	sd	ra,72(sp)
    80001802:	e0a2                	sd	s0,64(sp)
    80001804:	fc26                	sd	s1,56(sp)
    80001806:	f84a                	sd	s2,48(sp)
    80001808:	f44e                	sd	s3,40(sp)
    8000180a:	f052                	sd	s4,32(sp)
    8000180c:	ec56                	sd	s5,24(sp)
    8000180e:	e85a                	sd	s6,16(sp)
    80001810:	e45e                	sd	s7,8(sp)
    80001812:	0880                	add	s0,sp,80
    80001814:	8a2a                	mv	s4,a0
    80001816:	8b2e                	mv	s6,a1
    80001818:	8bb2                	mv	s7,a2
    8000181a:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000181c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000181e:	6985                	lui	s3,0x1
    80001820:	a825                	j	80001858 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001822:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001826:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001828:	37fd                	addw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000182e:	60a6                	ld	ra,72(sp)
    80001830:	6406                	ld	s0,64(sp)
    80001832:	74e2                	ld	s1,56(sp)
    80001834:	7942                	ld	s2,48(sp)
    80001836:	79a2                	ld	s3,40(sp)
    80001838:	7a02                	ld	s4,32(sp)
    8000183a:	6ae2                	ld	s5,24(sp)
    8000183c:	6b42                	ld	s6,16(sp)
    8000183e:	6ba2                	ld	s7,8(sp)
    80001840:	6161                	add	sp,sp,80
    80001842:	8082                	ret
    80001844:	fff90713          	add	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001848:	9742                	add	a4,a4,a6
      --max;
    8000184a:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000184e:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001852:	04e58663          	beq	a1,a4,8000189e <copyinstr+0xa2>
{
    80001856:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001858:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000185c:	85a6                	mv	a1,s1
    8000185e:	8552                	mv	a0,s4
    80001860:	00000097          	auipc	ra,0x0
    80001864:	856080e7          	jalr	-1962(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    80001868:	cd0d                	beqz	a0,800018a2 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    8000186a:	417486b3          	sub	a3,s1,s7
    8000186e:	96ce                	add	a3,a3,s3
    if(n > max)
    80001870:	00d97363          	bgeu	s2,a3,80001876 <copyinstr+0x7a>
    80001874:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001876:	955e                	add	a0,a0,s7
    80001878:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000187a:	c695                	beqz	a3,800018a6 <copyinstr+0xaa>
    8000187c:	87da                	mv	a5,s6
    8000187e:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001880:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001884:	96da                	add	a3,a3,s6
    80001886:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001888:	00f60733          	add	a4,a2,a5
    8000188c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd298>
    80001890:	db49                	beqz	a4,80001822 <copyinstr+0x26>
        *dst = *p;
    80001892:	00e78023          	sb	a4,0(a5)
      dst++;
    80001896:	0785                	add	a5,a5,1
    while(n > 0){
    80001898:	fed797e3          	bne	a5,a3,80001886 <copyinstr+0x8a>
    8000189c:	b765                	j	80001844 <copyinstr+0x48>
    8000189e:	4781                	li	a5,0
    800018a0:	b761                	j	80001828 <copyinstr+0x2c>
      return -1;
    800018a2:	557d                	li	a0,-1
    800018a4:	b769                	j	8000182e <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800018a6:	6b85                	lui	s7,0x1
    800018a8:	9ba6                	add	s7,s7,s1
    800018aa:	87da                	mv	a5,s6
    800018ac:	b76d                	j	80001856 <copyinstr+0x5a>
  int got_null = 0;
    800018ae:	4781                	li	a5,0
  if(got_null){
    800018b0:	37fd                	addw	a5,a5,-1
    800018b2:	0007851b          	sext.w	a0,a5
}
    800018b6:	8082                	ret

00000000800018b8 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018b8:	7139                	add	sp,sp,-64
    800018ba:	fc06                	sd	ra,56(sp)
    800018bc:	f822                	sd	s0,48(sp)
    800018be:	f426                	sd	s1,40(sp)
    800018c0:	f04a                	sd	s2,32(sp)
    800018c2:	ec4e                	sd	s3,24(sp)
    800018c4:	e852                	sd	s4,16(sp)
    800018c6:	e456                	sd	s5,8(sp)
    800018c8:	e05a                	sd	s6,0(sp)
    800018ca:	0080                	add	s0,sp,64
    800018cc:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ce:	0000f497          	auipc	s1,0xf
    800018d2:	6ba48493          	add	s1,s1,1722 # 80010f88 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018d6:	8b26                	mv	s6,s1
    800018d8:	04fa5937          	lui	s2,0x4fa5
    800018dc:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800018e0:	0932                	sll	s2,s2,0xc
    800018e2:	fa590913          	add	s2,s2,-91
    800018e6:	0932                	sll	s2,s2,0xc
    800018e8:	fa590913          	add	s2,s2,-91
    800018ec:	0932                	sll	s2,s2,0xc
    800018ee:	fa590913          	add	s2,s2,-91
    800018f2:	040009b7          	lui	s3,0x4000
    800018f6:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018f8:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fa:	00015a97          	auipc	s5,0x15
    800018fe:	08ea8a93          	add	s5,s5,142 # 80016988 <tickslock>
    char *pa = kalloc();
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	246080e7          	jalr	582(ra) # 80000b48 <kalloc>
    8000190a:	862a                	mv	a2,a0
    if(pa == 0)
    8000190c:	c121                	beqz	a0,8000194c <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    8000190e:	416485b3          	sub	a1,s1,s6
    80001912:	858d                	sra	a1,a1,0x3
    80001914:	032585b3          	mul	a1,a1,s2
    80001918:	2585                	addw	a1,a1,1
    8000191a:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000191e:	4719                	li	a4,6
    80001920:	6685                	lui	a3,0x1
    80001922:	40b985b3          	sub	a1,s3,a1
    80001926:	8552                	mv	a0,s4
    80001928:	00000097          	auipc	ra,0x0
    8000192c:	870080e7          	jalr	-1936(ra) # 80001198 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001930:	16848493          	add	s1,s1,360
    80001934:	fd5497e3          	bne	s1,s5,80001902 <proc_mapstacks+0x4a>
  }
}
    80001938:	70e2                	ld	ra,56(sp)
    8000193a:	7442                	ld	s0,48(sp)
    8000193c:	74a2                	ld	s1,40(sp)
    8000193e:	7902                	ld	s2,32(sp)
    80001940:	69e2                	ld	s3,24(sp)
    80001942:	6a42                	ld	s4,16(sp)
    80001944:	6aa2                	ld	s5,8(sp)
    80001946:	6b02                	ld	s6,0(sp)
    80001948:	6121                	add	sp,sp,64
    8000194a:	8082                	ret
      panic("kalloc");
    8000194c:	00007517          	auipc	a0,0x7
    80001950:	86c50513          	add	a0,a0,-1940 # 800081b8 <etext+0x1b8>
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	c0c080e7          	jalr	-1012(ra) # 80000560 <panic>

000000008000195c <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000195c:	7139                	add	sp,sp,-64
    8000195e:	fc06                	sd	ra,56(sp)
    80001960:	f822                	sd	s0,48(sp)
    80001962:	f426                	sd	s1,40(sp)
    80001964:	f04a                	sd	s2,32(sp)
    80001966:	ec4e                	sd	s3,24(sp)
    80001968:	e852                	sd	s4,16(sp)
    8000196a:	e456                	sd	s5,8(sp)
    8000196c:	e05a                	sd	s6,0(sp)
    8000196e:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001970:	00007597          	auipc	a1,0x7
    80001974:	85058593          	add	a1,a1,-1968 # 800081c0 <etext+0x1c0>
    80001978:	0000f517          	auipc	a0,0xf
    8000197c:	1c850513          	add	a0,a0,456 # 80010b40 <pid_lock>
    80001980:	fffff097          	auipc	ra,0xfffff
    80001984:	228080e7          	jalr	552(ra) # 80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001988:	00007597          	auipc	a1,0x7
    8000198c:	84058593          	add	a1,a1,-1984 # 800081c8 <etext+0x1c8>
    80001990:	0000f517          	auipc	a0,0xf
    80001994:	1c850513          	add	a0,a0,456 # 80010b58 <wait_lock>
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	210080e7          	jalr	528(ra) # 80000ba8 <initlock>
  initlock(&tid_lock, "next_tid"); // When the process/thread is initialized, initialize the thread id.
    800019a0:	00007597          	auipc	a1,0x7
    800019a4:	83858593          	add	a1,a1,-1992 # 800081d8 <etext+0x1d8>
    800019a8:	0000f517          	auipc	a0,0xf
    800019ac:	1c850513          	add	a0,a0,456 # 80010b70 <tid_lock>
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	1f8080e7          	jalr	504(ra) # 80000ba8 <initlock>

  for(p = proc; p < &proc[NPROC]; p++) {
    800019b8:	0000f497          	auipc	s1,0xf
    800019bc:	5d048493          	add	s1,s1,1488 # 80010f88 <proc>
      initlock(&p->lock, "proc");
    800019c0:	00007b17          	auipc	s6,0x7
    800019c4:	828b0b13          	add	s6,s6,-2008 # 800081e8 <etext+0x1e8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800019c8:	8aa6                	mv	s5,s1
    800019ca:	04fa5937          	lui	s2,0x4fa5
    800019ce:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800019d2:	0932                	sll	s2,s2,0xc
    800019d4:	fa590913          	add	s2,s2,-91
    800019d8:	0932                	sll	s2,s2,0xc
    800019da:	fa590913          	add	s2,s2,-91
    800019de:	0932                	sll	s2,s2,0xc
    800019e0:	fa590913          	add	s2,s2,-91
    800019e4:	040009b7          	lui	s3,0x4000
    800019e8:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019ea:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ec:	00015a17          	auipc	s4,0x15
    800019f0:	f9ca0a13          	add	s4,s4,-100 # 80016988 <tickslock>
      initlock(&p->lock, "proc");
    800019f4:	85da                	mv	a1,s6
    800019f6:	8526                	mv	a0,s1
    800019f8:	fffff097          	auipc	ra,0xfffff
    800019fc:	1b0080e7          	jalr	432(ra) # 80000ba8 <initlock>
      p->state = UNUSED;
    80001a00:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001a04:	415487b3          	sub	a5,s1,s5
    80001a08:	878d                	sra	a5,a5,0x3
    80001a0a:	032787b3          	mul	a5,a5,s2
    80001a0e:	2785                	addw	a5,a5,1
    80001a10:	00d7979b          	sllw	a5,a5,0xd
    80001a14:	40f987b3          	sub	a5,s3,a5
    80001a18:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a1a:	16848493          	add	s1,s1,360
    80001a1e:	fd449be3          	bne	s1,s4,800019f4 <procinit+0x98>
  }
}
    80001a22:	70e2                	ld	ra,56(sp)
    80001a24:	7442                	ld	s0,48(sp)
    80001a26:	74a2                	ld	s1,40(sp)
    80001a28:	7902                	ld	s2,32(sp)
    80001a2a:	69e2                	ld	s3,24(sp)
    80001a2c:	6a42                	ld	s4,16(sp)
    80001a2e:	6aa2                	ld	s5,8(sp)
    80001a30:	6b02                	ld	s6,0(sp)
    80001a32:	6121                	add	sp,sp,64
    80001a34:	8082                	ret

0000000080001a36 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a36:	1141                	add	sp,sp,-16
    80001a38:	e422                	sd	s0,8(sp)
    80001a3a:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a3c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a3e:	2501                	sext.w	a0,a0
    80001a40:	6422                	ld	s0,8(sp)
    80001a42:	0141                	add	sp,sp,16
    80001a44:	8082                	ret

0000000080001a46 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a46:	1141                	add	sp,sp,-16
    80001a48:	e422                	sd	s0,8(sp)
    80001a4a:	0800                	add	s0,sp,16
    80001a4c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a4e:	2781                	sext.w	a5,a5
    80001a50:	079e                	sll	a5,a5,0x7
  return c;
}
    80001a52:	0000f517          	auipc	a0,0xf
    80001a56:	13650513          	add	a0,a0,310 # 80010b88 <cpus>
    80001a5a:	953e                	add	a0,a0,a5
    80001a5c:	6422                	ld	s0,8(sp)
    80001a5e:	0141                	add	sp,sp,16
    80001a60:	8082                	ret

0000000080001a62 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a62:	1101                	add	sp,sp,-32
    80001a64:	ec06                	sd	ra,24(sp)
    80001a66:	e822                	sd	s0,16(sp)
    80001a68:	e426                	sd	s1,8(sp)
    80001a6a:	1000                	add	s0,sp,32
  push_off();
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	180080e7          	jalr	384(ra) # 80000bec <push_off>
    80001a74:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a76:	2781                	sext.w	a5,a5
    80001a78:	079e                	sll	a5,a5,0x7
    80001a7a:	0000f717          	auipc	a4,0xf
    80001a7e:	0c670713          	add	a4,a4,198 # 80010b40 <pid_lock>
    80001a82:	97ba                	add	a5,a5,a4
    80001a84:	67a4                	ld	s1,72(a5)
  pop_off();
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	206080e7          	jalr	518(ra) # 80000c8c <pop_off>
  return p;
}
    80001a8e:	8526                	mv	a0,s1
    80001a90:	60e2                	ld	ra,24(sp)
    80001a92:	6442                	ld	s0,16(sp)
    80001a94:	64a2                	ld	s1,8(sp)
    80001a96:	6105                	add	sp,sp,32
    80001a98:	8082                	ret

0000000080001a9a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a9a:	1141                	add	sp,sp,-16
    80001a9c:	e406                	sd	ra,8(sp)
    80001a9e:	e022                	sd	s0,0(sp)
    80001aa0:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001aa2:	00000097          	auipc	ra,0x0
    80001aa6:	fc0080e7          	jalr	-64(ra) # 80001a62 <myproc>
    80001aaa:	fffff097          	auipc	ra,0xfffff
    80001aae:	242080e7          	jalr	578(ra) # 80000cec <release>

  if (first) {
    80001ab2:	00007797          	auipc	a5,0x7
    80001ab6:	d9e7a783          	lw	a5,-610(a5) # 80008850 <first.1>
    80001aba:	eb89                	bnez	a5,80001acc <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001abc:	00001097          	auipc	ra,0x1
    80001ac0:	ef4080e7          	jalr	-268(ra) # 800029b0 <usertrapret>
}
    80001ac4:	60a2                	ld	ra,8(sp)
    80001ac6:	6402                	ld	s0,0(sp)
    80001ac8:	0141                	add	sp,sp,16
    80001aca:	8082                	ret
    first = 0;
    80001acc:	00007797          	auipc	a5,0x7
    80001ad0:	d807a223          	sw	zero,-636(a5) # 80008850 <first.1>
    fsinit(ROOTDEV);
    80001ad4:	4505                	li	a0,1
    80001ad6:	00002097          	auipc	ra,0x2
    80001ada:	c92080e7          	jalr	-878(ra) # 80003768 <fsinit>
    80001ade:	bff9                	j	80001abc <forkret+0x22>

0000000080001ae0 <allocpid>:
{
    80001ae0:	1101                	add	sp,sp,-32
    80001ae2:	ec06                	sd	ra,24(sp)
    80001ae4:	e822                	sd	s0,16(sp)
    80001ae6:	e426                	sd	s1,8(sp)
    80001ae8:	e04a                	sd	s2,0(sp)
    80001aea:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001aec:	0000f917          	auipc	s2,0xf
    80001af0:	05490913          	add	s2,s2,84 # 80010b40 <pid_lock>
    80001af4:	854a                	mv	a0,s2
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	142080e7          	jalr	322(ra) # 80000c38 <acquire>
  pid = nextpid;
    80001afe:	00007797          	auipc	a5,0x7
    80001b02:	d5a78793          	add	a5,a5,-678 # 80008858 <nextpid>
    80001b06:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b08:	0014871b          	addw	a4,s1,1
    80001b0c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b0e:	854a                	mv	a0,s2
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	1dc080e7          	jalr	476(ra) # 80000cec <release>
}
    80001b18:	8526                	mv	a0,s1
    80001b1a:	60e2                	ld	ra,24(sp)
    80001b1c:	6442                	ld	s0,16(sp)
    80001b1e:	64a2                	ld	s1,8(sp)
    80001b20:	6902                	ld	s2,0(sp)
    80001b22:	6105                	add	sp,sp,32
    80001b24:	8082                	ret

0000000080001b26 <alloctid>:
int alloctid() {
    80001b26:	1101                	add	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	add	s0,sp,32
  acquire(&tid_lock);
    80001b32:	0000f917          	auipc	s2,0xf
    80001b36:	03e90913          	add	s2,s2,62 # 80010b70 <tid_lock>
    80001b3a:	854a                	mv	a0,s2
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	0fc080e7          	jalr	252(ra) # 80000c38 <acquire>
  tid = next_tid;
    80001b44:	00007797          	auipc	a5,0x7
    80001b48:	d1078793          	add	a5,a5,-752 # 80008854 <next_tid>
    80001b4c:	4384                	lw	s1,0(a5)
  next_tid = next_tid + 1;
    80001b4e:	0014871b          	addw	a4,s1,1
    80001b52:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001b54:	854a                	mv	a0,s2
    80001b56:	fffff097          	auipc	ra,0xfffff
    80001b5a:	196080e7          	jalr	406(ra) # 80000cec <release>
}
    80001b5e:	8526                	mv	a0,s1
    80001b60:	60e2                	ld	ra,24(sp)
    80001b62:	6442                	ld	s0,16(sp)
    80001b64:	64a2                	ld	s1,8(sp)
    80001b66:	6902                	ld	s2,0(sp)
    80001b68:	6105                	add	sp,sp,32
    80001b6a:	8082                	ret

0000000080001b6c <proc_pagetable>:
{
    80001b6c:	1101                	add	sp,sp,-32
    80001b6e:	ec06                	sd	ra,24(sp)
    80001b70:	e822                	sd	s0,16(sp)
    80001b72:	e426                	sd	s1,8(sp)
    80001b74:	e04a                	sd	s2,0(sp)
    80001b76:	1000                	add	s0,sp,32
    80001b78:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b7a:	00000097          	auipc	ra,0x0
    80001b7e:	818080e7          	jalr	-2024(ra) # 80001392 <uvmcreate>
    80001b82:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b84:	c121                	beqz	a0,80001bc4 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b86:	4729                	li	a4,10
    80001b88:	00005697          	auipc	a3,0x5
    80001b8c:	47868693          	add	a3,a3,1144 # 80007000 <_trampoline>
    80001b90:	6605                	lui	a2,0x1
    80001b92:	040005b7          	lui	a1,0x4000
    80001b96:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b98:	05b2                	sll	a1,a1,0xc
    80001b9a:	fffff097          	auipc	ra,0xfffff
    80001b9e:	55e080e7          	jalr	1374(ra) # 800010f8 <mappages>
    80001ba2:	02054863          	bltz	a0,80001bd2 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ba6:	4719                	li	a4,6
    80001ba8:	05893683          	ld	a3,88(s2)
    80001bac:	6605                	lui	a2,0x1
    80001bae:	020005b7          	lui	a1,0x2000
    80001bb2:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bb4:	05b6                	sll	a1,a1,0xd
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	540080e7          	jalr	1344(ra) # 800010f8 <mappages>
    80001bc0:	02054163          	bltz	a0,80001be2 <proc_pagetable+0x76>
}
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6902                	ld	s2,0(sp)
    80001bce:	6105                	add	sp,sp,32
    80001bd0:	8082                	ret
    uvmfree(pagetable, 0);
    80001bd2:	4581                	li	a1,0
    80001bd4:	8526                	mv	a0,s1
    80001bd6:	00000097          	auipc	ra,0x0
    80001bda:	9ce080e7          	jalr	-1586(ra) # 800015a4 <uvmfree>
    return 0;
    80001bde:	4481                	li	s1,0
    80001be0:	b7d5                	j	80001bc4 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001be2:	4681                	li	a3,0
    80001be4:	4605                	li	a2,1
    80001be6:	040005b7          	lui	a1,0x4000
    80001bea:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bec:	05b2                	sll	a1,a1,0xc
    80001bee:	8526                	mv	a0,s1
    80001bf0:	fffff097          	auipc	ra,0xfffff
    80001bf4:	6ce080e7          	jalr	1742(ra) # 800012be <uvmunmap>
    uvmfree(pagetable, 0);
    80001bf8:	4581                	li	a1,0
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	9a8080e7          	jalr	-1624(ra) # 800015a4 <uvmfree>
    return 0;
    80001c04:	4481                	li	s1,0
    80001c06:	bf7d                	j	80001bc4 <proc_pagetable+0x58>

0000000080001c08 <proc_freepagetable>:
{
    80001c08:	1101                	add	sp,sp,-32
    80001c0a:	ec06                	sd	ra,24(sp)
    80001c0c:	e822                	sd	s0,16(sp)
    80001c0e:	e426                	sd	s1,8(sp)
    80001c10:	e04a                	sd	s2,0(sp)
    80001c12:	1000                	add	s0,sp,32
    80001c14:	84aa                	mv	s1,a0
    80001c16:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c18:	4681                	li	a3,0
    80001c1a:	4605                	li	a2,1
    80001c1c:	040005b7          	lui	a1,0x4000
    80001c20:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c22:	05b2                	sll	a1,a1,0xc
    80001c24:	fffff097          	auipc	ra,0xfffff
    80001c28:	69a080e7          	jalr	1690(ra) # 800012be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c2c:	4681                	li	a3,0
    80001c2e:	4605                	li	a2,1
    80001c30:	020005b7          	lui	a1,0x2000
    80001c34:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c36:	05b6                	sll	a1,a1,0xd
    80001c38:	8526                	mv	a0,s1
    80001c3a:	fffff097          	auipc	ra,0xfffff
    80001c3e:	684080e7          	jalr	1668(ra) # 800012be <uvmunmap>
  uvmfree(pagetable, sz);
    80001c42:	85ca                	mv	a1,s2
    80001c44:	8526                	mv	a0,s1
    80001c46:	00000097          	auipc	ra,0x0
    80001c4a:	95e080e7          	jalr	-1698(ra) # 800015a4 <uvmfree>
}
    80001c4e:	60e2                	ld	ra,24(sp)
    80001c50:	6442                	ld	s0,16(sp)
    80001c52:	64a2                	ld	s1,8(sp)
    80001c54:	6902                	ld	s2,0(sp)
    80001c56:	6105                	add	sp,sp,32
    80001c58:	8082                	ret

0000000080001c5a <freeproc>:
{
    80001c5a:	1101                	add	sp,sp,-32
    80001c5c:	ec06                	sd	ra,24(sp)
    80001c5e:	e822                	sd	s0,16(sp)
    80001c60:	e426                	sd	s1,8(sp)
    80001c62:	1000                	add	s0,sp,32
    80001c64:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c66:	6d28                	ld	a0,88(a0)
    80001c68:	c509                	beqz	a0,80001c72 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c6a:	fffff097          	auipc	ra,0xfffff
    80001c6e:	de0080e7          	jalr	-544(ra) # 80000a4a <kfree>
  p->trapframe = 0;
    80001c72:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable != 0 && p->tid != 0) {
    80001c76:	68a8                	ld	a0,80(s1)
    80001c78:	c901                	beqz	a0,80001c88 <freeproc+0x2e>
    80001c7a:	58cc                	lw	a1,52(s1)
    80001c7c:	ed9d                	bnez	a1,80001cba <freeproc+0x60>
    proc_freepagetable(p->pagetable, p->sz);
    80001c7e:	64ac                	ld	a1,72(s1)
    80001c80:	00000097          	auipc	ra,0x0
    80001c84:	f88080e7          	jalr	-120(ra) # 80001c08 <proc_freepagetable>
  p->pagetable = 0;
    80001c88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c90:	0204a823          	sw	zero,48(s1)
  p->tid = 0; // When a thread is freed, reinitialize tid
    80001c94:	0204aa23          	sw	zero,52(s1)
  p->parent = 0;
    80001c98:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c9c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ca0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ca4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ca8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001cac:	0004ac23          	sw	zero,24(s1)
}
    80001cb0:	60e2                	ld	ra,24(sp)
    80001cb2:	6442                	ld	s0,16(sp)
    80001cb4:	64a2                	ld	s1,8(sp)
    80001cb6:	6105                	add	sp,sp,32
    80001cb8:	8082                	ret
    uvmunmap(p->pagetable, TRAPFRAME - PGSIZE*(p->tid), 1, 0);
    80001cba:	00c5959b          	sllw	a1,a1,0xc
    80001cbe:	020007b7          	lui	a5,0x2000
    80001cc2:	17fd                	add	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001cc4:	07b6                	sll	a5,a5,0xd
    80001cc6:	4681                	li	a3,0
    80001cc8:	4605                	li	a2,1
    80001cca:	40b785b3          	sub	a1,a5,a1
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	5f0080e7          	jalr	1520(ra) # 800012be <uvmunmap>
    80001cd6:	bf4d                	j	80001c88 <freeproc+0x2e>

0000000080001cd8 <allocproc>:
{
    80001cd8:	1101                	add	sp,sp,-32
    80001cda:	ec06                	sd	ra,24(sp)
    80001cdc:	e822                	sd	s0,16(sp)
    80001cde:	e426                	sd	s1,8(sp)
    80001ce0:	e04a                	sd	s2,0(sp)
    80001ce2:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ce4:	0000f497          	auipc	s1,0xf
    80001ce8:	2a448493          	add	s1,s1,676 # 80010f88 <proc>
    80001cec:	00015917          	auipc	s2,0x15
    80001cf0:	c9c90913          	add	s2,s2,-868 # 80016988 <tickslock>
    acquire(&p->lock);
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	f42080e7          	jalr	-190(ra) # 80000c38 <acquire>
    if(p->state == UNUSED) {
    80001cfe:	4c9c                	lw	a5,24(s1)
    80001d00:	cf81                	beqz	a5,80001d18 <allocproc+0x40>
      release(&p->lock);
    80001d02:	8526                	mv	a0,s1
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	fe8080e7          	jalr	-24(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d0c:	16848493          	add	s1,s1,360
    80001d10:	ff2492e3          	bne	s1,s2,80001cf4 <allocproc+0x1c>
  return 0;
    80001d14:	4481                	li	s1,0
    80001d16:	a899                	j	80001d6c <allocproc+0x94>
  p->pid = allocpid();
    80001d18:	00000097          	auipc	ra,0x0
    80001d1c:	dc8080e7          	jalr	-568(ra) # 80001ae0 <allocpid>
    80001d20:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d22:	4785                	li	a5,1
    80001d24:	cc9c                	sw	a5,24(s1)
  p->tid = 0;
    80001d26:	0204aa23          	sw	zero,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d2a:	fffff097          	auipc	ra,0xfffff
    80001d2e:	e1e080e7          	jalr	-482(ra) # 80000b48 <kalloc>
    80001d32:	892a                	mv	s2,a0
    80001d34:	eca8                	sd	a0,88(s1)
    80001d36:	c131                	beqz	a0,80001d7a <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001d38:	8526                	mv	a0,s1
    80001d3a:	00000097          	auipc	ra,0x0
    80001d3e:	e32080e7          	jalr	-462(ra) # 80001b6c <proc_pagetable>
    80001d42:	892a                	mv	s2,a0
    80001d44:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d46:	c531                	beqz	a0,80001d92 <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001d48:	07000613          	li	a2,112
    80001d4c:	4581                	li	a1,0
    80001d4e:	06048513          	add	a0,s1,96
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	fe2080e7          	jalr	-30(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    80001d5a:	00000797          	auipc	a5,0x0
    80001d5e:	d4078793          	add	a5,a5,-704 # 80001a9a <forkret>
    80001d62:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d64:	60bc                	ld	a5,64(s1)
    80001d66:	6705                	lui	a4,0x1
    80001d68:	97ba                	add	a5,a5,a4
    80001d6a:	f4bc                	sd	a5,104(s1)
}
    80001d6c:	8526                	mv	a0,s1
    80001d6e:	60e2                	ld	ra,24(sp)
    80001d70:	6442                	ld	s0,16(sp)
    80001d72:	64a2                	ld	s1,8(sp)
    80001d74:	6902                	ld	s2,0(sp)
    80001d76:	6105                	add	sp,sp,32
    80001d78:	8082                	ret
    freeproc(p);
    80001d7a:	8526                	mv	a0,s1
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	ede080e7          	jalr	-290(ra) # 80001c5a <freeproc>
    release(&p->lock);
    80001d84:	8526                	mv	a0,s1
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	f66080e7          	jalr	-154(ra) # 80000cec <release>
    return 0;
    80001d8e:	84ca                	mv	s1,s2
    80001d90:	bff1                	j	80001d6c <allocproc+0x94>
    freeproc(p);
    80001d92:	8526                	mv	a0,s1
    80001d94:	00000097          	auipc	ra,0x0
    80001d98:	ec6080e7          	jalr	-314(ra) # 80001c5a <freeproc>
    release(&p->lock);
    80001d9c:	8526                	mv	a0,s1
    80001d9e:	fffff097          	auipc	ra,0xfffff
    80001da2:	f4e080e7          	jalr	-178(ra) # 80000cec <release>
    return 0;
    80001da6:	84ca                	mv	s1,s2
    80001da8:	b7d1                	j	80001d6c <allocproc+0x94>

0000000080001daa <userinit>:
{
    80001daa:	1101                	add	sp,sp,-32
    80001dac:	ec06                	sd	ra,24(sp)
    80001dae:	e822                	sd	s0,16(sp)
    80001db0:	e426                	sd	s1,8(sp)
    80001db2:	1000                	add	s0,sp,32
  p = allocproc();
    80001db4:	00000097          	auipc	ra,0x0
    80001db8:	f24080e7          	jalr	-220(ra) # 80001cd8 <allocproc>
    80001dbc:	84aa                	mv	s1,a0
  initproc = p;
    80001dbe:	00007797          	auipc	a5,0x7
    80001dc2:	b0a7b523          	sd	a0,-1270(a5) # 800088c8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001dc6:	03400613          	li	a2,52
    80001dca:	00007597          	auipc	a1,0x7
    80001dce:	a9658593          	add	a1,a1,-1386 # 80008860 <initcode>
    80001dd2:	6928                	ld	a0,80(a0)
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	5ec080e7          	jalr	1516(ra) # 800013c0 <uvmfirst>
  p->sz = PGSIZE;
    80001ddc:	6785                	lui	a5,0x1
    80001dde:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001de0:	6cb8                	ld	a4,88(s1)
    80001de2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001de6:	6cb8                	ld	a4,88(s1)
    80001de8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001dea:	4641                	li	a2,16
    80001dec:	00006597          	auipc	a1,0x6
    80001df0:	40458593          	add	a1,a1,1028 # 800081f0 <etext+0x1f0>
    80001df4:	15848513          	add	a0,s1,344
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	07e080e7          	jalr	126(ra) # 80000e76 <safestrcpy>
  p->cwd = namei("/");
    80001e00:	00006517          	auipc	a0,0x6
    80001e04:	40050513          	add	a0,a0,1024 # 80008200 <etext+0x200>
    80001e08:	00002097          	auipc	ra,0x2
    80001e0c:	3b2080e7          	jalr	946(ra) # 800041ba <namei>
    80001e10:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e14:	478d                	li	a5,3
    80001e16:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e18:	8526                	mv	a0,s1
    80001e1a:	fffff097          	auipc	ra,0xfffff
    80001e1e:	ed2080e7          	jalr	-302(ra) # 80000cec <release>
}
    80001e22:	60e2                	ld	ra,24(sp)
    80001e24:	6442                	ld	s0,16(sp)
    80001e26:	64a2                	ld	s1,8(sp)
    80001e28:	6105                	add	sp,sp,32
    80001e2a:	8082                	ret

0000000080001e2c <growproc>:
{
    80001e2c:	1101                	add	sp,sp,-32
    80001e2e:	ec06                	sd	ra,24(sp)
    80001e30:	e822                	sd	s0,16(sp)
    80001e32:	e426                	sd	s1,8(sp)
    80001e34:	e04a                	sd	s2,0(sp)
    80001e36:	1000                	add	s0,sp,32
    80001e38:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001e3a:	00000097          	auipc	ra,0x0
    80001e3e:	c28080e7          	jalr	-984(ra) # 80001a62 <myproc>
    80001e42:	84aa                	mv	s1,a0
  sz = p->sz;
    80001e44:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001e46:	01204c63          	bgtz	s2,80001e5e <growproc+0x32>
  } else if(n < 0){
    80001e4a:	02094663          	bltz	s2,80001e76 <growproc+0x4a>
  p->sz = sz;
    80001e4e:	e4ac                	sd	a1,72(s1)
  return 0;
    80001e50:	4501                	li	a0,0
}
    80001e52:	60e2                	ld	ra,24(sp)
    80001e54:	6442                	ld	s0,16(sp)
    80001e56:	64a2                	ld	s1,8(sp)
    80001e58:	6902                	ld	s2,0(sp)
    80001e5a:	6105                	add	sp,sp,32
    80001e5c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e5e:	4691                	li	a3,4
    80001e60:	00b90633          	add	a2,s2,a1
    80001e64:	6928                	ld	a0,80(a0)
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	614080e7          	jalr	1556(ra) # 8000147a <uvmalloc>
    80001e6e:	85aa                	mv	a1,a0
    80001e70:	fd79                	bnez	a0,80001e4e <growproc+0x22>
      return -1;
    80001e72:	557d                	li	a0,-1
    80001e74:	bff9                	j	80001e52 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e76:	00b90633          	add	a2,s2,a1
    80001e7a:	6928                	ld	a0,80(a0)
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	5b6080e7          	jalr	1462(ra) # 80001432 <uvmdealloc>
    80001e84:	85aa                	mv	a1,a0
    80001e86:	b7e1                	j	80001e4e <growproc+0x22>

0000000080001e88 <fork>:
{
    80001e88:	7139                	add	sp,sp,-64
    80001e8a:	fc06                	sd	ra,56(sp)
    80001e8c:	f822                	sd	s0,48(sp)
    80001e8e:	f04a                	sd	s2,32(sp)
    80001e90:	e456                	sd	s5,8(sp)
    80001e92:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e94:	00000097          	auipc	ra,0x0
    80001e98:	bce080e7          	jalr	-1074(ra) # 80001a62 <myproc>
    80001e9c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e9e:	00000097          	auipc	ra,0x0
    80001ea2:	e3a080e7          	jalr	-454(ra) # 80001cd8 <allocproc>
    80001ea6:	12050063          	beqz	a0,80001fc6 <fork+0x13e>
    80001eaa:	e852                	sd	s4,16(sp)
    80001eac:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001eae:	048ab603          	ld	a2,72(s5)
    80001eb2:	692c                	ld	a1,80(a0)
    80001eb4:	050ab503          	ld	a0,80(s5)
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	726080e7          	jalr	1830(ra) # 800015de <uvmcopy>
    80001ec0:	04054a63          	bltz	a0,80001f14 <fork+0x8c>
    80001ec4:	f426                	sd	s1,40(sp)
    80001ec6:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001ec8:	048ab783          	ld	a5,72(s5)
    80001ecc:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ed0:	058ab683          	ld	a3,88(s5)
    80001ed4:	87b6                	mv	a5,a3
    80001ed6:	058a3703          	ld	a4,88(s4)
    80001eda:	12068693          	add	a3,a3,288
    80001ede:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ee2:	6788                	ld	a0,8(a5)
    80001ee4:	6b8c                	ld	a1,16(a5)
    80001ee6:	6f90                	ld	a2,24(a5)
    80001ee8:	01073023          	sd	a6,0(a4)
    80001eec:	e708                	sd	a0,8(a4)
    80001eee:	eb0c                	sd	a1,16(a4)
    80001ef0:	ef10                	sd	a2,24(a4)
    80001ef2:	02078793          	add	a5,a5,32
    80001ef6:	02070713          	add	a4,a4,32
    80001efa:	fed792e3          	bne	a5,a3,80001ede <fork+0x56>
  np->trapframe->a0 = 0;
    80001efe:	058a3783          	ld	a5,88(s4)
    80001f02:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f06:	0d0a8493          	add	s1,s5,208
    80001f0a:	0d0a0913          	add	s2,s4,208
    80001f0e:	150a8993          	add	s3,s5,336
    80001f12:	a015                	j	80001f36 <fork+0xae>
    freeproc(np);
    80001f14:	8552                	mv	a0,s4
    80001f16:	00000097          	auipc	ra,0x0
    80001f1a:	d44080e7          	jalr	-700(ra) # 80001c5a <freeproc>
    release(&np->lock);
    80001f1e:	8552                	mv	a0,s4
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	dcc080e7          	jalr	-564(ra) # 80000cec <release>
    return -1;
    80001f28:	597d                	li	s2,-1
    80001f2a:	6a42                	ld	s4,16(sp)
    80001f2c:	a071                	j	80001fb8 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001f2e:	04a1                	add	s1,s1,8
    80001f30:	0921                	add	s2,s2,8
    80001f32:	01348b63          	beq	s1,s3,80001f48 <fork+0xc0>
    if(p->ofile[i])
    80001f36:	6088                	ld	a0,0(s1)
    80001f38:	d97d                	beqz	a0,80001f2e <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f3a:	00003097          	auipc	ra,0x3
    80001f3e:	8f8080e7          	jalr	-1800(ra) # 80004832 <filedup>
    80001f42:	00a93023          	sd	a0,0(s2)
    80001f46:	b7e5                	j	80001f2e <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001f48:	150ab503          	ld	a0,336(s5)
    80001f4c:	00002097          	auipc	ra,0x2
    80001f50:	a62080e7          	jalr	-1438(ra) # 800039ae <idup>
    80001f54:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f58:	4641                	li	a2,16
    80001f5a:	158a8593          	add	a1,s5,344
    80001f5e:	158a0513          	add	a0,s4,344
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	f14080e7          	jalr	-236(ra) # 80000e76 <safestrcpy>
  pid = np->pid;
    80001f6a:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f6e:	8552                	mv	a0,s4
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	d7c080e7          	jalr	-644(ra) # 80000cec <release>
  acquire(&wait_lock);
    80001f78:	0000f497          	auipc	s1,0xf
    80001f7c:	be048493          	add	s1,s1,-1056 # 80010b58 <wait_lock>
    80001f80:	8526                	mv	a0,s1
    80001f82:	fffff097          	auipc	ra,0xfffff
    80001f86:	cb6080e7          	jalr	-842(ra) # 80000c38 <acquire>
  np->parent = p;
    80001f8a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f8e:	8526                	mv	a0,s1
    80001f90:	fffff097          	auipc	ra,0xfffff
    80001f94:	d5c080e7          	jalr	-676(ra) # 80000cec <release>
  acquire(&np->lock);
    80001f98:	8552                	mv	a0,s4
    80001f9a:	fffff097          	auipc	ra,0xfffff
    80001f9e:	c9e080e7          	jalr	-866(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    80001fa2:	478d                	li	a5,3
    80001fa4:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001fa8:	8552                	mv	a0,s4
    80001faa:	fffff097          	auipc	ra,0xfffff
    80001fae:	d42080e7          	jalr	-702(ra) # 80000cec <release>
  return pid;
    80001fb2:	74a2                	ld	s1,40(sp)
    80001fb4:	69e2                	ld	s3,24(sp)
    80001fb6:	6a42                	ld	s4,16(sp)
}
    80001fb8:	854a                	mv	a0,s2
    80001fba:	70e2                	ld	ra,56(sp)
    80001fbc:	7442                	ld	s0,48(sp)
    80001fbe:	7902                	ld	s2,32(sp)
    80001fc0:	6aa2                	ld	s5,8(sp)
    80001fc2:	6121                	add	sp,sp,64
    80001fc4:	8082                	ret
    return -1;
    80001fc6:	597d                	li	s2,-1
    80001fc8:	bfc5                	j	80001fb8 <fork+0x130>

0000000080001fca <clone>:
int clone(void* stack) {
    80001fca:	7139                	add	sp,sp,-64
    80001fcc:	fc06                	sd	ra,56(sp)
    80001fce:	f822                	sd	s0,48(sp)
    80001fd0:	ec4e                	sd	s3,24(sp)
    80001fd2:	0080                	add	s0,sp,64
  if (stack == NULL) {
    80001fd4:	20050063          	beqz	a0,800021d4 <clone+0x20a>
    80001fd8:	f426                	sd	s1,40(sp)
    80001fda:	f04a                	sd	s2,32(sp)
    80001fdc:	e456                	sd	s5,8(sp)
    80001fde:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    80001fe0:	00000097          	auipc	ra,0x0
    80001fe4:	a82080e7          	jalr	-1406(ra) # 80001a62 <myproc>
    80001fe8:	8aaa                	mv	s5,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fea:	0000f497          	auipc	s1,0xf
    80001fee:	f9e48493          	add	s1,s1,-98 # 80010f88 <proc>
    80001ff2:	00015917          	auipc	s2,0x15
    80001ff6:	99690913          	add	s2,s2,-1642 # 80016988 <tickslock>
    acquire(&p->lock);
    80001ffa:	8526                	mv	a0,s1
    80001ffc:	fffff097          	auipc	ra,0xfffff
    80002000:	c3c080e7          	jalr	-964(ra) # 80000c38 <acquire>
    if(p->state == UNUSED) {
    80002004:	4c9c                	lw	a5,24(s1)
    80002006:	cf99                	beqz	a5,80002024 <clone+0x5a>
      release(&p->lock);
    80002008:	8526                	mv	a0,s1
    8000200a:	fffff097          	auipc	ra,0xfffff
    8000200e:	ce2080e7          	jalr	-798(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002012:	16848493          	add	s1,s1,360
    80002016:	ff2492e3          	bne	s1,s2,80001ffa <clone+0x30>
    return -1;
    8000201a:	59fd                	li	s3,-1
    8000201c:	74a2                	ld	s1,40(sp)
    8000201e:	7902                	ld	s2,32(sp)
    80002020:	6aa2                	ld	s5,8(sp)
    80002022:	a25d                	j	800021c8 <clone+0x1fe>
    80002024:	e852                	sd	s4,16(sp)
  p->pid = allocpid();
    80002026:	00000097          	auipc	ra,0x0
    8000202a:	aba080e7          	jalr	-1350(ra) # 80001ae0 <allocpid>
    8000202e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80002030:	4785                	li	a5,1
    80002032:	cc9c                	sw	a5,24(s1)
  p->tid = alloctid();
    80002034:	00000097          	auipc	ra,0x0
    80002038:	af2080e7          	jalr	-1294(ra) # 80001b26 <alloctid>
    8000203c:	d8c8                	sw	a0,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000203e:	fffff097          	auipc	ra,0xfffff
    80002042:	b0a080e7          	jalr	-1270(ra) # 80000b48 <kalloc>
    80002046:	eca8                	sd	a0,88(s1)
    80002048:	c15d                	beqz	a0,800020ee <clone+0x124>
  memset(&p->context, 0, sizeof(p->context));
    8000204a:	07000613          	li	a2,112
    8000204e:	4581                	li	a1,0
    80002050:	06048513          	add	a0,s1,96
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	ce0080e7          	jalr	-800(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    8000205c:	00000797          	auipc	a5,0x0
    80002060:	a3e78793          	add	a5,a5,-1474 # 80001a9a <forkret>
    80002064:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002066:	60bc                	ld	a5,64(s1)
    80002068:	6705                	lui	a4,0x1
    8000206a:	97ba                	add	a5,a5,a4
    8000206c:	f4bc                	sd	a5,104(s1)
  np->pagetable = p->pagetable;
    8000206e:	050ab503          	ld	a0,80(s5)
    80002072:	e8a8                	sd	a0,80(s1)
  if (mappages(np->pagetable, TRAPFRAME - (PGSIZE * np->tid), PGSIZE,
    80002074:	58cc                	lw	a1,52(s1)
    80002076:	00c5959b          	sllw	a1,a1,0xc
    8000207a:	020007b7          	lui	a5,0x2000
    8000207e:	17fd                	add	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002080:	07b6                	sll	a5,a5,0xd
    80002082:	4719                	li	a4,6
    80002084:	6cb4                	ld	a3,88(s1)
    80002086:	6605                	lui	a2,0x1
    80002088:	40b785b3          	sub	a1,a5,a1
    8000208c:	fffff097          	auipc	ra,0xfffff
    80002090:	06c080e7          	jalr	108(ra) # 800010f8 <mappages>
    80002094:	06054d63          	bltz	a0,8000210e <clone+0x144>
  np->sz = p->sz;
    80002098:	048ab783          	ld	a5,72(s5)
    8000209c:	e4bc                	sd	a5,72(s1)
  *(np->trapframe) = *(p->trapframe);
    8000209e:	058ab683          	ld	a3,88(s5)
    800020a2:	87b6                	mv	a5,a3
    800020a4:	6cb8                	ld	a4,88(s1)
    800020a6:	12068693          	add	a3,a3,288
    800020aa:	0007b803          	ld	a6,0(a5)
    800020ae:	6788                	ld	a0,8(a5)
    800020b0:	6b8c                	ld	a1,16(a5)
    800020b2:	6f90                	ld	a2,24(a5)
    800020b4:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800020b8:	e708                	sd	a0,8(a4)
    800020ba:	eb0c                	sd	a1,16(a4)
    800020bc:	ef10                	sd	a2,24(a4)
    800020be:	02078793          	add	a5,a5,32
    800020c2:	02070713          	add	a4,a4,32
    800020c6:	fed792e3          	bne	a5,a3,800020aa <clone+0xe0>
  np->trapframe->a0 = 0;
    800020ca:	6cbc                	ld	a5,88(s1)
    800020cc:	0607b823          	sd	zero,112(a5)
  np->trapframe->sp = (uint64)(stack + ptr_size);
    800020d0:	6cbc                	ld	a5,88(s1)
    800020d2:	6705                	lui	a4,0x1
    800020d4:	99ba                	add	s3,s3,a4
    800020d6:	0337b823          	sd	s3,48(a5)
  np->trapframe->a0 = 0;
    800020da:	6cbc                	ld	a5,88(s1)
    800020dc:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    800020e0:	0d0a8913          	add	s2,s5,208
    800020e4:	0d048993          	add	s3,s1,208
    800020e8:	150a8a13          	add	s4,s5,336
    800020ec:	a095                	j	80002150 <clone+0x186>
    freeproc(p);
    800020ee:	8526                	mv	a0,s1
    800020f0:	00000097          	auipc	ra,0x0
    800020f4:	b6a080e7          	jalr	-1174(ra) # 80001c5a <freeproc>
    release(&p->lock);
    800020f8:	8526                	mv	a0,s1
    800020fa:	fffff097          	auipc	ra,0xfffff
    800020fe:	bf2080e7          	jalr	-1038(ra) # 80000cec <release>
    return -1;
    80002102:	59fd                	li	s3,-1
    80002104:	74a2                	ld	s1,40(sp)
    80002106:	7902                	ld	s2,32(sp)
    80002108:	6a42                	ld	s4,16(sp)
    8000210a:	6aa2                	ld	s5,8(sp)
    8000210c:	a875                	j	800021c8 <clone+0x1fe>
    uvmunmap(np->pagetable, TRAMPOLINE, 1, 0);
    8000210e:	4681                	li	a3,0
    80002110:	4605                	li	a2,1
    80002112:	040005b7          	lui	a1,0x4000
    80002116:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002118:	05b2                	sll	a1,a1,0xc
    8000211a:	68a8                	ld	a0,80(s1)
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	1a2080e7          	jalr	418(ra) # 800012be <uvmunmap>
    uvmfree(np->pagetable, 0);
    80002124:	4581                	li	a1,0
    80002126:	68a8                	ld	a0,80(s1)
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	47c080e7          	jalr	1148(ra) # 800015a4 <uvmfree>
    return 0;
    80002130:	4981                	li	s3,0
    80002132:	74a2                	ld	s1,40(sp)
    80002134:	7902                	ld	s2,32(sp)
    80002136:	6a42                	ld	s4,16(sp)
    80002138:	6aa2                	ld	s5,8(sp)
    8000213a:	a079                	j	800021c8 <clone+0x1fe>
      np->ofile[i] = filedup(p->ofile[i]);
    8000213c:	00002097          	auipc	ra,0x2
    80002140:	6f6080e7          	jalr	1782(ra) # 80004832 <filedup>
    80002144:	00a9b023          	sd	a0,0(s3)
  for (i = 0; i < NOFILE; i++)
    80002148:	0921                	add	s2,s2,8
    8000214a:	09a1                	add	s3,s3,8
    8000214c:	01490663          	beq	s2,s4,80002158 <clone+0x18e>
    if (p->ofile[i])
    80002150:	00093503          	ld	a0,0(s2)
    80002154:	f565                	bnez	a0,8000213c <clone+0x172>
    80002156:	bfcd                	j	80002148 <clone+0x17e>
  np->cwd = idup(p->cwd);
    80002158:	150ab503          	ld	a0,336(s5)
    8000215c:	00002097          	auipc	ra,0x2
    80002160:	852080e7          	jalr	-1966(ra) # 800039ae <idup>
    80002164:	14a4b823          	sd	a0,336(s1)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002168:	4641                	li	a2,16
    8000216a:	158a8593          	add	a1,s5,344
    8000216e:	15848513          	add	a0,s1,344
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	d04080e7          	jalr	-764(ra) # 80000e76 <safestrcpy>
  tid = np->tid;
    8000217a:	0344a983          	lw	s3,52(s1)
  release(&np->lock);
    8000217e:	8526                	mv	a0,s1
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	b6c080e7          	jalr	-1172(ra) # 80000cec <release>
  acquire(&wait_lock);
    80002188:	0000f917          	auipc	s2,0xf
    8000218c:	9d090913          	add	s2,s2,-1584 # 80010b58 <wait_lock>
    80002190:	854a                	mv	a0,s2
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	aa6080e7          	jalr	-1370(ra) # 80000c38 <acquire>
  np->parent = p;
    8000219a:	0354bc23          	sd	s5,56(s1)
  release(&wait_lock);
    8000219e:	854a                	mv	a0,s2
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	b4c080e7          	jalr	-1204(ra) # 80000cec <release>
  acquire(&np->lock);
    800021a8:	8526                	mv	a0,s1
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	a8e080e7          	jalr	-1394(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    800021b2:	478d                	li	a5,3
    800021b4:	cc9c                	sw	a5,24(s1)
  release(&np->lock);
    800021b6:	8526                	mv	a0,s1
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	b34080e7          	jalr	-1228(ra) # 80000cec <release>
  return tid;
    800021c0:	74a2                	ld	s1,40(sp)
    800021c2:	7902                	ld	s2,32(sp)
    800021c4:	6a42                	ld	s4,16(sp)
    800021c6:	6aa2                	ld	s5,8(sp)
}
    800021c8:	854e                	mv	a0,s3
    800021ca:	70e2                	ld	ra,56(sp)
    800021cc:	7442                	ld	s0,48(sp)
    800021ce:	69e2                	ld	s3,24(sp)
    800021d0:	6121                	add	sp,sp,64
    800021d2:	8082                	ret
    return -1;
    800021d4:	59fd                	li	s3,-1
    800021d6:	bfcd                	j	800021c8 <clone+0x1fe>

00000000800021d8 <scheduler>:
{
    800021d8:	7139                	add	sp,sp,-64
    800021da:	fc06                	sd	ra,56(sp)
    800021dc:	f822                	sd	s0,48(sp)
    800021de:	f426                	sd	s1,40(sp)
    800021e0:	f04a                	sd	s2,32(sp)
    800021e2:	ec4e                	sd	s3,24(sp)
    800021e4:	e852                	sd	s4,16(sp)
    800021e6:	e456                	sd	s5,8(sp)
    800021e8:	e05a                	sd	s6,0(sp)
    800021ea:	0080                	add	s0,sp,64
    800021ec:	8792                	mv	a5,tp
  int id = r_tp();
    800021ee:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021f0:	00779a93          	sll	s5,a5,0x7
    800021f4:	0000f717          	auipc	a4,0xf
    800021f8:	94c70713          	add	a4,a4,-1716 # 80010b40 <pid_lock>
    800021fc:	9756                	add	a4,a4,s5
    800021fe:	04073423          	sd	zero,72(a4)
        swtch(&c->context, &p->context);
    80002202:	0000f717          	auipc	a4,0xf
    80002206:	98e70713          	add	a4,a4,-1650 # 80010b90 <cpus+0x8>
    8000220a:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    8000220c:	498d                	li	s3,3
        p->state = RUNNING;
    8000220e:	4b11                	li	s6,4
        c->proc = p;
    80002210:	079e                	sll	a5,a5,0x7
    80002212:	0000fa17          	auipc	s4,0xf
    80002216:	92ea0a13          	add	s4,s4,-1746 # 80010b40 <pid_lock>
    8000221a:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000221c:	00014917          	auipc	s2,0x14
    80002220:	76c90913          	add	s2,s2,1900 # 80016988 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002224:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002228:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000222c:	10079073          	csrw	sstatus,a5
    80002230:	0000f497          	auipc	s1,0xf
    80002234:	d5848493          	add	s1,s1,-680 # 80010f88 <proc>
    80002238:	a811                	j	8000224c <scheduler+0x74>
      release(&p->lock);
    8000223a:	8526                	mv	a0,s1
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	ab0080e7          	jalr	-1360(ra) # 80000cec <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002244:	16848493          	add	s1,s1,360
    80002248:	fd248ee3          	beq	s1,s2,80002224 <scheduler+0x4c>
      acquire(&p->lock);
    8000224c:	8526                	mv	a0,s1
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	9ea080e7          	jalr	-1558(ra) # 80000c38 <acquire>
      if(p->state == RUNNABLE) {
    80002256:	4c9c                	lw	a5,24(s1)
    80002258:	ff3791e3          	bne	a5,s3,8000223a <scheduler+0x62>
        p->state = RUNNING;
    8000225c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002260:	049a3423          	sd	s1,72(s4)
        swtch(&c->context, &p->context);
    80002264:	06048593          	add	a1,s1,96
    80002268:	8556                	mv	a0,s5
    8000226a:	00000097          	auipc	ra,0x0
    8000226e:	69c080e7          	jalr	1692(ra) # 80002906 <swtch>
        c->proc = 0;
    80002272:	040a3423          	sd	zero,72(s4)
    80002276:	b7d1                	j	8000223a <scheduler+0x62>

0000000080002278 <sched>:
{
    80002278:	7179                	add	sp,sp,-48
    8000227a:	f406                	sd	ra,40(sp)
    8000227c:	f022                	sd	s0,32(sp)
    8000227e:	ec26                	sd	s1,24(sp)
    80002280:	e84a                	sd	s2,16(sp)
    80002282:	e44e                	sd	s3,8(sp)
    80002284:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	7dc080e7          	jalr	2012(ra) # 80001a62 <myproc>
    8000228e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	92e080e7          	jalr	-1746(ra) # 80000bbe <holding>
    80002298:	c93d                	beqz	a0,8000230e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000229a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000229c:	2781                	sext.w	a5,a5
    8000229e:	079e                	sll	a5,a5,0x7
    800022a0:	0000f717          	auipc	a4,0xf
    800022a4:	8a070713          	add	a4,a4,-1888 # 80010b40 <pid_lock>
    800022a8:	97ba                	add	a5,a5,a4
    800022aa:	0c07a703          	lw	a4,192(a5)
    800022ae:	4785                	li	a5,1
    800022b0:	06f71763          	bne	a4,a5,8000231e <sched+0xa6>
  if(p->state == RUNNING)
    800022b4:	4c98                	lw	a4,24(s1)
    800022b6:	4791                	li	a5,4
    800022b8:	06f70b63          	beq	a4,a5,8000232e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022bc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022c0:	8b89                	and	a5,a5,2
  if(intr_get())
    800022c2:	efb5                	bnez	a5,8000233e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022c4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022c6:	0000f917          	auipc	s2,0xf
    800022ca:	87a90913          	add	s2,s2,-1926 # 80010b40 <pid_lock>
    800022ce:	2781                	sext.w	a5,a5
    800022d0:	079e                	sll	a5,a5,0x7
    800022d2:	97ca                	add	a5,a5,s2
    800022d4:	0c47a983          	lw	s3,196(a5)
    800022d8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800022da:	2781                	sext.w	a5,a5
    800022dc:	079e                	sll	a5,a5,0x7
    800022de:	0000f597          	auipc	a1,0xf
    800022e2:	8b258593          	add	a1,a1,-1870 # 80010b90 <cpus+0x8>
    800022e6:	95be                	add	a1,a1,a5
    800022e8:	06048513          	add	a0,s1,96
    800022ec:	00000097          	auipc	ra,0x0
    800022f0:	61a080e7          	jalr	1562(ra) # 80002906 <swtch>
    800022f4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800022f6:	2781                	sext.w	a5,a5
    800022f8:	079e                	sll	a5,a5,0x7
    800022fa:	993e                	add	s2,s2,a5
    800022fc:	0d392223          	sw	s3,196(s2)
}
    80002300:	70a2                	ld	ra,40(sp)
    80002302:	7402                	ld	s0,32(sp)
    80002304:	64e2                	ld	s1,24(sp)
    80002306:	6942                	ld	s2,16(sp)
    80002308:	69a2                	ld	s3,8(sp)
    8000230a:	6145                	add	sp,sp,48
    8000230c:	8082                	ret
    panic("sched p->lock");
    8000230e:	00006517          	auipc	a0,0x6
    80002312:	efa50513          	add	a0,a0,-262 # 80008208 <etext+0x208>
    80002316:	ffffe097          	auipc	ra,0xffffe
    8000231a:	24a080e7          	jalr	586(ra) # 80000560 <panic>
    panic("sched locks");
    8000231e:	00006517          	auipc	a0,0x6
    80002322:	efa50513          	add	a0,a0,-262 # 80008218 <etext+0x218>
    80002326:	ffffe097          	auipc	ra,0xffffe
    8000232a:	23a080e7          	jalr	570(ra) # 80000560 <panic>
    panic("sched running");
    8000232e:	00006517          	auipc	a0,0x6
    80002332:	efa50513          	add	a0,a0,-262 # 80008228 <etext+0x228>
    80002336:	ffffe097          	auipc	ra,0xffffe
    8000233a:	22a080e7          	jalr	554(ra) # 80000560 <panic>
    panic("sched interruptible");
    8000233e:	00006517          	auipc	a0,0x6
    80002342:	efa50513          	add	a0,a0,-262 # 80008238 <etext+0x238>
    80002346:	ffffe097          	auipc	ra,0xffffe
    8000234a:	21a080e7          	jalr	538(ra) # 80000560 <panic>

000000008000234e <yield>:
{
    8000234e:	1101                	add	sp,sp,-32
    80002350:	ec06                	sd	ra,24(sp)
    80002352:	e822                	sd	s0,16(sp)
    80002354:	e426                	sd	s1,8(sp)
    80002356:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	70a080e7          	jalr	1802(ra) # 80001a62 <myproc>
    80002360:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	8d6080e7          	jalr	-1834(ra) # 80000c38 <acquire>
  p->state = RUNNABLE;
    8000236a:	478d                	li	a5,3
    8000236c:	cc9c                	sw	a5,24(s1)
  sched();
    8000236e:	00000097          	auipc	ra,0x0
    80002372:	f0a080e7          	jalr	-246(ra) # 80002278 <sched>
  release(&p->lock);
    80002376:	8526                	mv	a0,s1
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	974080e7          	jalr	-1676(ra) # 80000cec <release>
}
    80002380:	60e2                	ld	ra,24(sp)
    80002382:	6442                	ld	s0,16(sp)
    80002384:	64a2                	ld	s1,8(sp)
    80002386:	6105                	add	sp,sp,32
    80002388:	8082                	ret

000000008000238a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000238a:	7179                	add	sp,sp,-48
    8000238c:	f406                	sd	ra,40(sp)
    8000238e:	f022                	sd	s0,32(sp)
    80002390:	ec26                	sd	s1,24(sp)
    80002392:	e84a                	sd	s2,16(sp)
    80002394:	e44e                	sd	s3,8(sp)
    80002396:	1800                	add	s0,sp,48
    80002398:	89aa                	mv	s3,a0
    8000239a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000239c:	fffff097          	auipc	ra,0xfffff
    800023a0:	6c6080e7          	jalr	1734(ra) # 80001a62 <myproc>
    800023a4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	892080e7          	jalr	-1902(ra) # 80000c38 <acquire>
  release(lk);
    800023ae:	854a                	mv	a0,s2
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	93c080e7          	jalr	-1732(ra) # 80000cec <release>

  // Go to sleep.
  p->chan = chan;
    800023b8:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800023bc:	4789                	li	a5,2
    800023be:	cc9c                	sw	a5,24(s1)

  sched();
    800023c0:	00000097          	auipc	ra,0x0
    800023c4:	eb8080e7          	jalr	-328(ra) # 80002278 <sched>

  // Tidy up.
  p->chan = 0;
    800023c8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800023cc:	8526                	mv	a0,s1
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	91e080e7          	jalr	-1762(ra) # 80000cec <release>
  acquire(lk);
    800023d6:	854a                	mv	a0,s2
    800023d8:	fffff097          	auipc	ra,0xfffff
    800023dc:	860080e7          	jalr	-1952(ra) # 80000c38 <acquire>
}
    800023e0:	70a2                	ld	ra,40(sp)
    800023e2:	7402                	ld	s0,32(sp)
    800023e4:	64e2                	ld	s1,24(sp)
    800023e6:	6942                	ld	s2,16(sp)
    800023e8:	69a2                	ld	s3,8(sp)
    800023ea:	6145                	add	sp,sp,48
    800023ec:	8082                	ret

00000000800023ee <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800023ee:	7139                	add	sp,sp,-64
    800023f0:	fc06                	sd	ra,56(sp)
    800023f2:	f822                	sd	s0,48(sp)
    800023f4:	f426                	sd	s1,40(sp)
    800023f6:	f04a                	sd	s2,32(sp)
    800023f8:	ec4e                	sd	s3,24(sp)
    800023fa:	e852                	sd	s4,16(sp)
    800023fc:	e456                	sd	s5,8(sp)
    800023fe:	0080                	add	s0,sp,64
    80002400:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002402:	0000f497          	auipc	s1,0xf
    80002406:	b8648493          	add	s1,s1,-1146 # 80010f88 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000240a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000240c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000240e:	00014917          	auipc	s2,0x14
    80002412:	57a90913          	add	s2,s2,1402 # 80016988 <tickslock>
    80002416:	a811                	j	8000242a <wakeup+0x3c>
      }
      release(&p->lock);
    80002418:	8526                	mv	a0,s1
    8000241a:	fffff097          	auipc	ra,0xfffff
    8000241e:	8d2080e7          	jalr	-1838(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002422:	16848493          	add	s1,s1,360
    80002426:	03248663          	beq	s1,s2,80002452 <wakeup+0x64>
    if(p != myproc()){
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	638080e7          	jalr	1592(ra) # 80001a62 <myproc>
    80002432:	fea488e3          	beq	s1,a0,80002422 <wakeup+0x34>
      acquire(&p->lock);
    80002436:	8526                	mv	a0,s1
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	800080e7          	jalr	-2048(ra) # 80000c38 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002440:	4c9c                	lw	a5,24(s1)
    80002442:	fd379be3          	bne	a5,s3,80002418 <wakeup+0x2a>
    80002446:	709c                	ld	a5,32(s1)
    80002448:	fd4798e3          	bne	a5,s4,80002418 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000244c:	0154ac23          	sw	s5,24(s1)
    80002450:	b7e1                	j	80002418 <wakeup+0x2a>
    }
  }
}
    80002452:	70e2                	ld	ra,56(sp)
    80002454:	7442                	ld	s0,48(sp)
    80002456:	74a2                	ld	s1,40(sp)
    80002458:	7902                	ld	s2,32(sp)
    8000245a:	69e2                	ld	s3,24(sp)
    8000245c:	6a42                	ld	s4,16(sp)
    8000245e:	6aa2                	ld	s5,8(sp)
    80002460:	6121                	add	sp,sp,64
    80002462:	8082                	ret

0000000080002464 <reparent>:
{
    80002464:	7179                	add	sp,sp,-48
    80002466:	f406                	sd	ra,40(sp)
    80002468:	f022                	sd	s0,32(sp)
    8000246a:	ec26                	sd	s1,24(sp)
    8000246c:	e84a                	sd	s2,16(sp)
    8000246e:	e44e                	sd	s3,8(sp)
    80002470:	e052                	sd	s4,0(sp)
    80002472:	1800                	add	s0,sp,48
    80002474:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002476:	0000f497          	auipc	s1,0xf
    8000247a:	b1248493          	add	s1,s1,-1262 # 80010f88 <proc>
      pp->parent = initproc;
    8000247e:	00006a17          	auipc	s4,0x6
    80002482:	44aa0a13          	add	s4,s4,1098 # 800088c8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002486:	00014997          	auipc	s3,0x14
    8000248a:	50298993          	add	s3,s3,1282 # 80016988 <tickslock>
    8000248e:	a029                	j	80002498 <reparent+0x34>
    80002490:	16848493          	add	s1,s1,360
    80002494:	01348d63          	beq	s1,s3,800024ae <reparent+0x4a>
    if(pp->parent == p){
    80002498:	7c9c                	ld	a5,56(s1)
    8000249a:	ff279be3          	bne	a5,s2,80002490 <reparent+0x2c>
      pp->parent = initproc;
    8000249e:	000a3503          	ld	a0,0(s4)
    800024a2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800024a4:	00000097          	auipc	ra,0x0
    800024a8:	f4a080e7          	jalr	-182(ra) # 800023ee <wakeup>
    800024ac:	b7d5                	j	80002490 <reparent+0x2c>
}
    800024ae:	70a2                	ld	ra,40(sp)
    800024b0:	7402                	ld	s0,32(sp)
    800024b2:	64e2                	ld	s1,24(sp)
    800024b4:	6942                	ld	s2,16(sp)
    800024b6:	69a2                	ld	s3,8(sp)
    800024b8:	6a02                	ld	s4,0(sp)
    800024ba:	6145                	add	sp,sp,48
    800024bc:	8082                	ret

00000000800024be <exit>:
{
    800024be:	7179                	add	sp,sp,-48
    800024c0:	f406                	sd	ra,40(sp)
    800024c2:	f022                	sd	s0,32(sp)
    800024c4:	e052                	sd	s4,0(sp)
    800024c6:	1800                	add	s0,sp,48
    800024c8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	598080e7          	jalr	1432(ra) # 80001a62 <myproc>
  if(p == initproc)
    800024d2:	00006797          	auipc	a5,0x6
    800024d6:	3f67b783          	ld	a5,1014(a5) # 800088c8 <initproc>
    800024da:	00a78d63          	beq	a5,a0,800024f4 <exit+0x36>
    800024de:	ec26                	sd	s1,24(sp)
    800024e0:	e84a                	sd	s2,16(sp)
    800024e2:	e44e                	sd	s3,8(sp)
    800024e4:	892a                	mv	s2,a0
  if (p->tid == 0) {
    800024e6:	595c                	lw	a5,52(a0)
    800024e8:	ef8d                	bnez	a5,80002522 <exit+0x64>
    800024ea:	0d050493          	add	s1,a0,208
    800024ee:	15050993          	add	s3,a0,336
    800024f2:	a02d                	j	8000251c <exit+0x5e>
    800024f4:	ec26                	sd	s1,24(sp)
    800024f6:	e84a                	sd	s2,16(sp)
    800024f8:	e44e                	sd	s3,8(sp)
    panic("init exiting");
    800024fa:	00006517          	auipc	a0,0x6
    800024fe:	d5650513          	add	a0,a0,-682 # 80008250 <etext+0x250>
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	05e080e7          	jalr	94(ra) # 80000560 <panic>
          fileclose(f);
    8000250a:	00002097          	auipc	ra,0x2
    8000250e:	37a080e7          	jalr	890(ra) # 80004884 <fileclose>
          p->ofile[fd] = 0;
    80002512:	0004b023          	sd	zero,0(s1)
    for(int fd = 0; fd < NOFILE; fd++){
    80002516:	04a1                	add	s1,s1,8
    80002518:	01348563          	beq	s1,s3,80002522 <exit+0x64>
        if(p->ofile[fd]){
    8000251c:	6088                	ld	a0,0(s1)
    8000251e:	f575                	bnez	a0,8000250a <exit+0x4c>
    80002520:	bfdd                	j	80002516 <exit+0x58>
  begin_op();
    80002522:	00002097          	auipc	ra,0x2
    80002526:	e98080e7          	jalr	-360(ra) # 800043ba <begin_op>
  iput(p->cwd);
    8000252a:	15093503          	ld	a0,336(s2)
    8000252e:	00001097          	auipc	ra,0x1
    80002532:	67c080e7          	jalr	1660(ra) # 80003baa <iput>
  end_op();
    80002536:	00002097          	auipc	ra,0x2
    8000253a:	efe080e7          	jalr	-258(ra) # 80004434 <end_op>
  p->cwd = 0;
    8000253e:	14093823          	sd	zero,336(s2)
  acquire(&wait_lock);
    80002542:	0000e517          	auipc	a0,0xe
    80002546:	61650513          	add	a0,a0,1558 # 80010b58 <wait_lock>
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	6ee080e7          	jalr	1774(ra) # 80000c38 <acquire>
  if(p->tid == 0)
    80002552:	03492783          	lw	a5,52(s2)
    80002556:	c7a9                	beqz	a5,800025a0 <exit+0xe2>
  wakeup(p->parent);
    80002558:	03893503          	ld	a0,56(s2)
    8000255c:	00000097          	auipc	ra,0x0
    80002560:	e92080e7          	jalr	-366(ra) # 800023ee <wakeup>
  acquire(&p->lock);
    80002564:	854a                	mv	a0,s2
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	6d2080e7          	jalr	1746(ra) # 80000c38 <acquire>
  p->xstate = status;
    8000256e:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    80002572:	4795                	li	a5,5
    80002574:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    80002578:	0000e517          	auipc	a0,0xe
    8000257c:	5e050513          	add	a0,a0,1504 # 80010b58 <wait_lock>
    80002580:	ffffe097          	auipc	ra,0xffffe
    80002584:	76c080e7          	jalr	1900(ra) # 80000cec <release>
  sched();
    80002588:	00000097          	auipc	ra,0x0
    8000258c:	cf0080e7          	jalr	-784(ra) # 80002278 <sched>
  panic("zombie exit");
    80002590:	00006517          	auipc	a0,0x6
    80002594:	cd050513          	add	a0,a0,-816 # 80008260 <etext+0x260>
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	fc8080e7          	jalr	-56(ra) # 80000560 <panic>
    reparent(p);
    800025a0:	854a                	mv	a0,s2
    800025a2:	00000097          	auipc	ra,0x0
    800025a6:	ec2080e7          	jalr	-318(ra) # 80002464 <reparent>
    800025aa:	b77d                	j	80002558 <exit+0x9a>

00000000800025ac <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800025ac:	7179                	add	sp,sp,-48
    800025ae:	f406                	sd	ra,40(sp)
    800025b0:	f022                	sd	s0,32(sp)
    800025b2:	ec26                	sd	s1,24(sp)
    800025b4:	e84a                	sd	s2,16(sp)
    800025b6:	e44e                	sd	s3,8(sp)
    800025b8:	1800                	add	s0,sp,48
    800025ba:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800025bc:	0000f497          	auipc	s1,0xf
    800025c0:	9cc48493          	add	s1,s1,-1588 # 80010f88 <proc>
    800025c4:	00014997          	auipc	s3,0x14
    800025c8:	3c498993          	add	s3,s3,964 # 80016988 <tickslock>
    acquire(&p->lock);
    800025cc:	8526                	mv	a0,s1
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	66a080e7          	jalr	1642(ra) # 80000c38 <acquire>
    if(p->pid == pid){
    800025d6:	589c                	lw	a5,48(s1)
    800025d8:	01278d63          	beq	a5,s2,800025f2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800025dc:	8526                	mv	a0,s1
    800025de:	ffffe097          	auipc	ra,0xffffe
    800025e2:	70e080e7          	jalr	1806(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800025e6:	16848493          	add	s1,s1,360
    800025ea:	ff3491e3          	bne	s1,s3,800025cc <kill+0x20>
  }
  return -1;
    800025ee:	557d                	li	a0,-1
    800025f0:	a829                	j	8000260a <kill+0x5e>
      p->killed = 1;
    800025f2:	4785                	li	a5,1
    800025f4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800025f6:	4c98                	lw	a4,24(s1)
    800025f8:	4789                	li	a5,2
    800025fa:	00f70f63          	beq	a4,a5,80002618 <kill+0x6c>
      release(&p->lock);
    800025fe:	8526                	mv	a0,s1
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	6ec080e7          	jalr	1772(ra) # 80000cec <release>
      return 0;
    80002608:	4501                	li	a0,0
}
    8000260a:	70a2                	ld	ra,40(sp)
    8000260c:	7402                	ld	s0,32(sp)
    8000260e:	64e2                	ld	s1,24(sp)
    80002610:	6942                	ld	s2,16(sp)
    80002612:	69a2                	ld	s3,8(sp)
    80002614:	6145                	add	sp,sp,48
    80002616:	8082                	ret
        p->state = RUNNABLE;
    80002618:	478d                	li	a5,3
    8000261a:	cc9c                	sw	a5,24(s1)
    8000261c:	b7cd                	j	800025fe <kill+0x52>

000000008000261e <setkilled>:

void
setkilled(struct proc *p)
{
    8000261e:	1101                	add	sp,sp,-32
    80002620:	ec06                	sd	ra,24(sp)
    80002622:	e822                	sd	s0,16(sp)
    80002624:	e426                	sd	s1,8(sp)
    80002626:	1000                	add	s0,sp,32
    80002628:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	60e080e7          	jalr	1550(ra) # 80000c38 <acquire>
  p->killed = 1;
    80002632:	4785                	li	a5,1
    80002634:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002636:	8526                	mv	a0,s1
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	6b4080e7          	jalr	1716(ra) # 80000cec <release>
}
    80002640:	60e2                	ld	ra,24(sp)
    80002642:	6442                	ld	s0,16(sp)
    80002644:	64a2                	ld	s1,8(sp)
    80002646:	6105                	add	sp,sp,32
    80002648:	8082                	ret

000000008000264a <killed>:

int
killed(struct proc *p)
{
    8000264a:	1101                	add	sp,sp,-32
    8000264c:	ec06                	sd	ra,24(sp)
    8000264e:	e822                	sd	s0,16(sp)
    80002650:	e426                	sd	s1,8(sp)
    80002652:	e04a                	sd	s2,0(sp)
    80002654:	1000                	add	s0,sp,32
    80002656:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002658:	ffffe097          	auipc	ra,0xffffe
    8000265c:	5e0080e7          	jalr	1504(ra) # 80000c38 <acquire>
  k = p->killed;
    80002660:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002664:	8526                	mv	a0,s1
    80002666:	ffffe097          	auipc	ra,0xffffe
    8000266a:	686080e7          	jalr	1670(ra) # 80000cec <release>
  return k;
}
    8000266e:	854a                	mv	a0,s2
    80002670:	60e2                	ld	ra,24(sp)
    80002672:	6442                	ld	s0,16(sp)
    80002674:	64a2                	ld	s1,8(sp)
    80002676:	6902                	ld	s2,0(sp)
    80002678:	6105                	add	sp,sp,32
    8000267a:	8082                	ret

000000008000267c <wait>:
{
    8000267c:	715d                	add	sp,sp,-80
    8000267e:	e486                	sd	ra,72(sp)
    80002680:	e0a2                	sd	s0,64(sp)
    80002682:	fc26                	sd	s1,56(sp)
    80002684:	f84a                	sd	s2,48(sp)
    80002686:	f44e                	sd	s3,40(sp)
    80002688:	f052                	sd	s4,32(sp)
    8000268a:	ec56                	sd	s5,24(sp)
    8000268c:	e85a                	sd	s6,16(sp)
    8000268e:	e45e                	sd	s7,8(sp)
    80002690:	e062                	sd	s8,0(sp)
    80002692:	0880                	add	s0,sp,80
    80002694:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002696:	fffff097          	auipc	ra,0xfffff
    8000269a:	3cc080e7          	jalr	972(ra) # 80001a62 <myproc>
    8000269e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800026a0:	0000e517          	auipc	a0,0xe
    800026a4:	4b850513          	add	a0,a0,1208 # 80010b58 <wait_lock>
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	590080e7          	jalr	1424(ra) # 80000c38 <acquire>
    havekids = 0;
    800026b0:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800026b2:	4a15                	li	s4,5
        havekids = 1;
    800026b4:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800026b6:	00014997          	auipc	s3,0x14
    800026ba:	2d298993          	add	s3,s3,722 # 80016988 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026be:	0000ec17          	auipc	s8,0xe
    800026c2:	49ac0c13          	add	s8,s8,1178 # 80010b58 <wait_lock>
    800026c6:	a0d1                	j	8000278a <wait+0x10e>
          pid = pp->pid;
    800026c8:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026cc:	000b0e63          	beqz	s6,800026e8 <wait+0x6c>
    800026d0:	4691                	li	a3,4
    800026d2:	02c48613          	add	a2,s1,44
    800026d6:	85da                	mv	a1,s6
    800026d8:	05093503          	ld	a0,80(s2)
    800026dc:	fffff097          	auipc	ra,0xfffff
    800026e0:	006080e7          	jalr	6(ra) # 800016e2 <copyout>
    800026e4:	04054163          	bltz	a0,80002726 <wait+0xaa>
          freeproc(pp);
    800026e8:	8526                	mv	a0,s1
    800026ea:	fffff097          	auipc	ra,0xfffff
    800026ee:	570080e7          	jalr	1392(ra) # 80001c5a <freeproc>
          release(&pp->lock);
    800026f2:	8526                	mv	a0,s1
    800026f4:	ffffe097          	auipc	ra,0xffffe
    800026f8:	5f8080e7          	jalr	1528(ra) # 80000cec <release>
          release(&wait_lock);
    800026fc:	0000e517          	auipc	a0,0xe
    80002700:	45c50513          	add	a0,a0,1116 # 80010b58 <wait_lock>
    80002704:	ffffe097          	auipc	ra,0xffffe
    80002708:	5e8080e7          	jalr	1512(ra) # 80000cec <release>
}
    8000270c:	854e                	mv	a0,s3
    8000270e:	60a6                	ld	ra,72(sp)
    80002710:	6406                	ld	s0,64(sp)
    80002712:	74e2                	ld	s1,56(sp)
    80002714:	7942                	ld	s2,48(sp)
    80002716:	79a2                	ld	s3,40(sp)
    80002718:	7a02                	ld	s4,32(sp)
    8000271a:	6ae2                	ld	s5,24(sp)
    8000271c:	6b42                	ld	s6,16(sp)
    8000271e:	6ba2                	ld	s7,8(sp)
    80002720:	6c02                	ld	s8,0(sp)
    80002722:	6161                	add	sp,sp,80
    80002724:	8082                	ret
            release(&pp->lock);
    80002726:	8526                	mv	a0,s1
    80002728:	ffffe097          	auipc	ra,0xffffe
    8000272c:	5c4080e7          	jalr	1476(ra) # 80000cec <release>
            release(&wait_lock);
    80002730:	0000e517          	auipc	a0,0xe
    80002734:	42850513          	add	a0,a0,1064 # 80010b58 <wait_lock>
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	5b4080e7          	jalr	1460(ra) # 80000cec <release>
            return -1;
    80002740:	59fd                	li	s3,-1
    80002742:	b7e9                	j	8000270c <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002744:	16848493          	add	s1,s1,360
    80002748:	03348463          	beq	s1,s3,80002770 <wait+0xf4>
      if(pp->parent == p){
    8000274c:	7c9c                	ld	a5,56(s1)
    8000274e:	ff279be3          	bne	a5,s2,80002744 <wait+0xc8>
        acquire(&pp->lock);
    80002752:	8526                	mv	a0,s1
    80002754:	ffffe097          	auipc	ra,0xffffe
    80002758:	4e4080e7          	jalr	1252(ra) # 80000c38 <acquire>
        if(pp->state == ZOMBIE){
    8000275c:	4c9c                	lw	a5,24(s1)
    8000275e:	f74785e3          	beq	a5,s4,800026c8 <wait+0x4c>
        release(&pp->lock);
    80002762:	8526                	mv	a0,s1
    80002764:	ffffe097          	auipc	ra,0xffffe
    80002768:	588080e7          	jalr	1416(ra) # 80000cec <release>
        havekids = 1;
    8000276c:	8756                	mv	a4,s5
    8000276e:	bfd9                	j	80002744 <wait+0xc8>
    if(!havekids || killed(p)){
    80002770:	c31d                	beqz	a4,80002796 <wait+0x11a>
    80002772:	854a                	mv	a0,s2
    80002774:	00000097          	auipc	ra,0x0
    80002778:	ed6080e7          	jalr	-298(ra) # 8000264a <killed>
    8000277c:	ed09                	bnez	a0,80002796 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000277e:	85e2                	mv	a1,s8
    80002780:	854a                	mv	a0,s2
    80002782:	00000097          	auipc	ra,0x0
    80002786:	c08080e7          	jalr	-1016(ra) # 8000238a <sleep>
    havekids = 0;
    8000278a:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000278c:	0000e497          	auipc	s1,0xe
    80002790:	7fc48493          	add	s1,s1,2044 # 80010f88 <proc>
    80002794:	bf65                	j	8000274c <wait+0xd0>
      release(&wait_lock);
    80002796:	0000e517          	auipc	a0,0xe
    8000279a:	3c250513          	add	a0,a0,962 # 80010b58 <wait_lock>
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	54e080e7          	jalr	1358(ra) # 80000cec <release>
      return -1;
    800027a6:	59fd                	li	s3,-1
    800027a8:	b795                	j	8000270c <wait+0x90>

00000000800027aa <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027aa:	7179                	add	sp,sp,-48
    800027ac:	f406                	sd	ra,40(sp)
    800027ae:	f022                	sd	s0,32(sp)
    800027b0:	ec26                	sd	s1,24(sp)
    800027b2:	e84a                	sd	s2,16(sp)
    800027b4:	e44e                	sd	s3,8(sp)
    800027b6:	e052                	sd	s4,0(sp)
    800027b8:	1800                	add	s0,sp,48
    800027ba:	84aa                	mv	s1,a0
    800027bc:	892e                	mv	s2,a1
    800027be:	89b2                	mv	s3,a2
    800027c0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027c2:	fffff097          	auipc	ra,0xfffff
    800027c6:	2a0080e7          	jalr	672(ra) # 80001a62 <myproc>
  if(user_dst){
    800027ca:	c08d                	beqz	s1,800027ec <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800027cc:	86d2                	mv	a3,s4
    800027ce:	864e                	mv	a2,s3
    800027d0:	85ca                	mv	a1,s2
    800027d2:	6928                	ld	a0,80(a0)
    800027d4:	fffff097          	auipc	ra,0xfffff
    800027d8:	f0e080e7          	jalr	-242(ra) # 800016e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027dc:	70a2                	ld	ra,40(sp)
    800027de:	7402                	ld	s0,32(sp)
    800027e0:	64e2                	ld	s1,24(sp)
    800027e2:	6942                	ld	s2,16(sp)
    800027e4:	69a2                	ld	s3,8(sp)
    800027e6:	6a02                	ld	s4,0(sp)
    800027e8:	6145                	add	sp,sp,48
    800027ea:	8082                	ret
    memmove((char *)dst, src, len);
    800027ec:	000a061b          	sext.w	a2,s4
    800027f0:	85ce                	mv	a1,s3
    800027f2:	854a                	mv	a0,s2
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	59c080e7          	jalr	1436(ra) # 80000d90 <memmove>
    return 0;
    800027fc:	8526                	mv	a0,s1
    800027fe:	bff9                	j	800027dc <either_copyout+0x32>

0000000080002800 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002800:	7179                	add	sp,sp,-48
    80002802:	f406                	sd	ra,40(sp)
    80002804:	f022                	sd	s0,32(sp)
    80002806:	ec26                	sd	s1,24(sp)
    80002808:	e84a                	sd	s2,16(sp)
    8000280a:	e44e                	sd	s3,8(sp)
    8000280c:	e052                	sd	s4,0(sp)
    8000280e:	1800                	add	s0,sp,48
    80002810:	892a                	mv	s2,a0
    80002812:	84ae                	mv	s1,a1
    80002814:	89b2                	mv	s3,a2
    80002816:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002818:	fffff097          	auipc	ra,0xfffff
    8000281c:	24a080e7          	jalr	586(ra) # 80001a62 <myproc>
  if(user_src){
    80002820:	c08d                	beqz	s1,80002842 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002822:	86d2                	mv	a3,s4
    80002824:	864e                	mv	a2,s3
    80002826:	85ca                	mv	a1,s2
    80002828:	6928                	ld	a0,80(a0)
    8000282a:	fffff097          	auipc	ra,0xfffff
    8000282e:	f44080e7          	jalr	-188(ra) # 8000176e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002832:	70a2                	ld	ra,40(sp)
    80002834:	7402                	ld	s0,32(sp)
    80002836:	64e2                	ld	s1,24(sp)
    80002838:	6942                	ld	s2,16(sp)
    8000283a:	69a2                	ld	s3,8(sp)
    8000283c:	6a02                	ld	s4,0(sp)
    8000283e:	6145                	add	sp,sp,48
    80002840:	8082                	ret
    memmove(dst, (char*)src, len);
    80002842:	000a061b          	sext.w	a2,s4
    80002846:	85ce                	mv	a1,s3
    80002848:	854a                	mv	a0,s2
    8000284a:	ffffe097          	auipc	ra,0xffffe
    8000284e:	546080e7          	jalr	1350(ra) # 80000d90 <memmove>
    return 0;
    80002852:	8526                	mv	a0,s1
    80002854:	bff9                	j	80002832 <either_copyin+0x32>

0000000080002856 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002856:	715d                	add	sp,sp,-80
    80002858:	e486                	sd	ra,72(sp)
    8000285a:	e0a2                	sd	s0,64(sp)
    8000285c:	fc26                	sd	s1,56(sp)
    8000285e:	f84a                	sd	s2,48(sp)
    80002860:	f44e                	sd	s3,40(sp)
    80002862:	f052                	sd	s4,32(sp)
    80002864:	ec56                	sd	s5,24(sp)
    80002866:	e85a                	sd	s6,16(sp)
    80002868:	e45e                	sd	s7,8(sp)
    8000286a:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000286c:	00005517          	auipc	a0,0x5
    80002870:	7a450513          	add	a0,a0,1956 # 80008010 <etext+0x10>
    80002874:	ffffe097          	auipc	ra,0xffffe
    80002878:	d36080e7          	jalr	-714(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000287c:	0000f497          	auipc	s1,0xf
    80002880:	86448493          	add	s1,s1,-1948 # 800110e0 <proc+0x158>
    80002884:	00014917          	auipc	s2,0x14
    80002888:	25c90913          	add	s2,s2,604 # 80016ae0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000288c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000288e:	00006997          	auipc	s3,0x6
    80002892:	9e298993          	add	s3,s3,-1566 # 80008270 <etext+0x270>
    printf("%d %s %s", p->pid, state, p->name);
    80002896:	00006a97          	auipc	s5,0x6
    8000289a:	9e2a8a93          	add	s5,s5,-1566 # 80008278 <etext+0x278>
    printf("\n");
    8000289e:	00005a17          	auipc	s4,0x5
    800028a2:	772a0a13          	add	s4,s4,1906 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028a6:	00006b97          	auipc	s7,0x6
    800028aa:	eaab8b93          	add	s7,s7,-342 # 80008750 <states.0>
    800028ae:	a00d                	j	800028d0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800028b0:	ed86a583          	lw	a1,-296(a3)
    800028b4:	8556                	mv	a0,s5
    800028b6:	ffffe097          	auipc	ra,0xffffe
    800028ba:	cf4080e7          	jalr	-780(ra) # 800005aa <printf>
    printf("\n");
    800028be:	8552                	mv	a0,s4
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	cea080e7          	jalr	-790(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028c8:	16848493          	add	s1,s1,360
    800028cc:	03248263          	beq	s1,s2,800028f0 <procdump+0x9a>
    if(p->state == UNUSED)
    800028d0:	86a6                	mv	a3,s1
    800028d2:	ec04a783          	lw	a5,-320(s1)
    800028d6:	dbed                	beqz	a5,800028c8 <procdump+0x72>
      state = "???";
    800028d8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028da:	fcfb6be3          	bltu	s6,a5,800028b0 <procdump+0x5a>
    800028de:	02079713          	sll	a4,a5,0x20
    800028e2:	01d75793          	srl	a5,a4,0x1d
    800028e6:	97de                	add	a5,a5,s7
    800028e8:	6390                	ld	a2,0(a5)
    800028ea:	f279                	bnez	a2,800028b0 <procdump+0x5a>
      state = "???";
    800028ec:	864e                	mv	a2,s3
    800028ee:	b7c9                	j	800028b0 <procdump+0x5a>
  }
}
    800028f0:	60a6                	ld	ra,72(sp)
    800028f2:	6406                	ld	s0,64(sp)
    800028f4:	74e2                	ld	s1,56(sp)
    800028f6:	7942                	ld	s2,48(sp)
    800028f8:	79a2                	ld	s3,40(sp)
    800028fa:	7a02                	ld	s4,32(sp)
    800028fc:	6ae2                	ld	s5,24(sp)
    800028fe:	6b42                	ld	s6,16(sp)
    80002900:	6ba2                	ld	s7,8(sp)
    80002902:	6161                	add	sp,sp,80
    80002904:	8082                	ret

0000000080002906 <swtch>:
    80002906:	00153023          	sd	ra,0(a0)
    8000290a:	00253423          	sd	sp,8(a0)
    8000290e:	e900                	sd	s0,16(a0)
    80002910:	ed04                	sd	s1,24(a0)
    80002912:	03253023          	sd	s2,32(a0)
    80002916:	03353423          	sd	s3,40(a0)
    8000291a:	03453823          	sd	s4,48(a0)
    8000291e:	03553c23          	sd	s5,56(a0)
    80002922:	05653023          	sd	s6,64(a0)
    80002926:	05753423          	sd	s7,72(a0)
    8000292a:	05853823          	sd	s8,80(a0)
    8000292e:	05953c23          	sd	s9,88(a0)
    80002932:	07a53023          	sd	s10,96(a0)
    80002936:	07b53423          	sd	s11,104(a0)
    8000293a:	0005b083          	ld	ra,0(a1)
    8000293e:	0085b103          	ld	sp,8(a1)
    80002942:	6980                	ld	s0,16(a1)
    80002944:	6d84                	ld	s1,24(a1)
    80002946:	0205b903          	ld	s2,32(a1)
    8000294a:	0285b983          	ld	s3,40(a1)
    8000294e:	0305ba03          	ld	s4,48(a1)
    80002952:	0385ba83          	ld	s5,56(a1)
    80002956:	0405bb03          	ld	s6,64(a1)
    8000295a:	0485bb83          	ld	s7,72(a1)
    8000295e:	0505bc03          	ld	s8,80(a1)
    80002962:	0585bc83          	ld	s9,88(a1)
    80002966:	0605bd03          	ld	s10,96(a1)
    8000296a:	0685bd83          	ld	s11,104(a1)
    8000296e:	8082                	ret

0000000080002970 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002970:	1141                	add	sp,sp,-16
    80002972:	e406                	sd	ra,8(sp)
    80002974:	e022                	sd	s0,0(sp)
    80002976:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    80002978:	00006597          	auipc	a1,0x6
    8000297c:	94058593          	add	a1,a1,-1728 # 800082b8 <etext+0x2b8>
    80002980:	00014517          	auipc	a0,0x14
    80002984:	00850513          	add	a0,a0,8 # 80016988 <tickslock>
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	220080e7          	jalr	544(ra) # 80000ba8 <initlock>
}
    80002990:	60a2                	ld	ra,8(sp)
    80002992:	6402                	ld	s0,0(sp)
    80002994:	0141                	add	sp,sp,16
    80002996:	8082                	ret

0000000080002998 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002998:	1141                	add	sp,sp,-16
    8000299a:	e422                	sd	s0,8(sp)
    8000299c:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000299e:	00003797          	auipc	a5,0x3
    800029a2:	5e278793          	add	a5,a5,1506 # 80005f80 <kernelvec>
    800029a6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029aa:	6422                	ld	s0,8(sp)
    800029ac:	0141                	add	sp,sp,16
    800029ae:	8082                	ret

00000000800029b0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800029b0:	1141                	add	sp,sp,-16
    800029b2:	e406                	sd	ra,8(sp)
    800029b4:	e022                	sd	s0,0(sp)
    800029b6:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800029b8:	fffff097          	auipc	ra,0xfffff
    800029bc:	0aa080e7          	jalr	170(ra) # 80001a62 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029c4:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029c6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029ca:	00004617          	auipc	a2,0x4
    800029ce:	63660613          	add	a2,a2,1590 # 80007000 <_trampoline>
    800029d2:	00004717          	auipc	a4,0x4
    800029d6:	62e70713          	add	a4,a4,1582 # 80007000 <_trampoline>
    800029da:	8f11                	sub	a4,a4,a2
    800029dc:	040007b7          	lui	a5,0x4000
    800029e0:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800029e2:	07b2                	sll	a5,a5,0xc
    800029e4:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029e6:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029ea:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029ec:	180026f3          	csrr	a3,satp
    800029f0:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029f2:	6d34                	ld	a3,88(a0)
    800029f4:	6138                	ld	a4,64(a0)
    800029f6:	6585                	lui	a1,0x1
    800029f8:	972e                	add	a4,a4,a1
    800029fa:	e698                	sd	a4,8(a3)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029fc:	6d38                	ld	a4,88(a0)
    800029fe:	00000697          	auipc	a3,0x0
    80002a02:	14a68693          	add	a3,a3,330 # 80002b48 <usertrap>
    80002a06:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a08:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a0a:	8692                	mv	a3,tp
    80002a0c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a0e:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a12:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a16:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a1a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a1e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a20:	6f18                	ld	a4,24(a4)
    80002a22:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a26:	692c                	ld	a1,80(a0)
    80002a28:	81b1                	srl	a1,a1,0xc
  // Jump to the userret function located in trampoline.S at the top of memory.
  // Calculate the address by considering the offset due to threadID.
  // Switch to the user page table and restore user registers.
  // Finally, switch to user mode using sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64,uint64))trampoline_userret)(TRAPFRAME - (PGSIZE * p->tid), satp);
    80002a2a:	5948                	lw	a0,52(a0)
    80002a2c:	00c5151b          	sllw	a0,a0,0xc
    80002a30:	020006b7          	lui	a3,0x2000
    80002a34:	16fd                	add	a3,a3,-1 # 1ffffff <_entry-0x7e000001>
    80002a36:	06b6                	sll	a3,a3,0xd
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a38:	00004717          	auipc	a4,0x4
    80002a3c:	65870713          	add	a4,a4,1624 # 80007090 <userret>
    80002a40:	8f11                	sub	a4,a4,a2
    80002a42:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))trampoline_userret)(TRAPFRAME - (PGSIZE * p->tid), satp);
    80002a44:	577d                	li	a4,-1
    80002a46:	177e                	sll	a4,a4,0x3f
    80002a48:	8dd9                	or	a1,a1,a4
    80002a4a:	40a68533          	sub	a0,a3,a0
    80002a4e:	9782                	jalr	a5

}
    80002a50:	60a2                	ld	ra,8(sp)
    80002a52:	6402                	ld	s0,0(sp)
    80002a54:	0141                	add	sp,sp,16
    80002a56:	8082                	ret

0000000080002a58 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a58:	1101                	add	sp,sp,-32
    80002a5a:	ec06                	sd	ra,24(sp)
    80002a5c:	e822                	sd	s0,16(sp)
    80002a5e:	e426                	sd	s1,8(sp)
    80002a60:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002a62:	00014497          	auipc	s1,0x14
    80002a66:	f2648493          	add	s1,s1,-218 # 80016988 <tickslock>
    80002a6a:	8526                	mv	a0,s1
    80002a6c:	ffffe097          	auipc	ra,0xffffe
    80002a70:	1cc080e7          	jalr	460(ra) # 80000c38 <acquire>
  ticks++;
    80002a74:	00006517          	auipc	a0,0x6
    80002a78:	e5c50513          	add	a0,a0,-420 # 800088d0 <ticks>
    80002a7c:	411c                	lw	a5,0(a0)
    80002a7e:	2785                	addw	a5,a5,1
    80002a80:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a82:	00000097          	auipc	ra,0x0
    80002a86:	96c080e7          	jalr	-1684(ra) # 800023ee <wakeup>
  release(&tickslock);
    80002a8a:	8526                	mv	a0,s1
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	260080e7          	jalr	608(ra) # 80000cec <release>
}
    80002a94:	60e2                	ld	ra,24(sp)
    80002a96:	6442                	ld	s0,16(sp)
    80002a98:	64a2                	ld	s1,8(sp)
    80002a9a:	6105                	add	sp,sp,32
    80002a9c:	8082                	ret

0000000080002a9e <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a9e:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002aa2:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002aa4:	0a07d163          	bgez	a5,80002b46 <devintr+0xa8>
{
    80002aa8:	1101                	add	sp,sp,-32
    80002aaa:	ec06                	sd	ra,24(sp)
    80002aac:	e822                	sd	s0,16(sp)
    80002aae:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002ab0:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002ab4:	46a5                	li	a3,9
    80002ab6:	00d70c63          	beq	a4,a3,80002ace <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002aba:	577d                	li	a4,-1
    80002abc:	177e                	sll	a4,a4,0x3f
    80002abe:	0705                	add	a4,a4,1
    return 0;
    80002ac0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ac2:	06e78163          	beq	a5,a4,80002b24 <devintr+0x86>
  }
}
    80002ac6:	60e2                	ld	ra,24(sp)
    80002ac8:	6442                	ld	s0,16(sp)
    80002aca:	6105                	add	sp,sp,32
    80002acc:	8082                	ret
    80002ace:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002ad0:	00003097          	auipc	ra,0x3
    80002ad4:	5bc080e7          	jalr	1468(ra) # 8000608c <plic_claim>
    80002ad8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ada:	47a9                	li	a5,10
    80002adc:	00f50963          	beq	a0,a5,80002aee <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002ae0:	4785                	li	a5,1
    80002ae2:	00f50b63          	beq	a0,a5,80002af8 <devintr+0x5a>
    return 1;
    80002ae6:	4505                	li	a0,1
    } else if(irq){
    80002ae8:	ec89                	bnez	s1,80002b02 <devintr+0x64>
    80002aea:	64a2                	ld	s1,8(sp)
    80002aec:	bfe9                	j	80002ac6 <devintr+0x28>
      uartintr();
    80002aee:	ffffe097          	auipc	ra,0xffffe
    80002af2:	f0c080e7          	jalr	-244(ra) # 800009fa <uartintr>
    if(irq)
    80002af6:	a839                	j	80002b14 <devintr+0x76>
      virtio_disk_intr();
    80002af8:	00004097          	auipc	ra,0x4
    80002afc:	abe080e7          	jalr	-1346(ra) # 800065b6 <virtio_disk_intr>
    if(irq)
    80002b00:	a811                	j	80002b14 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b02:	85a6                	mv	a1,s1
    80002b04:	00005517          	auipc	a0,0x5
    80002b08:	7bc50513          	add	a0,a0,1980 # 800082c0 <etext+0x2c0>
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	a9e080e7          	jalr	-1378(ra) # 800005aa <printf>
      plic_complete(irq);
    80002b14:	8526                	mv	a0,s1
    80002b16:	00003097          	auipc	ra,0x3
    80002b1a:	59a080e7          	jalr	1434(ra) # 800060b0 <plic_complete>
    return 1;
    80002b1e:	4505                	li	a0,1
    80002b20:	64a2                	ld	s1,8(sp)
    80002b22:	b755                	j	80002ac6 <devintr+0x28>
    if(cpuid() == 0){
    80002b24:	fffff097          	auipc	ra,0xfffff
    80002b28:	f12080e7          	jalr	-238(ra) # 80001a36 <cpuid>
    80002b2c:	c901                	beqz	a0,80002b3c <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b2e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b32:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b34:	14479073          	csrw	sip,a5
    return 2;
    80002b38:	4509                	li	a0,2
    80002b3a:	b771                	j	80002ac6 <devintr+0x28>
      clockintr();
    80002b3c:	00000097          	auipc	ra,0x0
    80002b40:	f1c080e7          	jalr	-228(ra) # 80002a58 <clockintr>
    80002b44:	b7ed                	j	80002b2e <devintr+0x90>
}
    80002b46:	8082                	ret

0000000080002b48 <usertrap>:
{
    80002b48:	1101                	add	sp,sp,-32
    80002b4a:	ec06                	sd	ra,24(sp)
    80002b4c:	e822                	sd	s0,16(sp)
    80002b4e:	e426                	sd	s1,8(sp)
    80002b50:	e04a                	sd	s2,0(sp)
    80002b52:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b54:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b58:	1007f793          	and	a5,a5,256
    80002b5c:	e3b1                	bnez	a5,80002ba0 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b5e:	00003797          	auipc	a5,0x3
    80002b62:	42278793          	add	a5,a5,1058 # 80005f80 <kernelvec>
    80002b66:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b6a:	fffff097          	auipc	ra,0xfffff
    80002b6e:	ef8080e7          	jalr	-264(ra) # 80001a62 <myproc>
    80002b72:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b74:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b76:	14102773          	csrr	a4,sepc
    80002b7a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b7c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b80:	47a1                	li	a5,8
    80002b82:	02f70763          	beq	a4,a5,80002bb0 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002b86:	00000097          	auipc	ra,0x0
    80002b8a:	f18080e7          	jalr	-232(ra) # 80002a9e <devintr>
    80002b8e:	892a                	mv	s2,a0
    80002b90:	c151                	beqz	a0,80002c14 <usertrap+0xcc>
  if(killed(p))
    80002b92:	8526                	mv	a0,s1
    80002b94:	00000097          	auipc	ra,0x0
    80002b98:	ab6080e7          	jalr	-1354(ra) # 8000264a <killed>
    80002b9c:	c929                	beqz	a0,80002bee <usertrap+0xa6>
    80002b9e:	a099                	j	80002be4 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002ba0:	00005517          	auipc	a0,0x5
    80002ba4:	74050513          	add	a0,a0,1856 # 800082e0 <etext+0x2e0>
    80002ba8:	ffffe097          	auipc	ra,0xffffe
    80002bac:	9b8080e7          	jalr	-1608(ra) # 80000560 <panic>
    if(killed(p))
    80002bb0:	00000097          	auipc	ra,0x0
    80002bb4:	a9a080e7          	jalr	-1382(ra) # 8000264a <killed>
    80002bb8:	e921                	bnez	a0,80002c08 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002bba:	6cb8                	ld	a4,88(s1)
    80002bbc:	6f1c                	ld	a5,24(a4)
    80002bbe:	0791                	add	a5,a5,4
    80002bc0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bc6:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bca:	10079073          	csrw	sstatus,a5
    syscall();
    80002bce:	00000097          	auipc	ra,0x0
    80002bd2:	2d4080e7          	jalr	724(ra) # 80002ea2 <syscall>
  if(killed(p))
    80002bd6:	8526                	mv	a0,s1
    80002bd8:	00000097          	auipc	ra,0x0
    80002bdc:	a72080e7          	jalr	-1422(ra) # 8000264a <killed>
    80002be0:	c911                	beqz	a0,80002bf4 <usertrap+0xac>
    80002be2:	4901                	li	s2,0
    exit(-1);
    80002be4:	557d                	li	a0,-1
    80002be6:	00000097          	auipc	ra,0x0
    80002bea:	8d8080e7          	jalr	-1832(ra) # 800024be <exit>
  if(which_dev == 2)
    80002bee:	4789                	li	a5,2
    80002bf0:	04f90f63          	beq	s2,a5,80002c4e <usertrap+0x106>
  usertrapret();
    80002bf4:	00000097          	auipc	ra,0x0
    80002bf8:	dbc080e7          	jalr	-580(ra) # 800029b0 <usertrapret>
}
    80002bfc:	60e2                	ld	ra,24(sp)
    80002bfe:	6442                	ld	s0,16(sp)
    80002c00:	64a2                	ld	s1,8(sp)
    80002c02:	6902                	ld	s2,0(sp)
    80002c04:	6105                	add	sp,sp,32
    80002c06:	8082                	ret
      exit(-1);
    80002c08:	557d                	li	a0,-1
    80002c0a:	00000097          	auipc	ra,0x0
    80002c0e:	8b4080e7          	jalr	-1868(ra) # 800024be <exit>
    80002c12:	b765                	j	80002bba <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c14:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c18:	5890                	lw	a2,48(s1)
    80002c1a:	00005517          	auipc	a0,0x5
    80002c1e:	6e650513          	add	a0,a0,1766 # 80008300 <etext+0x300>
    80002c22:	ffffe097          	auipc	ra,0xffffe
    80002c26:	988080e7          	jalr	-1656(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c2a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c2e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c32:	00005517          	auipc	a0,0x5
    80002c36:	6fe50513          	add	a0,a0,1790 # 80008330 <etext+0x330>
    80002c3a:	ffffe097          	auipc	ra,0xffffe
    80002c3e:	970080e7          	jalr	-1680(ra) # 800005aa <printf>
    setkilled(p);
    80002c42:	8526                	mv	a0,s1
    80002c44:	00000097          	auipc	ra,0x0
    80002c48:	9da080e7          	jalr	-1574(ra) # 8000261e <setkilled>
    80002c4c:	b769                	j	80002bd6 <usertrap+0x8e>
    yield();
    80002c4e:	fffff097          	auipc	ra,0xfffff
    80002c52:	700080e7          	jalr	1792(ra) # 8000234e <yield>
    80002c56:	bf79                	j	80002bf4 <usertrap+0xac>

0000000080002c58 <kerneltrap>:
{
    80002c58:	7179                	add	sp,sp,-48
    80002c5a:	f406                	sd	ra,40(sp)
    80002c5c:	f022                	sd	s0,32(sp)
    80002c5e:	ec26                	sd	s1,24(sp)
    80002c60:	e84a                	sd	s2,16(sp)
    80002c62:	e44e                	sd	s3,8(sp)
    80002c64:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c66:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c6a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c6e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c72:	1004f793          	and	a5,s1,256
    80002c76:	cb85                	beqz	a5,80002ca6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c7c:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002c7e:	ef85                	bnez	a5,80002cb6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c80:	00000097          	auipc	ra,0x0
    80002c84:	e1e080e7          	jalr	-482(ra) # 80002a9e <devintr>
    80002c88:	cd1d                	beqz	a0,80002cc6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c8a:	4789                	li	a5,2
    80002c8c:	06f50a63          	beq	a0,a5,80002d00 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c90:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c94:	10049073          	csrw	sstatus,s1
}
    80002c98:	70a2                	ld	ra,40(sp)
    80002c9a:	7402                	ld	s0,32(sp)
    80002c9c:	64e2                	ld	s1,24(sp)
    80002c9e:	6942                	ld	s2,16(sp)
    80002ca0:	69a2                	ld	s3,8(sp)
    80002ca2:	6145                	add	sp,sp,48
    80002ca4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ca6:	00005517          	auipc	a0,0x5
    80002caa:	6aa50513          	add	a0,a0,1706 # 80008350 <etext+0x350>
    80002cae:	ffffe097          	auipc	ra,0xffffe
    80002cb2:	8b2080e7          	jalr	-1870(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002cb6:	00005517          	auipc	a0,0x5
    80002cba:	6c250513          	add	a0,a0,1730 # 80008378 <etext+0x378>
    80002cbe:	ffffe097          	auipc	ra,0xffffe
    80002cc2:	8a2080e7          	jalr	-1886(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002cc6:	85ce                	mv	a1,s3
    80002cc8:	00005517          	auipc	a0,0x5
    80002ccc:	6d050513          	add	a0,a0,1744 # 80008398 <etext+0x398>
    80002cd0:	ffffe097          	auipc	ra,0xffffe
    80002cd4:	8da080e7          	jalr	-1830(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cd8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cdc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ce0:	00005517          	auipc	a0,0x5
    80002ce4:	6c850513          	add	a0,a0,1736 # 800083a8 <etext+0x3a8>
    80002ce8:	ffffe097          	auipc	ra,0xffffe
    80002cec:	8c2080e7          	jalr	-1854(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002cf0:	00005517          	auipc	a0,0x5
    80002cf4:	6d050513          	add	a0,a0,1744 # 800083c0 <etext+0x3c0>
    80002cf8:	ffffe097          	auipc	ra,0xffffe
    80002cfc:	868080e7          	jalr	-1944(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d00:	fffff097          	auipc	ra,0xfffff
    80002d04:	d62080e7          	jalr	-670(ra) # 80001a62 <myproc>
    80002d08:	d541                	beqz	a0,80002c90 <kerneltrap+0x38>
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	d58080e7          	jalr	-680(ra) # 80001a62 <myproc>
    80002d12:	4d18                	lw	a4,24(a0)
    80002d14:	4791                	li	a5,4
    80002d16:	f6f71de3          	bne	a4,a5,80002c90 <kerneltrap+0x38>
    yield();
    80002d1a:	fffff097          	auipc	ra,0xfffff
    80002d1e:	634080e7          	jalr	1588(ra) # 8000234e <yield>
    80002d22:	b7bd                	j	80002c90 <kerneltrap+0x38>

0000000080002d24 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d24:	1101                	add	sp,sp,-32
    80002d26:	ec06                	sd	ra,24(sp)
    80002d28:	e822                	sd	s0,16(sp)
    80002d2a:	e426                	sd	s1,8(sp)
    80002d2c:	1000                	add	s0,sp,32
    80002d2e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	d32080e7          	jalr	-718(ra) # 80001a62 <myproc>
  switch (n) {
    80002d38:	4795                	li	a5,5
    80002d3a:	0497e163          	bltu	a5,s1,80002d7c <argraw+0x58>
    80002d3e:	048a                	sll	s1,s1,0x2
    80002d40:	00006717          	auipc	a4,0x6
    80002d44:	a4070713          	add	a4,a4,-1472 # 80008780 <states.0+0x30>
    80002d48:	94ba                	add	s1,s1,a4
    80002d4a:	409c                	lw	a5,0(s1)
    80002d4c:	97ba                	add	a5,a5,a4
    80002d4e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d50:	6d3c                	ld	a5,88(a0)
    80002d52:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d54:	60e2                	ld	ra,24(sp)
    80002d56:	6442                	ld	s0,16(sp)
    80002d58:	64a2                	ld	s1,8(sp)
    80002d5a:	6105                	add	sp,sp,32
    80002d5c:	8082                	ret
    return p->trapframe->a1;
    80002d5e:	6d3c                	ld	a5,88(a0)
    80002d60:	7fa8                	ld	a0,120(a5)
    80002d62:	bfcd                	j	80002d54 <argraw+0x30>
    return p->trapframe->a2;
    80002d64:	6d3c                	ld	a5,88(a0)
    80002d66:	63c8                	ld	a0,128(a5)
    80002d68:	b7f5                	j	80002d54 <argraw+0x30>
    return p->trapframe->a3;
    80002d6a:	6d3c                	ld	a5,88(a0)
    80002d6c:	67c8                	ld	a0,136(a5)
    80002d6e:	b7dd                	j	80002d54 <argraw+0x30>
    return p->trapframe->a4;
    80002d70:	6d3c                	ld	a5,88(a0)
    80002d72:	6bc8                	ld	a0,144(a5)
    80002d74:	b7c5                	j	80002d54 <argraw+0x30>
    return p->trapframe->a5;
    80002d76:	6d3c                	ld	a5,88(a0)
    80002d78:	6fc8                	ld	a0,152(a5)
    80002d7a:	bfe9                	j	80002d54 <argraw+0x30>
  panic("argraw");
    80002d7c:	00005517          	auipc	a0,0x5
    80002d80:	65450513          	add	a0,a0,1620 # 800083d0 <etext+0x3d0>
    80002d84:	ffffd097          	auipc	ra,0xffffd
    80002d88:	7dc080e7          	jalr	2012(ra) # 80000560 <panic>

0000000080002d8c <fetchaddr>:
{
    80002d8c:	1101                	add	sp,sp,-32
    80002d8e:	ec06                	sd	ra,24(sp)
    80002d90:	e822                	sd	s0,16(sp)
    80002d92:	e426                	sd	s1,8(sp)
    80002d94:	e04a                	sd	s2,0(sp)
    80002d96:	1000                	add	s0,sp,32
    80002d98:	84aa                	mv	s1,a0
    80002d9a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d9c:	fffff097          	auipc	ra,0xfffff
    80002da0:	cc6080e7          	jalr	-826(ra) # 80001a62 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002da4:	653c                	ld	a5,72(a0)
    80002da6:	02f4f863          	bgeu	s1,a5,80002dd6 <fetchaddr+0x4a>
    80002daa:	00848713          	add	a4,s1,8
    80002dae:	02e7e663          	bltu	a5,a4,80002dda <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002db2:	46a1                	li	a3,8
    80002db4:	8626                	mv	a2,s1
    80002db6:	85ca                	mv	a1,s2
    80002db8:	6928                	ld	a0,80(a0)
    80002dba:	fffff097          	auipc	ra,0xfffff
    80002dbe:	9b4080e7          	jalr	-1612(ra) # 8000176e <copyin>
    80002dc2:	00a03533          	snez	a0,a0
    80002dc6:	40a00533          	neg	a0,a0
}
    80002dca:	60e2                	ld	ra,24(sp)
    80002dcc:	6442                	ld	s0,16(sp)
    80002dce:	64a2                	ld	s1,8(sp)
    80002dd0:	6902                	ld	s2,0(sp)
    80002dd2:	6105                	add	sp,sp,32
    80002dd4:	8082                	ret
    return -1;
    80002dd6:	557d                	li	a0,-1
    80002dd8:	bfcd                	j	80002dca <fetchaddr+0x3e>
    80002dda:	557d                	li	a0,-1
    80002ddc:	b7fd                	j	80002dca <fetchaddr+0x3e>

0000000080002dde <fetchstr>:
{
    80002dde:	7179                	add	sp,sp,-48
    80002de0:	f406                	sd	ra,40(sp)
    80002de2:	f022                	sd	s0,32(sp)
    80002de4:	ec26                	sd	s1,24(sp)
    80002de6:	e84a                	sd	s2,16(sp)
    80002de8:	e44e                	sd	s3,8(sp)
    80002dea:	1800                	add	s0,sp,48
    80002dec:	892a                	mv	s2,a0
    80002dee:	84ae                	mv	s1,a1
    80002df0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002df2:	fffff097          	auipc	ra,0xfffff
    80002df6:	c70080e7          	jalr	-912(ra) # 80001a62 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002dfa:	86ce                	mv	a3,s3
    80002dfc:	864a                	mv	a2,s2
    80002dfe:	85a6                	mv	a1,s1
    80002e00:	6928                	ld	a0,80(a0)
    80002e02:	fffff097          	auipc	ra,0xfffff
    80002e06:	9fa080e7          	jalr	-1542(ra) # 800017fc <copyinstr>
    80002e0a:	00054e63          	bltz	a0,80002e26 <fetchstr+0x48>
  return strlen(buf);
    80002e0e:	8526                	mv	a0,s1
    80002e10:	ffffe097          	auipc	ra,0xffffe
    80002e14:	098080e7          	jalr	152(ra) # 80000ea8 <strlen>
}
    80002e18:	70a2                	ld	ra,40(sp)
    80002e1a:	7402                	ld	s0,32(sp)
    80002e1c:	64e2                	ld	s1,24(sp)
    80002e1e:	6942                	ld	s2,16(sp)
    80002e20:	69a2                	ld	s3,8(sp)
    80002e22:	6145                	add	sp,sp,48
    80002e24:	8082                	ret
    return -1;
    80002e26:	557d                	li	a0,-1
    80002e28:	bfc5                	j	80002e18 <fetchstr+0x3a>

0000000080002e2a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e2a:	1101                	add	sp,sp,-32
    80002e2c:	ec06                	sd	ra,24(sp)
    80002e2e:	e822                	sd	s0,16(sp)
    80002e30:	e426                	sd	s1,8(sp)
    80002e32:	1000                	add	s0,sp,32
    80002e34:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e36:	00000097          	auipc	ra,0x0
    80002e3a:	eee080e7          	jalr	-274(ra) # 80002d24 <argraw>
    80002e3e:	c088                	sw	a0,0(s1)
}
    80002e40:	60e2                	ld	ra,24(sp)
    80002e42:	6442                	ld	s0,16(sp)
    80002e44:	64a2                	ld	s1,8(sp)
    80002e46:	6105                	add	sp,sp,32
    80002e48:	8082                	ret

0000000080002e4a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e4a:	1101                	add	sp,sp,-32
    80002e4c:	ec06                	sd	ra,24(sp)
    80002e4e:	e822                	sd	s0,16(sp)
    80002e50:	e426                	sd	s1,8(sp)
    80002e52:	1000                	add	s0,sp,32
    80002e54:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e56:	00000097          	auipc	ra,0x0
    80002e5a:	ece080e7          	jalr	-306(ra) # 80002d24 <argraw>
    80002e5e:	e088                	sd	a0,0(s1)
}
    80002e60:	60e2                	ld	ra,24(sp)
    80002e62:	6442                	ld	s0,16(sp)
    80002e64:	64a2                	ld	s1,8(sp)
    80002e66:	6105                	add	sp,sp,32
    80002e68:	8082                	ret

0000000080002e6a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e6a:	7179                	add	sp,sp,-48
    80002e6c:	f406                	sd	ra,40(sp)
    80002e6e:	f022                	sd	s0,32(sp)
    80002e70:	ec26                	sd	s1,24(sp)
    80002e72:	e84a                	sd	s2,16(sp)
    80002e74:	1800                	add	s0,sp,48
    80002e76:	84ae                	mv	s1,a1
    80002e78:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e7a:	fd840593          	add	a1,s0,-40
    80002e7e:	00000097          	auipc	ra,0x0
    80002e82:	fcc080e7          	jalr	-52(ra) # 80002e4a <argaddr>
  return fetchstr(addr, buf, max);
    80002e86:	864a                	mv	a2,s2
    80002e88:	85a6                	mv	a1,s1
    80002e8a:	fd843503          	ld	a0,-40(s0)
    80002e8e:	00000097          	auipc	ra,0x0
    80002e92:	f50080e7          	jalr	-176(ra) # 80002dde <fetchstr>
}
    80002e96:	70a2                	ld	ra,40(sp)
    80002e98:	7402                	ld	s0,32(sp)
    80002e9a:	64e2                	ld	s1,24(sp)
    80002e9c:	6942                	ld	s2,16(sp)
    80002e9e:	6145                	add	sp,sp,48
    80002ea0:	8082                	ret

0000000080002ea2 <syscall>:
[SYS_clone]   sys_clone, // Clone System Call Entry
};

void
syscall(void)
{
    80002ea2:	1101                	add	sp,sp,-32
    80002ea4:	ec06                	sd	ra,24(sp)
    80002ea6:	e822                	sd	s0,16(sp)
    80002ea8:	e426                	sd	s1,8(sp)
    80002eaa:	e04a                	sd	s2,0(sp)
    80002eac:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002eae:	fffff097          	auipc	ra,0xfffff
    80002eb2:	bb4080e7          	jalr	-1100(ra) # 80001a62 <myproc>
    80002eb6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002eb8:	05853903          	ld	s2,88(a0)
    80002ebc:	0a893783          	ld	a5,168(s2)
    80002ec0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ec4:	37fd                	addw	a5,a5,-1
    80002ec6:	4755                	li	a4,21
    80002ec8:	00f76f63          	bltu	a4,a5,80002ee6 <syscall+0x44>
    80002ecc:	00369713          	sll	a4,a3,0x3
    80002ed0:	00006797          	auipc	a5,0x6
    80002ed4:	8c878793          	add	a5,a5,-1848 # 80008798 <syscalls>
    80002ed8:	97ba                	add	a5,a5,a4
    80002eda:	639c                	ld	a5,0(a5)
    80002edc:	c789                	beqz	a5,80002ee6 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ede:	9782                	jalr	a5
    80002ee0:	06a93823          	sd	a0,112(s2)
    80002ee4:	a839                	j	80002f02 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ee6:	15848613          	add	a2,s1,344
    80002eea:	588c                	lw	a1,48(s1)
    80002eec:	00005517          	auipc	a0,0x5
    80002ef0:	4ec50513          	add	a0,a0,1260 # 800083d8 <etext+0x3d8>
    80002ef4:	ffffd097          	auipc	ra,0xffffd
    80002ef8:	6b6080e7          	jalr	1718(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002efc:	6cbc                	ld	a5,88(s1)
    80002efe:	577d                	li	a4,-1
    80002f00:	fbb8                	sd	a4,112(a5)
  }
}
    80002f02:	60e2                	ld	ra,24(sp)
    80002f04:	6442                	ld	s0,16(sp)
    80002f06:	64a2                	ld	s1,8(sp)
    80002f08:	6902                	ld	s2,0(sp)
    80002f0a:	6105                	add	sp,sp,32
    80002f0c:	8082                	ret

0000000080002f0e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f0e:	1101                	add	sp,sp,-32
    80002f10:	ec06                	sd	ra,24(sp)
    80002f12:	e822                	sd	s0,16(sp)
    80002f14:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002f16:	fec40593          	add	a1,s0,-20
    80002f1a:	4501                	li	a0,0
    80002f1c:	00000097          	auipc	ra,0x0
    80002f20:	f0e080e7          	jalr	-242(ra) # 80002e2a <argint>
  exit(n);
    80002f24:	fec42503          	lw	a0,-20(s0)
    80002f28:	fffff097          	auipc	ra,0xfffff
    80002f2c:	596080e7          	jalr	1430(ra) # 800024be <exit>
  return 0;  // not reached
}
    80002f30:	4501                	li	a0,0
    80002f32:	60e2                	ld	ra,24(sp)
    80002f34:	6442                	ld	s0,16(sp)
    80002f36:	6105                	add	sp,sp,32
    80002f38:	8082                	ret

0000000080002f3a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f3a:	1141                	add	sp,sp,-16
    80002f3c:	e406                	sd	ra,8(sp)
    80002f3e:	e022                	sd	s0,0(sp)
    80002f40:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002f42:	fffff097          	auipc	ra,0xfffff
    80002f46:	b20080e7          	jalr	-1248(ra) # 80001a62 <myproc>
}
    80002f4a:	5908                	lw	a0,48(a0)
    80002f4c:	60a2                	ld	ra,8(sp)
    80002f4e:	6402                	ld	s0,0(sp)
    80002f50:	0141                	add	sp,sp,16
    80002f52:	8082                	ret

0000000080002f54 <sys_fork>:

uint64
sys_fork(void)
{
    80002f54:	1141                	add	sp,sp,-16
    80002f56:	e406                	sd	ra,8(sp)
    80002f58:	e022                	sd	s0,0(sp)
    80002f5a:	0800                	add	s0,sp,16
  return fork();
    80002f5c:	fffff097          	auipc	ra,0xfffff
    80002f60:	f2c080e7          	jalr	-212(ra) # 80001e88 <fork>
}
    80002f64:	60a2                	ld	ra,8(sp)
    80002f66:	6402                	ld	s0,0(sp)
    80002f68:	0141                	add	sp,sp,16
    80002f6a:	8082                	ret

0000000080002f6c <sys_wait>:

uint64
sys_wait(void)
{
    80002f6c:	1101                	add	sp,sp,-32
    80002f6e:	ec06                	sd	ra,24(sp)
    80002f70:	e822                	sd	s0,16(sp)
    80002f72:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f74:	fe840593          	add	a1,s0,-24
    80002f78:	4501                	li	a0,0
    80002f7a:	00000097          	auipc	ra,0x0
    80002f7e:	ed0080e7          	jalr	-304(ra) # 80002e4a <argaddr>
  return wait(p);
    80002f82:	fe843503          	ld	a0,-24(s0)
    80002f86:	fffff097          	auipc	ra,0xfffff
    80002f8a:	6f6080e7          	jalr	1782(ra) # 8000267c <wait>
}
    80002f8e:	60e2                	ld	ra,24(sp)
    80002f90:	6442                	ld	s0,16(sp)
    80002f92:	6105                	add	sp,sp,32
    80002f94:	8082                	ret

0000000080002f96 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f96:	7179                	add	sp,sp,-48
    80002f98:	f406                	sd	ra,40(sp)
    80002f9a:	f022                	sd	s0,32(sp)
    80002f9c:	ec26                	sd	s1,24(sp)
    80002f9e:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002fa0:	fdc40593          	add	a1,s0,-36
    80002fa4:	4501                	li	a0,0
    80002fa6:	00000097          	auipc	ra,0x0
    80002faa:	e84080e7          	jalr	-380(ra) # 80002e2a <argint>
  addr = myproc()->sz;
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	ab4080e7          	jalr	-1356(ra) # 80001a62 <myproc>
    80002fb6:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002fb8:	fdc42503          	lw	a0,-36(s0)
    80002fbc:	fffff097          	auipc	ra,0xfffff
    80002fc0:	e70080e7          	jalr	-400(ra) # 80001e2c <growproc>
    80002fc4:	00054863          	bltz	a0,80002fd4 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002fc8:	8526                	mv	a0,s1
    80002fca:	70a2                	ld	ra,40(sp)
    80002fcc:	7402                	ld	s0,32(sp)
    80002fce:	64e2                	ld	s1,24(sp)
    80002fd0:	6145                	add	sp,sp,48
    80002fd2:	8082                	ret
    return -1;
    80002fd4:	54fd                	li	s1,-1
    80002fd6:	bfcd                	j	80002fc8 <sys_sbrk+0x32>

0000000080002fd8 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fd8:	7139                	add	sp,sp,-64
    80002fda:	fc06                	sd	ra,56(sp)
    80002fdc:	f822                	sd	s0,48(sp)
    80002fde:	f04a                	sd	s2,32(sp)
    80002fe0:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002fe2:	fcc40593          	add	a1,s0,-52
    80002fe6:	4501                	li	a0,0
    80002fe8:	00000097          	auipc	ra,0x0
    80002fec:	e42080e7          	jalr	-446(ra) # 80002e2a <argint>
  acquire(&tickslock);
    80002ff0:	00014517          	auipc	a0,0x14
    80002ff4:	99850513          	add	a0,a0,-1640 # 80016988 <tickslock>
    80002ff8:	ffffe097          	auipc	ra,0xffffe
    80002ffc:	c40080e7          	jalr	-960(ra) # 80000c38 <acquire>
  ticks0 = ticks;
    80003000:	00006917          	auipc	s2,0x6
    80003004:	8d092903          	lw	s2,-1840(s2) # 800088d0 <ticks>
  while(ticks - ticks0 < n){
    80003008:	fcc42783          	lw	a5,-52(s0)
    8000300c:	c3b9                	beqz	a5,80003052 <sys_sleep+0x7a>
    8000300e:	f426                	sd	s1,40(sp)
    80003010:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003012:	00014997          	auipc	s3,0x14
    80003016:	97698993          	add	s3,s3,-1674 # 80016988 <tickslock>
    8000301a:	00006497          	auipc	s1,0x6
    8000301e:	8b648493          	add	s1,s1,-1866 # 800088d0 <ticks>
    if(killed(myproc())){
    80003022:	fffff097          	auipc	ra,0xfffff
    80003026:	a40080e7          	jalr	-1472(ra) # 80001a62 <myproc>
    8000302a:	fffff097          	auipc	ra,0xfffff
    8000302e:	620080e7          	jalr	1568(ra) # 8000264a <killed>
    80003032:	ed15                	bnez	a0,8000306e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003034:	85ce                	mv	a1,s3
    80003036:	8526                	mv	a0,s1
    80003038:	fffff097          	auipc	ra,0xfffff
    8000303c:	352080e7          	jalr	850(ra) # 8000238a <sleep>
  while(ticks - ticks0 < n){
    80003040:	409c                	lw	a5,0(s1)
    80003042:	412787bb          	subw	a5,a5,s2
    80003046:	fcc42703          	lw	a4,-52(s0)
    8000304a:	fce7ece3          	bltu	a5,a4,80003022 <sys_sleep+0x4a>
    8000304e:	74a2                	ld	s1,40(sp)
    80003050:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003052:	00014517          	auipc	a0,0x14
    80003056:	93650513          	add	a0,a0,-1738 # 80016988 <tickslock>
    8000305a:	ffffe097          	auipc	ra,0xffffe
    8000305e:	c92080e7          	jalr	-878(ra) # 80000cec <release>
  return 0;
    80003062:	4501                	li	a0,0
}
    80003064:	70e2                	ld	ra,56(sp)
    80003066:	7442                	ld	s0,48(sp)
    80003068:	7902                	ld	s2,32(sp)
    8000306a:	6121                	add	sp,sp,64
    8000306c:	8082                	ret
      release(&tickslock);
    8000306e:	00014517          	auipc	a0,0x14
    80003072:	91a50513          	add	a0,a0,-1766 # 80016988 <tickslock>
    80003076:	ffffe097          	auipc	ra,0xffffe
    8000307a:	c76080e7          	jalr	-906(ra) # 80000cec <release>
      return -1;
    8000307e:	557d                	li	a0,-1
    80003080:	74a2                	ld	s1,40(sp)
    80003082:	69e2                	ld	s3,24(sp)
    80003084:	b7c5                	j	80003064 <sys_sleep+0x8c>

0000000080003086 <sys_kill>:

uint64
sys_kill(void)
{
    80003086:	1101                	add	sp,sp,-32
    80003088:	ec06                	sd	ra,24(sp)
    8000308a:	e822                	sd	s0,16(sp)
    8000308c:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    8000308e:	fec40593          	add	a1,s0,-20
    80003092:	4501                	li	a0,0
    80003094:	00000097          	auipc	ra,0x0
    80003098:	d96080e7          	jalr	-618(ra) # 80002e2a <argint>
  return kill(pid);
    8000309c:	fec42503          	lw	a0,-20(s0)
    800030a0:	fffff097          	auipc	ra,0xfffff
    800030a4:	50c080e7          	jalr	1292(ra) # 800025ac <kill>
}
    800030a8:	60e2                	ld	ra,24(sp)
    800030aa:	6442                	ld	s0,16(sp)
    800030ac:	6105                	add	sp,sp,32
    800030ae:	8082                	ret

00000000800030b0 <sys_uptime>:

// System call to return the number of clock tick interrupts
// that have occurred since system start.
uint64
sys_uptime(void)
{
    800030b0:	1101                	add	sp,sp,-32
    800030b2:	ec06                	sd	ra,24(sp)
    800030b4:	e822                	sd	s0,16(sp)
    800030b6:	e426                	sd	s1,8(sp)
    800030b8:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030ba:	00014517          	auipc	a0,0x14
    800030be:	8ce50513          	add	a0,a0,-1842 # 80016988 <tickslock>
    800030c2:	ffffe097          	auipc	ra,0xffffe
    800030c6:	b76080e7          	jalr	-1162(ra) # 80000c38 <acquire>
  xticks = ticks;
    800030ca:	00006497          	auipc	s1,0x6
    800030ce:	8064a483          	lw	s1,-2042(s1) # 800088d0 <ticks>
  release(&tickslock);
    800030d2:	00014517          	auipc	a0,0x14
    800030d6:	8b650513          	add	a0,a0,-1866 # 80016988 <tickslock>
    800030da:	ffffe097          	auipc	ra,0xffffe
    800030de:	c12080e7          	jalr	-1006(ra) # 80000cec <release>
  return xticks;
}
    800030e2:	02049513          	sll	a0,s1,0x20
    800030e6:	9101                	srl	a0,a0,0x20
    800030e8:	60e2                	ld	ra,24(sp)
    800030ea:	6442                	ld	s0,16(sp)
    800030ec:	64a2                	ld	s1,8(sp)
    800030ee:	6105                	add	sp,sp,32
    800030f0:	8082                	ret

00000000800030f2 <sys_clone>:

// System call to create a clone of the parent thread.
uint64 sys_clone(void) {
    800030f2:	1101                	add	sp,sp,-32
    800030f4:	ec06                	sd	ra,24(sp)
    800030f6:	e822                	sd	s0,16(sp)
    800030f8:	1000                	add	s0,sp,32
  uint64 stack;
  int size;
  argaddr(0, &stack);
    800030fa:	fe840593          	add	a1,s0,-24
    800030fe:	4501                	li	a0,0
    80003100:	00000097          	auipc	ra,0x0
    80003104:	d4a080e7          	jalr	-694(ra) # 80002e4a <argaddr>
  argint(1, &size);
    80003108:	fe440593          	add	a1,s0,-28
    8000310c:	4505                	li	a0,1
    8000310e:	00000097          	auipc	ra,0x0
    80003112:	d1c080e7          	jalr	-740(ra) # 80002e2a <argint>
  return clone((void* ) stack);
    80003116:	fe843503          	ld	a0,-24(s0)
    8000311a:	fffff097          	auipc	ra,0xfffff
    8000311e:	eb0080e7          	jalr	-336(ra) # 80001fca <clone>
}
    80003122:	60e2                	ld	ra,24(sp)
    80003124:	6442                	ld	s0,16(sp)
    80003126:	6105                	add	sp,sp,32
    80003128:	8082                	ret

000000008000312a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000312a:	7179                	add	sp,sp,-48
    8000312c:	f406                	sd	ra,40(sp)
    8000312e:	f022                	sd	s0,32(sp)
    80003130:	ec26                	sd	s1,24(sp)
    80003132:	e84a                	sd	s2,16(sp)
    80003134:	e44e                	sd	s3,8(sp)
    80003136:	e052                	sd	s4,0(sp)
    80003138:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000313a:	00005597          	auipc	a1,0x5
    8000313e:	2be58593          	add	a1,a1,702 # 800083f8 <etext+0x3f8>
    80003142:	00014517          	auipc	a0,0x14
    80003146:	85e50513          	add	a0,a0,-1954 # 800169a0 <bcache>
    8000314a:	ffffe097          	auipc	ra,0xffffe
    8000314e:	a5e080e7          	jalr	-1442(ra) # 80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003152:	0001c797          	auipc	a5,0x1c
    80003156:	84e78793          	add	a5,a5,-1970 # 8001e9a0 <bcache+0x8000>
    8000315a:	0001c717          	auipc	a4,0x1c
    8000315e:	aae70713          	add	a4,a4,-1362 # 8001ec08 <bcache+0x8268>
    80003162:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003166:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000316a:	00014497          	auipc	s1,0x14
    8000316e:	84e48493          	add	s1,s1,-1970 # 800169b8 <bcache+0x18>
    b->next = bcache.head.next;
    80003172:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003174:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003176:	00005a17          	auipc	s4,0x5
    8000317a:	28aa0a13          	add	s4,s4,650 # 80008400 <etext+0x400>
    b->next = bcache.head.next;
    8000317e:	2b893783          	ld	a5,696(s2)
    80003182:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003184:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003188:	85d2                	mv	a1,s4
    8000318a:	01048513          	add	a0,s1,16
    8000318e:	00001097          	auipc	ra,0x1
    80003192:	4e8080e7          	jalr	1256(ra) # 80004676 <initsleeplock>
    bcache.head.next->prev = b;
    80003196:	2b893783          	ld	a5,696(s2)
    8000319a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000319c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031a0:	45848493          	add	s1,s1,1112
    800031a4:	fd349de3          	bne	s1,s3,8000317e <binit+0x54>
  }
}
    800031a8:	70a2                	ld	ra,40(sp)
    800031aa:	7402                	ld	s0,32(sp)
    800031ac:	64e2                	ld	s1,24(sp)
    800031ae:	6942                	ld	s2,16(sp)
    800031b0:	69a2                	ld	s3,8(sp)
    800031b2:	6a02                	ld	s4,0(sp)
    800031b4:	6145                	add	sp,sp,48
    800031b6:	8082                	ret

00000000800031b8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031b8:	7179                	add	sp,sp,-48
    800031ba:	f406                	sd	ra,40(sp)
    800031bc:	f022                	sd	s0,32(sp)
    800031be:	ec26                	sd	s1,24(sp)
    800031c0:	e84a                	sd	s2,16(sp)
    800031c2:	e44e                	sd	s3,8(sp)
    800031c4:	1800                	add	s0,sp,48
    800031c6:	892a                	mv	s2,a0
    800031c8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031ca:	00013517          	auipc	a0,0x13
    800031ce:	7d650513          	add	a0,a0,2006 # 800169a0 <bcache>
    800031d2:	ffffe097          	auipc	ra,0xffffe
    800031d6:	a66080e7          	jalr	-1434(ra) # 80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031da:	0001c497          	auipc	s1,0x1c
    800031de:	a7e4b483          	ld	s1,-1410(s1) # 8001ec58 <bcache+0x82b8>
    800031e2:	0001c797          	auipc	a5,0x1c
    800031e6:	a2678793          	add	a5,a5,-1498 # 8001ec08 <bcache+0x8268>
    800031ea:	02f48f63          	beq	s1,a5,80003228 <bread+0x70>
    800031ee:	873e                	mv	a4,a5
    800031f0:	a021                	j	800031f8 <bread+0x40>
    800031f2:	68a4                	ld	s1,80(s1)
    800031f4:	02e48a63          	beq	s1,a4,80003228 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031f8:	449c                	lw	a5,8(s1)
    800031fa:	ff279ce3          	bne	a5,s2,800031f2 <bread+0x3a>
    800031fe:	44dc                	lw	a5,12(s1)
    80003200:	ff3799e3          	bne	a5,s3,800031f2 <bread+0x3a>
      b->refcnt++;
    80003204:	40bc                	lw	a5,64(s1)
    80003206:	2785                	addw	a5,a5,1
    80003208:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000320a:	00013517          	auipc	a0,0x13
    8000320e:	79650513          	add	a0,a0,1942 # 800169a0 <bcache>
    80003212:	ffffe097          	auipc	ra,0xffffe
    80003216:	ada080e7          	jalr	-1318(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    8000321a:	01048513          	add	a0,s1,16
    8000321e:	00001097          	auipc	ra,0x1
    80003222:	492080e7          	jalr	1170(ra) # 800046b0 <acquiresleep>
      return b;
    80003226:	a8b9                	j	80003284 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003228:	0001c497          	auipc	s1,0x1c
    8000322c:	a284b483          	ld	s1,-1496(s1) # 8001ec50 <bcache+0x82b0>
    80003230:	0001c797          	auipc	a5,0x1c
    80003234:	9d878793          	add	a5,a5,-1576 # 8001ec08 <bcache+0x8268>
    80003238:	00f48863          	beq	s1,a5,80003248 <bread+0x90>
    8000323c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000323e:	40bc                	lw	a5,64(s1)
    80003240:	cf81                	beqz	a5,80003258 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003242:	64a4                	ld	s1,72(s1)
    80003244:	fee49de3          	bne	s1,a4,8000323e <bread+0x86>
  panic("bget: no buffers");
    80003248:	00005517          	auipc	a0,0x5
    8000324c:	1c050513          	add	a0,a0,448 # 80008408 <etext+0x408>
    80003250:	ffffd097          	auipc	ra,0xffffd
    80003254:	310080e7          	jalr	784(ra) # 80000560 <panic>
      b->dev = dev;
    80003258:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000325c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003260:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003264:	4785                	li	a5,1
    80003266:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003268:	00013517          	auipc	a0,0x13
    8000326c:	73850513          	add	a0,a0,1848 # 800169a0 <bcache>
    80003270:	ffffe097          	auipc	ra,0xffffe
    80003274:	a7c080e7          	jalr	-1412(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80003278:	01048513          	add	a0,s1,16
    8000327c:	00001097          	auipc	ra,0x1
    80003280:	434080e7          	jalr	1076(ra) # 800046b0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003284:	409c                	lw	a5,0(s1)
    80003286:	cb89                	beqz	a5,80003298 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003288:	8526                	mv	a0,s1
    8000328a:	70a2                	ld	ra,40(sp)
    8000328c:	7402                	ld	s0,32(sp)
    8000328e:	64e2                	ld	s1,24(sp)
    80003290:	6942                	ld	s2,16(sp)
    80003292:	69a2                	ld	s3,8(sp)
    80003294:	6145                	add	sp,sp,48
    80003296:	8082                	ret
    virtio_disk_rw(b, 0);
    80003298:	4581                	li	a1,0
    8000329a:	8526                	mv	a0,s1
    8000329c:	00003097          	auipc	ra,0x3
    800032a0:	0ec080e7          	jalr	236(ra) # 80006388 <virtio_disk_rw>
    b->valid = 1;
    800032a4:	4785                	li	a5,1
    800032a6:	c09c                	sw	a5,0(s1)
  return b;
    800032a8:	b7c5                	j	80003288 <bread+0xd0>

00000000800032aa <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032aa:	1101                	add	sp,sp,-32
    800032ac:	ec06                	sd	ra,24(sp)
    800032ae:	e822                	sd	s0,16(sp)
    800032b0:	e426                	sd	s1,8(sp)
    800032b2:	1000                	add	s0,sp,32
    800032b4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032b6:	0541                	add	a0,a0,16
    800032b8:	00001097          	auipc	ra,0x1
    800032bc:	492080e7          	jalr	1170(ra) # 8000474a <holdingsleep>
    800032c0:	cd01                	beqz	a0,800032d8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032c2:	4585                	li	a1,1
    800032c4:	8526                	mv	a0,s1
    800032c6:	00003097          	auipc	ra,0x3
    800032ca:	0c2080e7          	jalr	194(ra) # 80006388 <virtio_disk_rw>
}
    800032ce:	60e2                	ld	ra,24(sp)
    800032d0:	6442                	ld	s0,16(sp)
    800032d2:	64a2                	ld	s1,8(sp)
    800032d4:	6105                	add	sp,sp,32
    800032d6:	8082                	ret
    panic("bwrite");
    800032d8:	00005517          	auipc	a0,0x5
    800032dc:	14850513          	add	a0,a0,328 # 80008420 <etext+0x420>
    800032e0:	ffffd097          	auipc	ra,0xffffd
    800032e4:	280080e7          	jalr	640(ra) # 80000560 <panic>

00000000800032e8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032e8:	1101                	add	sp,sp,-32
    800032ea:	ec06                	sd	ra,24(sp)
    800032ec:	e822                	sd	s0,16(sp)
    800032ee:	e426                	sd	s1,8(sp)
    800032f0:	e04a                	sd	s2,0(sp)
    800032f2:	1000                	add	s0,sp,32
    800032f4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032f6:	01050913          	add	s2,a0,16
    800032fa:	854a                	mv	a0,s2
    800032fc:	00001097          	auipc	ra,0x1
    80003300:	44e080e7          	jalr	1102(ra) # 8000474a <holdingsleep>
    80003304:	c925                	beqz	a0,80003374 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003306:	854a                	mv	a0,s2
    80003308:	00001097          	auipc	ra,0x1
    8000330c:	3fe080e7          	jalr	1022(ra) # 80004706 <releasesleep>

  acquire(&bcache.lock);
    80003310:	00013517          	auipc	a0,0x13
    80003314:	69050513          	add	a0,a0,1680 # 800169a0 <bcache>
    80003318:	ffffe097          	auipc	ra,0xffffe
    8000331c:	920080e7          	jalr	-1760(ra) # 80000c38 <acquire>
  b->refcnt--;
    80003320:	40bc                	lw	a5,64(s1)
    80003322:	37fd                	addw	a5,a5,-1
    80003324:	0007871b          	sext.w	a4,a5
    80003328:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000332a:	e71d                	bnez	a4,80003358 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000332c:	68b8                	ld	a4,80(s1)
    8000332e:	64bc                	ld	a5,72(s1)
    80003330:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003332:	68b8                	ld	a4,80(s1)
    80003334:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003336:	0001b797          	auipc	a5,0x1b
    8000333a:	66a78793          	add	a5,a5,1642 # 8001e9a0 <bcache+0x8000>
    8000333e:	2b87b703          	ld	a4,696(a5)
    80003342:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003344:	0001c717          	auipc	a4,0x1c
    80003348:	8c470713          	add	a4,a4,-1852 # 8001ec08 <bcache+0x8268>
    8000334c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000334e:	2b87b703          	ld	a4,696(a5)
    80003352:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003354:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003358:	00013517          	auipc	a0,0x13
    8000335c:	64850513          	add	a0,a0,1608 # 800169a0 <bcache>
    80003360:	ffffe097          	auipc	ra,0xffffe
    80003364:	98c080e7          	jalr	-1652(ra) # 80000cec <release>
}
    80003368:	60e2                	ld	ra,24(sp)
    8000336a:	6442                	ld	s0,16(sp)
    8000336c:	64a2                	ld	s1,8(sp)
    8000336e:	6902                	ld	s2,0(sp)
    80003370:	6105                	add	sp,sp,32
    80003372:	8082                	ret
    panic("brelse");
    80003374:	00005517          	auipc	a0,0x5
    80003378:	0b450513          	add	a0,a0,180 # 80008428 <etext+0x428>
    8000337c:	ffffd097          	auipc	ra,0xffffd
    80003380:	1e4080e7          	jalr	484(ra) # 80000560 <panic>

0000000080003384 <bpin>:

void
bpin(struct buf *b) {
    80003384:	1101                	add	sp,sp,-32
    80003386:	ec06                	sd	ra,24(sp)
    80003388:	e822                	sd	s0,16(sp)
    8000338a:	e426                	sd	s1,8(sp)
    8000338c:	1000                	add	s0,sp,32
    8000338e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003390:	00013517          	auipc	a0,0x13
    80003394:	61050513          	add	a0,a0,1552 # 800169a0 <bcache>
    80003398:	ffffe097          	auipc	ra,0xffffe
    8000339c:	8a0080e7          	jalr	-1888(ra) # 80000c38 <acquire>
  b->refcnt++;
    800033a0:	40bc                	lw	a5,64(s1)
    800033a2:	2785                	addw	a5,a5,1
    800033a4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033a6:	00013517          	auipc	a0,0x13
    800033aa:	5fa50513          	add	a0,a0,1530 # 800169a0 <bcache>
    800033ae:	ffffe097          	auipc	ra,0xffffe
    800033b2:	93e080e7          	jalr	-1730(ra) # 80000cec <release>
}
    800033b6:	60e2                	ld	ra,24(sp)
    800033b8:	6442                	ld	s0,16(sp)
    800033ba:	64a2                	ld	s1,8(sp)
    800033bc:	6105                	add	sp,sp,32
    800033be:	8082                	ret

00000000800033c0 <bunpin>:

void
bunpin(struct buf *b) {
    800033c0:	1101                	add	sp,sp,-32
    800033c2:	ec06                	sd	ra,24(sp)
    800033c4:	e822                	sd	s0,16(sp)
    800033c6:	e426                	sd	s1,8(sp)
    800033c8:	1000                	add	s0,sp,32
    800033ca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033cc:	00013517          	auipc	a0,0x13
    800033d0:	5d450513          	add	a0,a0,1492 # 800169a0 <bcache>
    800033d4:	ffffe097          	auipc	ra,0xffffe
    800033d8:	864080e7          	jalr	-1948(ra) # 80000c38 <acquire>
  b->refcnt--;
    800033dc:	40bc                	lw	a5,64(s1)
    800033de:	37fd                	addw	a5,a5,-1
    800033e0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033e2:	00013517          	auipc	a0,0x13
    800033e6:	5be50513          	add	a0,a0,1470 # 800169a0 <bcache>
    800033ea:	ffffe097          	auipc	ra,0xffffe
    800033ee:	902080e7          	jalr	-1790(ra) # 80000cec <release>
}
    800033f2:	60e2                	ld	ra,24(sp)
    800033f4:	6442                	ld	s0,16(sp)
    800033f6:	64a2                	ld	s1,8(sp)
    800033f8:	6105                	add	sp,sp,32
    800033fa:	8082                	ret

00000000800033fc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033fc:	1101                	add	sp,sp,-32
    800033fe:	ec06                	sd	ra,24(sp)
    80003400:	e822                	sd	s0,16(sp)
    80003402:	e426                	sd	s1,8(sp)
    80003404:	e04a                	sd	s2,0(sp)
    80003406:	1000                	add	s0,sp,32
    80003408:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000340a:	00d5d59b          	srlw	a1,a1,0xd
    8000340e:	0001c797          	auipc	a5,0x1c
    80003412:	c6e7a783          	lw	a5,-914(a5) # 8001f07c <sb+0x1c>
    80003416:	9dbd                	addw	a1,a1,a5
    80003418:	00000097          	auipc	ra,0x0
    8000341c:	da0080e7          	jalr	-608(ra) # 800031b8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003420:	0074f713          	and	a4,s1,7
    80003424:	4785                	li	a5,1
    80003426:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000342a:	14ce                	sll	s1,s1,0x33
    8000342c:	90d9                	srl	s1,s1,0x36
    8000342e:	00950733          	add	a4,a0,s1
    80003432:	05874703          	lbu	a4,88(a4)
    80003436:	00e7f6b3          	and	a3,a5,a4
    8000343a:	c69d                	beqz	a3,80003468 <bfree+0x6c>
    8000343c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000343e:	94aa                	add	s1,s1,a0
    80003440:	fff7c793          	not	a5,a5
    80003444:	8f7d                	and	a4,a4,a5
    80003446:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000344a:	00001097          	auipc	ra,0x1
    8000344e:	148080e7          	jalr	328(ra) # 80004592 <log_write>
  brelse(bp);
    80003452:	854a                	mv	a0,s2
    80003454:	00000097          	auipc	ra,0x0
    80003458:	e94080e7          	jalr	-364(ra) # 800032e8 <brelse>
}
    8000345c:	60e2                	ld	ra,24(sp)
    8000345e:	6442                	ld	s0,16(sp)
    80003460:	64a2                	ld	s1,8(sp)
    80003462:	6902                	ld	s2,0(sp)
    80003464:	6105                	add	sp,sp,32
    80003466:	8082                	ret
    panic("freeing free block");
    80003468:	00005517          	auipc	a0,0x5
    8000346c:	fc850513          	add	a0,a0,-56 # 80008430 <etext+0x430>
    80003470:	ffffd097          	auipc	ra,0xffffd
    80003474:	0f0080e7          	jalr	240(ra) # 80000560 <panic>

0000000080003478 <balloc>:
{
    80003478:	711d                	add	sp,sp,-96
    8000347a:	ec86                	sd	ra,88(sp)
    8000347c:	e8a2                	sd	s0,80(sp)
    8000347e:	e4a6                	sd	s1,72(sp)
    80003480:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003482:	0001c797          	auipc	a5,0x1c
    80003486:	be27a783          	lw	a5,-1054(a5) # 8001f064 <sb+0x4>
    8000348a:	10078f63          	beqz	a5,800035a8 <balloc+0x130>
    8000348e:	e0ca                	sd	s2,64(sp)
    80003490:	fc4e                	sd	s3,56(sp)
    80003492:	f852                	sd	s4,48(sp)
    80003494:	f456                	sd	s5,40(sp)
    80003496:	f05a                	sd	s6,32(sp)
    80003498:	ec5e                	sd	s7,24(sp)
    8000349a:	e862                	sd	s8,16(sp)
    8000349c:	e466                	sd	s9,8(sp)
    8000349e:	8baa                	mv	s7,a0
    800034a0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034a2:	0001cb17          	auipc	s6,0x1c
    800034a6:	bbeb0b13          	add	s6,s6,-1090 # 8001f060 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034aa:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034ac:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ae:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034b0:	6c89                	lui	s9,0x2
    800034b2:	a061                	j	8000353a <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034b4:	97ca                	add	a5,a5,s2
    800034b6:	8e55                	or	a2,a2,a3
    800034b8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800034bc:	854a                	mv	a0,s2
    800034be:	00001097          	auipc	ra,0x1
    800034c2:	0d4080e7          	jalr	212(ra) # 80004592 <log_write>
        brelse(bp);
    800034c6:	854a                	mv	a0,s2
    800034c8:	00000097          	auipc	ra,0x0
    800034cc:	e20080e7          	jalr	-480(ra) # 800032e8 <brelse>
  bp = bread(dev, bno);
    800034d0:	85a6                	mv	a1,s1
    800034d2:	855e                	mv	a0,s7
    800034d4:	00000097          	auipc	ra,0x0
    800034d8:	ce4080e7          	jalr	-796(ra) # 800031b8 <bread>
    800034dc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034de:	40000613          	li	a2,1024
    800034e2:	4581                	li	a1,0
    800034e4:	05850513          	add	a0,a0,88
    800034e8:	ffffe097          	auipc	ra,0xffffe
    800034ec:	84c080e7          	jalr	-1972(ra) # 80000d34 <memset>
  log_write(bp);
    800034f0:	854a                	mv	a0,s2
    800034f2:	00001097          	auipc	ra,0x1
    800034f6:	0a0080e7          	jalr	160(ra) # 80004592 <log_write>
  brelse(bp);
    800034fa:	854a                	mv	a0,s2
    800034fc:	00000097          	auipc	ra,0x0
    80003500:	dec080e7          	jalr	-532(ra) # 800032e8 <brelse>
}
    80003504:	6906                	ld	s2,64(sp)
    80003506:	79e2                	ld	s3,56(sp)
    80003508:	7a42                	ld	s4,48(sp)
    8000350a:	7aa2                	ld	s5,40(sp)
    8000350c:	7b02                	ld	s6,32(sp)
    8000350e:	6be2                	ld	s7,24(sp)
    80003510:	6c42                	ld	s8,16(sp)
    80003512:	6ca2                	ld	s9,8(sp)
}
    80003514:	8526                	mv	a0,s1
    80003516:	60e6                	ld	ra,88(sp)
    80003518:	6446                	ld	s0,80(sp)
    8000351a:	64a6                	ld	s1,72(sp)
    8000351c:	6125                	add	sp,sp,96
    8000351e:	8082                	ret
    brelse(bp);
    80003520:	854a                	mv	a0,s2
    80003522:	00000097          	auipc	ra,0x0
    80003526:	dc6080e7          	jalr	-570(ra) # 800032e8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000352a:	015c87bb          	addw	a5,s9,s5
    8000352e:	00078a9b          	sext.w	s5,a5
    80003532:	004b2703          	lw	a4,4(s6)
    80003536:	06eaf163          	bgeu	s5,a4,80003598 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    8000353a:	41fad79b          	sraw	a5,s5,0x1f
    8000353e:	0137d79b          	srlw	a5,a5,0x13
    80003542:	015787bb          	addw	a5,a5,s5
    80003546:	40d7d79b          	sraw	a5,a5,0xd
    8000354a:	01cb2583          	lw	a1,28(s6)
    8000354e:	9dbd                	addw	a1,a1,a5
    80003550:	855e                	mv	a0,s7
    80003552:	00000097          	auipc	ra,0x0
    80003556:	c66080e7          	jalr	-922(ra) # 800031b8 <bread>
    8000355a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000355c:	004b2503          	lw	a0,4(s6)
    80003560:	000a849b          	sext.w	s1,s5
    80003564:	8762                	mv	a4,s8
    80003566:	faa4fde3          	bgeu	s1,a0,80003520 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000356a:	00777693          	and	a3,a4,7
    8000356e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003572:	41f7579b          	sraw	a5,a4,0x1f
    80003576:	01d7d79b          	srlw	a5,a5,0x1d
    8000357a:	9fb9                	addw	a5,a5,a4
    8000357c:	4037d79b          	sraw	a5,a5,0x3
    80003580:	00f90633          	add	a2,s2,a5
    80003584:	05864603          	lbu	a2,88(a2)
    80003588:	00c6f5b3          	and	a1,a3,a2
    8000358c:	d585                	beqz	a1,800034b4 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000358e:	2705                	addw	a4,a4,1
    80003590:	2485                	addw	s1,s1,1
    80003592:	fd471ae3          	bne	a4,s4,80003566 <balloc+0xee>
    80003596:	b769                	j	80003520 <balloc+0xa8>
    80003598:	6906                	ld	s2,64(sp)
    8000359a:	79e2                	ld	s3,56(sp)
    8000359c:	7a42                	ld	s4,48(sp)
    8000359e:	7aa2                	ld	s5,40(sp)
    800035a0:	7b02                	ld	s6,32(sp)
    800035a2:	6be2                	ld	s7,24(sp)
    800035a4:	6c42                	ld	s8,16(sp)
    800035a6:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800035a8:	00005517          	auipc	a0,0x5
    800035ac:	ea050513          	add	a0,a0,-352 # 80008448 <etext+0x448>
    800035b0:	ffffd097          	auipc	ra,0xffffd
    800035b4:	ffa080e7          	jalr	-6(ra) # 800005aa <printf>
  return 0;
    800035b8:	4481                	li	s1,0
    800035ba:	bfa9                	j	80003514 <balloc+0x9c>

00000000800035bc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800035bc:	7179                	add	sp,sp,-48
    800035be:	f406                	sd	ra,40(sp)
    800035c0:	f022                	sd	s0,32(sp)
    800035c2:	ec26                	sd	s1,24(sp)
    800035c4:	e84a                	sd	s2,16(sp)
    800035c6:	e44e                	sd	s3,8(sp)
    800035c8:	1800                	add	s0,sp,48
    800035ca:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035cc:	47ad                	li	a5,11
    800035ce:	02b7e863          	bltu	a5,a1,800035fe <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800035d2:	02059793          	sll	a5,a1,0x20
    800035d6:	01e7d593          	srl	a1,a5,0x1e
    800035da:	00b504b3          	add	s1,a0,a1
    800035de:	0504a903          	lw	s2,80(s1)
    800035e2:	08091263          	bnez	s2,80003666 <bmap+0xaa>
      addr = balloc(ip->dev);
    800035e6:	4108                	lw	a0,0(a0)
    800035e8:	00000097          	auipc	ra,0x0
    800035ec:	e90080e7          	jalr	-368(ra) # 80003478 <balloc>
    800035f0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035f4:	06090963          	beqz	s2,80003666 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    800035f8:	0524a823          	sw	s2,80(s1)
    800035fc:	a0ad                	j	80003666 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035fe:	ff45849b          	addw	s1,a1,-12
    80003602:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003606:	0ff00793          	li	a5,255
    8000360a:	08e7e863          	bltu	a5,a4,8000369a <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000360e:	08052903          	lw	s2,128(a0)
    80003612:	00091f63          	bnez	s2,80003630 <bmap+0x74>
      addr = balloc(ip->dev);
    80003616:	4108                	lw	a0,0(a0)
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	e60080e7          	jalr	-416(ra) # 80003478 <balloc>
    80003620:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003624:	04090163          	beqz	s2,80003666 <bmap+0xaa>
    80003628:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000362a:	0929a023          	sw	s2,128(s3)
    8000362e:	a011                	j	80003632 <bmap+0x76>
    80003630:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003632:	85ca                	mv	a1,s2
    80003634:	0009a503          	lw	a0,0(s3)
    80003638:	00000097          	auipc	ra,0x0
    8000363c:	b80080e7          	jalr	-1152(ra) # 800031b8 <bread>
    80003640:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003642:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    80003646:	02049713          	sll	a4,s1,0x20
    8000364a:	01e75593          	srl	a1,a4,0x1e
    8000364e:	00b784b3          	add	s1,a5,a1
    80003652:	0004a903          	lw	s2,0(s1)
    80003656:	02090063          	beqz	s2,80003676 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000365a:	8552                	mv	a0,s4
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	c8c080e7          	jalr	-884(ra) # 800032e8 <brelse>
    return addr;
    80003664:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003666:	854a                	mv	a0,s2
    80003668:	70a2                	ld	ra,40(sp)
    8000366a:	7402                	ld	s0,32(sp)
    8000366c:	64e2                	ld	s1,24(sp)
    8000366e:	6942                	ld	s2,16(sp)
    80003670:	69a2                	ld	s3,8(sp)
    80003672:	6145                	add	sp,sp,48
    80003674:	8082                	ret
      addr = balloc(ip->dev);
    80003676:	0009a503          	lw	a0,0(s3)
    8000367a:	00000097          	auipc	ra,0x0
    8000367e:	dfe080e7          	jalr	-514(ra) # 80003478 <balloc>
    80003682:	0005091b          	sext.w	s2,a0
      if(addr){
    80003686:	fc090ae3          	beqz	s2,8000365a <bmap+0x9e>
        a[bn] = addr;
    8000368a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000368e:	8552                	mv	a0,s4
    80003690:	00001097          	auipc	ra,0x1
    80003694:	f02080e7          	jalr	-254(ra) # 80004592 <log_write>
    80003698:	b7c9                	j	8000365a <bmap+0x9e>
    8000369a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000369c:	00005517          	auipc	a0,0x5
    800036a0:	dc450513          	add	a0,a0,-572 # 80008460 <etext+0x460>
    800036a4:	ffffd097          	auipc	ra,0xffffd
    800036a8:	ebc080e7          	jalr	-324(ra) # 80000560 <panic>

00000000800036ac <iget>:
{
    800036ac:	7179                	add	sp,sp,-48
    800036ae:	f406                	sd	ra,40(sp)
    800036b0:	f022                	sd	s0,32(sp)
    800036b2:	ec26                	sd	s1,24(sp)
    800036b4:	e84a                	sd	s2,16(sp)
    800036b6:	e44e                	sd	s3,8(sp)
    800036b8:	e052                	sd	s4,0(sp)
    800036ba:	1800                	add	s0,sp,48
    800036bc:	89aa                	mv	s3,a0
    800036be:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036c0:	0001c517          	auipc	a0,0x1c
    800036c4:	9c050513          	add	a0,a0,-1600 # 8001f080 <itable>
    800036c8:	ffffd097          	auipc	ra,0xffffd
    800036cc:	570080e7          	jalr	1392(ra) # 80000c38 <acquire>
  empty = 0;
    800036d0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036d2:	0001c497          	auipc	s1,0x1c
    800036d6:	9c648493          	add	s1,s1,-1594 # 8001f098 <itable+0x18>
    800036da:	0001d697          	auipc	a3,0x1d
    800036de:	44e68693          	add	a3,a3,1102 # 80020b28 <log>
    800036e2:	a039                	j	800036f0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036e4:	02090b63          	beqz	s2,8000371a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800036e8:	08848493          	add	s1,s1,136
    800036ec:	02d48a63          	beq	s1,a3,80003720 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036f0:	449c                	lw	a5,8(s1)
    800036f2:	fef059e3          	blez	a5,800036e4 <iget+0x38>
    800036f6:	4098                	lw	a4,0(s1)
    800036f8:	ff3716e3          	bne	a4,s3,800036e4 <iget+0x38>
    800036fc:	40d8                	lw	a4,4(s1)
    800036fe:	ff4713e3          	bne	a4,s4,800036e4 <iget+0x38>
      ip->ref++;
    80003702:	2785                	addw	a5,a5,1
    80003704:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003706:	0001c517          	auipc	a0,0x1c
    8000370a:	97a50513          	add	a0,a0,-1670 # 8001f080 <itable>
    8000370e:	ffffd097          	auipc	ra,0xffffd
    80003712:	5de080e7          	jalr	1502(ra) # 80000cec <release>
      return ip;
    80003716:	8926                	mv	s2,s1
    80003718:	a03d                	j	80003746 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000371a:	f7f9                	bnez	a5,800036e8 <iget+0x3c>
      empty = ip;
    8000371c:	8926                	mv	s2,s1
    8000371e:	b7e9                	j	800036e8 <iget+0x3c>
  if(empty == 0)
    80003720:	02090c63          	beqz	s2,80003758 <iget+0xac>
  ip->dev = dev;
    80003724:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003728:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000372c:	4785                	li	a5,1
    8000372e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003732:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003736:	0001c517          	auipc	a0,0x1c
    8000373a:	94a50513          	add	a0,a0,-1718 # 8001f080 <itable>
    8000373e:	ffffd097          	auipc	ra,0xffffd
    80003742:	5ae080e7          	jalr	1454(ra) # 80000cec <release>
}
    80003746:	854a                	mv	a0,s2
    80003748:	70a2                	ld	ra,40(sp)
    8000374a:	7402                	ld	s0,32(sp)
    8000374c:	64e2                	ld	s1,24(sp)
    8000374e:	6942                	ld	s2,16(sp)
    80003750:	69a2                	ld	s3,8(sp)
    80003752:	6a02                	ld	s4,0(sp)
    80003754:	6145                	add	sp,sp,48
    80003756:	8082                	ret
    panic("iget: no inodes");
    80003758:	00005517          	auipc	a0,0x5
    8000375c:	d2050513          	add	a0,a0,-736 # 80008478 <etext+0x478>
    80003760:	ffffd097          	auipc	ra,0xffffd
    80003764:	e00080e7          	jalr	-512(ra) # 80000560 <panic>

0000000080003768 <fsinit>:
fsinit(int dev) {
    80003768:	7179                	add	sp,sp,-48
    8000376a:	f406                	sd	ra,40(sp)
    8000376c:	f022                	sd	s0,32(sp)
    8000376e:	ec26                	sd	s1,24(sp)
    80003770:	e84a                	sd	s2,16(sp)
    80003772:	e44e                	sd	s3,8(sp)
    80003774:	1800                	add	s0,sp,48
    80003776:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003778:	4585                	li	a1,1
    8000377a:	00000097          	auipc	ra,0x0
    8000377e:	a3e080e7          	jalr	-1474(ra) # 800031b8 <bread>
    80003782:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003784:	0001c997          	auipc	s3,0x1c
    80003788:	8dc98993          	add	s3,s3,-1828 # 8001f060 <sb>
    8000378c:	02000613          	li	a2,32
    80003790:	05850593          	add	a1,a0,88
    80003794:	854e                	mv	a0,s3
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	5fa080e7          	jalr	1530(ra) # 80000d90 <memmove>
  brelse(bp);
    8000379e:	8526                	mv	a0,s1
    800037a0:	00000097          	auipc	ra,0x0
    800037a4:	b48080e7          	jalr	-1208(ra) # 800032e8 <brelse>
  if(sb.magic != FSMAGIC)
    800037a8:	0009a703          	lw	a4,0(s3)
    800037ac:	102037b7          	lui	a5,0x10203
    800037b0:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037b4:	02f71263          	bne	a4,a5,800037d8 <fsinit+0x70>
  initlog(dev, &sb);
    800037b8:	0001c597          	auipc	a1,0x1c
    800037bc:	8a858593          	add	a1,a1,-1880 # 8001f060 <sb>
    800037c0:	854a                	mv	a0,s2
    800037c2:	00001097          	auipc	ra,0x1
    800037c6:	b60080e7          	jalr	-1184(ra) # 80004322 <initlog>
}
    800037ca:	70a2                	ld	ra,40(sp)
    800037cc:	7402                	ld	s0,32(sp)
    800037ce:	64e2                	ld	s1,24(sp)
    800037d0:	6942                	ld	s2,16(sp)
    800037d2:	69a2                	ld	s3,8(sp)
    800037d4:	6145                	add	sp,sp,48
    800037d6:	8082                	ret
    panic("invalid file system");
    800037d8:	00005517          	auipc	a0,0x5
    800037dc:	cb050513          	add	a0,a0,-848 # 80008488 <etext+0x488>
    800037e0:	ffffd097          	auipc	ra,0xffffd
    800037e4:	d80080e7          	jalr	-640(ra) # 80000560 <panic>

00000000800037e8 <iinit>:
{
    800037e8:	7179                	add	sp,sp,-48
    800037ea:	f406                	sd	ra,40(sp)
    800037ec:	f022                	sd	s0,32(sp)
    800037ee:	ec26                	sd	s1,24(sp)
    800037f0:	e84a                	sd	s2,16(sp)
    800037f2:	e44e                	sd	s3,8(sp)
    800037f4:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    800037f6:	00005597          	auipc	a1,0x5
    800037fa:	caa58593          	add	a1,a1,-854 # 800084a0 <etext+0x4a0>
    800037fe:	0001c517          	auipc	a0,0x1c
    80003802:	88250513          	add	a0,a0,-1918 # 8001f080 <itable>
    80003806:	ffffd097          	auipc	ra,0xffffd
    8000380a:	3a2080e7          	jalr	930(ra) # 80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000380e:	0001c497          	auipc	s1,0x1c
    80003812:	89a48493          	add	s1,s1,-1894 # 8001f0a8 <itable+0x28>
    80003816:	0001d997          	auipc	s3,0x1d
    8000381a:	32298993          	add	s3,s3,802 # 80020b38 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000381e:	00005917          	auipc	s2,0x5
    80003822:	c8a90913          	add	s2,s2,-886 # 800084a8 <etext+0x4a8>
    80003826:	85ca                	mv	a1,s2
    80003828:	8526                	mv	a0,s1
    8000382a:	00001097          	auipc	ra,0x1
    8000382e:	e4c080e7          	jalr	-436(ra) # 80004676 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003832:	08848493          	add	s1,s1,136
    80003836:	ff3498e3          	bne	s1,s3,80003826 <iinit+0x3e>
}
    8000383a:	70a2                	ld	ra,40(sp)
    8000383c:	7402                	ld	s0,32(sp)
    8000383e:	64e2                	ld	s1,24(sp)
    80003840:	6942                	ld	s2,16(sp)
    80003842:	69a2                	ld	s3,8(sp)
    80003844:	6145                	add	sp,sp,48
    80003846:	8082                	ret

0000000080003848 <ialloc>:
{
    80003848:	7139                	add	sp,sp,-64
    8000384a:	fc06                	sd	ra,56(sp)
    8000384c:	f822                	sd	s0,48(sp)
    8000384e:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003850:	0001c717          	auipc	a4,0x1c
    80003854:	81c72703          	lw	a4,-2020(a4) # 8001f06c <sb+0xc>
    80003858:	4785                	li	a5,1
    8000385a:	06e7f463          	bgeu	a5,a4,800038c2 <ialloc+0x7a>
    8000385e:	f426                	sd	s1,40(sp)
    80003860:	f04a                	sd	s2,32(sp)
    80003862:	ec4e                	sd	s3,24(sp)
    80003864:	e852                	sd	s4,16(sp)
    80003866:	e456                	sd	s5,8(sp)
    80003868:	e05a                	sd	s6,0(sp)
    8000386a:	8aaa                	mv	s5,a0
    8000386c:	8b2e                	mv	s6,a1
    8000386e:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003870:	0001ba17          	auipc	s4,0x1b
    80003874:	7f0a0a13          	add	s4,s4,2032 # 8001f060 <sb>
    80003878:	00495593          	srl	a1,s2,0x4
    8000387c:	018a2783          	lw	a5,24(s4)
    80003880:	9dbd                	addw	a1,a1,a5
    80003882:	8556                	mv	a0,s5
    80003884:	00000097          	auipc	ra,0x0
    80003888:	934080e7          	jalr	-1740(ra) # 800031b8 <bread>
    8000388c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000388e:	05850993          	add	s3,a0,88
    80003892:	00f97793          	and	a5,s2,15
    80003896:	079a                	sll	a5,a5,0x6
    80003898:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000389a:	00099783          	lh	a5,0(s3)
    8000389e:	cf9d                	beqz	a5,800038dc <ialloc+0x94>
    brelse(bp);
    800038a0:	00000097          	auipc	ra,0x0
    800038a4:	a48080e7          	jalr	-1464(ra) # 800032e8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038a8:	0905                	add	s2,s2,1
    800038aa:	00ca2703          	lw	a4,12(s4)
    800038ae:	0009079b          	sext.w	a5,s2
    800038b2:	fce7e3e3          	bltu	a5,a4,80003878 <ialloc+0x30>
    800038b6:	74a2                	ld	s1,40(sp)
    800038b8:	7902                	ld	s2,32(sp)
    800038ba:	69e2                	ld	s3,24(sp)
    800038bc:	6a42                	ld	s4,16(sp)
    800038be:	6aa2                	ld	s5,8(sp)
    800038c0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800038c2:	00005517          	auipc	a0,0x5
    800038c6:	bee50513          	add	a0,a0,-1042 # 800084b0 <etext+0x4b0>
    800038ca:	ffffd097          	auipc	ra,0xffffd
    800038ce:	ce0080e7          	jalr	-800(ra) # 800005aa <printf>
  return 0;
    800038d2:	4501                	li	a0,0
}
    800038d4:	70e2                	ld	ra,56(sp)
    800038d6:	7442                	ld	s0,48(sp)
    800038d8:	6121                	add	sp,sp,64
    800038da:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800038dc:	04000613          	li	a2,64
    800038e0:	4581                	li	a1,0
    800038e2:	854e                	mv	a0,s3
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	450080e7          	jalr	1104(ra) # 80000d34 <memset>
      dip->type = type;
    800038ec:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038f0:	8526                	mv	a0,s1
    800038f2:	00001097          	auipc	ra,0x1
    800038f6:	ca0080e7          	jalr	-864(ra) # 80004592 <log_write>
      brelse(bp);
    800038fa:	8526                	mv	a0,s1
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	9ec080e7          	jalr	-1556(ra) # 800032e8 <brelse>
      return iget(dev, inum);
    80003904:	0009059b          	sext.w	a1,s2
    80003908:	8556                	mv	a0,s5
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	da2080e7          	jalr	-606(ra) # 800036ac <iget>
    80003912:	74a2                	ld	s1,40(sp)
    80003914:	7902                	ld	s2,32(sp)
    80003916:	69e2                	ld	s3,24(sp)
    80003918:	6a42                	ld	s4,16(sp)
    8000391a:	6aa2                	ld	s5,8(sp)
    8000391c:	6b02                	ld	s6,0(sp)
    8000391e:	bf5d                	j	800038d4 <ialloc+0x8c>

0000000080003920 <iupdate>:
{
    80003920:	1101                	add	sp,sp,-32
    80003922:	ec06                	sd	ra,24(sp)
    80003924:	e822                	sd	s0,16(sp)
    80003926:	e426                	sd	s1,8(sp)
    80003928:	e04a                	sd	s2,0(sp)
    8000392a:	1000                	add	s0,sp,32
    8000392c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000392e:	415c                	lw	a5,4(a0)
    80003930:	0047d79b          	srlw	a5,a5,0x4
    80003934:	0001b597          	auipc	a1,0x1b
    80003938:	7445a583          	lw	a1,1860(a1) # 8001f078 <sb+0x18>
    8000393c:	9dbd                	addw	a1,a1,a5
    8000393e:	4108                	lw	a0,0(a0)
    80003940:	00000097          	auipc	ra,0x0
    80003944:	878080e7          	jalr	-1928(ra) # 800031b8 <bread>
    80003948:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000394a:	05850793          	add	a5,a0,88
    8000394e:	40d8                	lw	a4,4(s1)
    80003950:	8b3d                	and	a4,a4,15
    80003952:	071a                	sll	a4,a4,0x6
    80003954:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003956:	04449703          	lh	a4,68(s1)
    8000395a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000395e:	04649703          	lh	a4,70(s1)
    80003962:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003966:	04849703          	lh	a4,72(s1)
    8000396a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000396e:	04a49703          	lh	a4,74(s1)
    80003972:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003976:	44f8                	lw	a4,76(s1)
    80003978:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000397a:	03400613          	li	a2,52
    8000397e:	05048593          	add	a1,s1,80
    80003982:	00c78513          	add	a0,a5,12
    80003986:	ffffd097          	auipc	ra,0xffffd
    8000398a:	40a080e7          	jalr	1034(ra) # 80000d90 <memmove>
  log_write(bp);
    8000398e:	854a                	mv	a0,s2
    80003990:	00001097          	auipc	ra,0x1
    80003994:	c02080e7          	jalr	-1022(ra) # 80004592 <log_write>
  brelse(bp);
    80003998:	854a                	mv	a0,s2
    8000399a:	00000097          	auipc	ra,0x0
    8000399e:	94e080e7          	jalr	-1714(ra) # 800032e8 <brelse>
}
    800039a2:	60e2                	ld	ra,24(sp)
    800039a4:	6442                	ld	s0,16(sp)
    800039a6:	64a2                	ld	s1,8(sp)
    800039a8:	6902                	ld	s2,0(sp)
    800039aa:	6105                	add	sp,sp,32
    800039ac:	8082                	ret

00000000800039ae <idup>:
{
    800039ae:	1101                	add	sp,sp,-32
    800039b0:	ec06                	sd	ra,24(sp)
    800039b2:	e822                	sd	s0,16(sp)
    800039b4:	e426                	sd	s1,8(sp)
    800039b6:	1000                	add	s0,sp,32
    800039b8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039ba:	0001b517          	auipc	a0,0x1b
    800039be:	6c650513          	add	a0,a0,1734 # 8001f080 <itable>
    800039c2:	ffffd097          	auipc	ra,0xffffd
    800039c6:	276080e7          	jalr	630(ra) # 80000c38 <acquire>
  ip->ref++;
    800039ca:	449c                	lw	a5,8(s1)
    800039cc:	2785                	addw	a5,a5,1
    800039ce:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039d0:	0001b517          	auipc	a0,0x1b
    800039d4:	6b050513          	add	a0,a0,1712 # 8001f080 <itable>
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	314080e7          	jalr	788(ra) # 80000cec <release>
}
    800039e0:	8526                	mv	a0,s1
    800039e2:	60e2                	ld	ra,24(sp)
    800039e4:	6442                	ld	s0,16(sp)
    800039e6:	64a2                	ld	s1,8(sp)
    800039e8:	6105                	add	sp,sp,32
    800039ea:	8082                	ret

00000000800039ec <ilock>:
{
    800039ec:	1101                	add	sp,sp,-32
    800039ee:	ec06                	sd	ra,24(sp)
    800039f0:	e822                	sd	s0,16(sp)
    800039f2:	e426                	sd	s1,8(sp)
    800039f4:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039f6:	c10d                	beqz	a0,80003a18 <ilock+0x2c>
    800039f8:	84aa                	mv	s1,a0
    800039fa:	451c                	lw	a5,8(a0)
    800039fc:	00f05e63          	blez	a5,80003a18 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003a00:	0541                	add	a0,a0,16
    80003a02:	00001097          	auipc	ra,0x1
    80003a06:	cae080e7          	jalr	-850(ra) # 800046b0 <acquiresleep>
  if(ip->valid == 0){
    80003a0a:	40bc                	lw	a5,64(s1)
    80003a0c:	cf99                	beqz	a5,80003a2a <ilock+0x3e>
}
    80003a0e:	60e2                	ld	ra,24(sp)
    80003a10:	6442                	ld	s0,16(sp)
    80003a12:	64a2                	ld	s1,8(sp)
    80003a14:	6105                	add	sp,sp,32
    80003a16:	8082                	ret
    80003a18:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003a1a:	00005517          	auipc	a0,0x5
    80003a1e:	aae50513          	add	a0,a0,-1362 # 800084c8 <etext+0x4c8>
    80003a22:	ffffd097          	auipc	ra,0xffffd
    80003a26:	b3e080e7          	jalr	-1218(ra) # 80000560 <panic>
    80003a2a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a2c:	40dc                	lw	a5,4(s1)
    80003a2e:	0047d79b          	srlw	a5,a5,0x4
    80003a32:	0001b597          	auipc	a1,0x1b
    80003a36:	6465a583          	lw	a1,1606(a1) # 8001f078 <sb+0x18>
    80003a3a:	9dbd                	addw	a1,a1,a5
    80003a3c:	4088                	lw	a0,0(s1)
    80003a3e:	fffff097          	auipc	ra,0xfffff
    80003a42:	77a080e7          	jalr	1914(ra) # 800031b8 <bread>
    80003a46:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a48:	05850593          	add	a1,a0,88
    80003a4c:	40dc                	lw	a5,4(s1)
    80003a4e:	8bbd                	and	a5,a5,15
    80003a50:	079a                	sll	a5,a5,0x6
    80003a52:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a54:	00059783          	lh	a5,0(a1)
    80003a58:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a5c:	00259783          	lh	a5,2(a1)
    80003a60:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a64:	00459783          	lh	a5,4(a1)
    80003a68:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a6c:	00659783          	lh	a5,6(a1)
    80003a70:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a74:	459c                	lw	a5,8(a1)
    80003a76:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a78:	03400613          	li	a2,52
    80003a7c:	05b1                	add	a1,a1,12
    80003a7e:	05048513          	add	a0,s1,80
    80003a82:	ffffd097          	auipc	ra,0xffffd
    80003a86:	30e080e7          	jalr	782(ra) # 80000d90 <memmove>
    brelse(bp);
    80003a8a:	854a                	mv	a0,s2
    80003a8c:	00000097          	auipc	ra,0x0
    80003a90:	85c080e7          	jalr	-1956(ra) # 800032e8 <brelse>
    ip->valid = 1;
    80003a94:	4785                	li	a5,1
    80003a96:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a98:	04449783          	lh	a5,68(s1)
    80003a9c:	c399                	beqz	a5,80003aa2 <ilock+0xb6>
    80003a9e:	6902                	ld	s2,0(sp)
    80003aa0:	b7bd                	j	80003a0e <ilock+0x22>
      panic("ilock: no type");
    80003aa2:	00005517          	auipc	a0,0x5
    80003aa6:	a2e50513          	add	a0,a0,-1490 # 800084d0 <etext+0x4d0>
    80003aaa:	ffffd097          	auipc	ra,0xffffd
    80003aae:	ab6080e7          	jalr	-1354(ra) # 80000560 <panic>

0000000080003ab2 <iunlock>:
{
    80003ab2:	1101                	add	sp,sp,-32
    80003ab4:	ec06                	sd	ra,24(sp)
    80003ab6:	e822                	sd	s0,16(sp)
    80003ab8:	e426                	sd	s1,8(sp)
    80003aba:	e04a                	sd	s2,0(sp)
    80003abc:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003abe:	c905                	beqz	a0,80003aee <iunlock+0x3c>
    80003ac0:	84aa                	mv	s1,a0
    80003ac2:	01050913          	add	s2,a0,16
    80003ac6:	854a                	mv	a0,s2
    80003ac8:	00001097          	auipc	ra,0x1
    80003acc:	c82080e7          	jalr	-894(ra) # 8000474a <holdingsleep>
    80003ad0:	cd19                	beqz	a0,80003aee <iunlock+0x3c>
    80003ad2:	449c                	lw	a5,8(s1)
    80003ad4:	00f05d63          	blez	a5,80003aee <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ad8:	854a                	mv	a0,s2
    80003ada:	00001097          	auipc	ra,0x1
    80003ade:	c2c080e7          	jalr	-980(ra) # 80004706 <releasesleep>
}
    80003ae2:	60e2                	ld	ra,24(sp)
    80003ae4:	6442                	ld	s0,16(sp)
    80003ae6:	64a2                	ld	s1,8(sp)
    80003ae8:	6902                	ld	s2,0(sp)
    80003aea:	6105                	add	sp,sp,32
    80003aec:	8082                	ret
    panic("iunlock");
    80003aee:	00005517          	auipc	a0,0x5
    80003af2:	9f250513          	add	a0,a0,-1550 # 800084e0 <etext+0x4e0>
    80003af6:	ffffd097          	auipc	ra,0xffffd
    80003afa:	a6a080e7          	jalr	-1430(ra) # 80000560 <panic>

0000000080003afe <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003afe:	7179                	add	sp,sp,-48
    80003b00:	f406                	sd	ra,40(sp)
    80003b02:	f022                	sd	s0,32(sp)
    80003b04:	ec26                	sd	s1,24(sp)
    80003b06:	e84a                	sd	s2,16(sp)
    80003b08:	e44e                	sd	s3,8(sp)
    80003b0a:	1800                	add	s0,sp,48
    80003b0c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b0e:	05050493          	add	s1,a0,80
    80003b12:	08050913          	add	s2,a0,128
    80003b16:	a021                	j	80003b1e <itrunc+0x20>
    80003b18:	0491                	add	s1,s1,4
    80003b1a:	01248d63          	beq	s1,s2,80003b34 <itrunc+0x36>
    if(ip->addrs[i]){
    80003b1e:	408c                	lw	a1,0(s1)
    80003b20:	dde5                	beqz	a1,80003b18 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003b22:	0009a503          	lw	a0,0(s3)
    80003b26:	00000097          	auipc	ra,0x0
    80003b2a:	8d6080e7          	jalr	-1834(ra) # 800033fc <bfree>
      ip->addrs[i] = 0;
    80003b2e:	0004a023          	sw	zero,0(s1)
    80003b32:	b7dd                	j	80003b18 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b34:	0809a583          	lw	a1,128(s3)
    80003b38:	ed99                	bnez	a1,80003b56 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b3a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b3e:	854e                	mv	a0,s3
    80003b40:	00000097          	auipc	ra,0x0
    80003b44:	de0080e7          	jalr	-544(ra) # 80003920 <iupdate>
}
    80003b48:	70a2                	ld	ra,40(sp)
    80003b4a:	7402                	ld	s0,32(sp)
    80003b4c:	64e2                	ld	s1,24(sp)
    80003b4e:	6942                	ld	s2,16(sp)
    80003b50:	69a2                	ld	s3,8(sp)
    80003b52:	6145                	add	sp,sp,48
    80003b54:	8082                	ret
    80003b56:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b58:	0009a503          	lw	a0,0(s3)
    80003b5c:	fffff097          	auipc	ra,0xfffff
    80003b60:	65c080e7          	jalr	1628(ra) # 800031b8 <bread>
    80003b64:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b66:	05850493          	add	s1,a0,88
    80003b6a:	45850913          	add	s2,a0,1112
    80003b6e:	a021                	j	80003b76 <itrunc+0x78>
    80003b70:	0491                	add	s1,s1,4
    80003b72:	01248b63          	beq	s1,s2,80003b88 <itrunc+0x8a>
      if(a[j])
    80003b76:	408c                	lw	a1,0(s1)
    80003b78:	dde5                	beqz	a1,80003b70 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003b7a:	0009a503          	lw	a0,0(s3)
    80003b7e:	00000097          	auipc	ra,0x0
    80003b82:	87e080e7          	jalr	-1922(ra) # 800033fc <bfree>
    80003b86:	b7ed                	j	80003b70 <itrunc+0x72>
    brelse(bp);
    80003b88:	8552                	mv	a0,s4
    80003b8a:	fffff097          	auipc	ra,0xfffff
    80003b8e:	75e080e7          	jalr	1886(ra) # 800032e8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b92:	0809a583          	lw	a1,128(s3)
    80003b96:	0009a503          	lw	a0,0(s3)
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	862080e7          	jalr	-1950(ra) # 800033fc <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ba2:	0809a023          	sw	zero,128(s3)
    80003ba6:	6a02                	ld	s4,0(sp)
    80003ba8:	bf49                	j	80003b3a <itrunc+0x3c>

0000000080003baa <iput>:
{
    80003baa:	1101                	add	sp,sp,-32
    80003bac:	ec06                	sd	ra,24(sp)
    80003bae:	e822                	sd	s0,16(sp)
    80003bb0:	e426                	sd	s1,8(sp)
    80003bb2:	1000                	add	s0,sp,32
    80003bb4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003bb6:	0001b517          	auipc	a0,0x1b
    80003bba:	4ca50513          	add	a0,a0,1226 # 8001f080 <itable>
    80003bbe:	ffffd097          	auipc	ra,0xffffd
    80003bc2:	07a080e7          	jalr	122(ra) # 80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bc6:	4498                	lw	a4,8(s1)
    80003bc8:	4785                	li	a5,1
    80003bca:	02f70263          	beq	a4,a5,80003bee <iput+0x44>
  ip->ref--;
    80003bce:	449c                	lw	a5,8(s1)
    80003bd0:	37fd                	addw	a5,a5,-1
    80003bd2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bd4:	0001b517          	auipc	a0,0x1b
    80003bd8:	4ac50513          	add	a0,a0,1196 # 8001f080 <itable>
    80003bdc:	ffffd097          	auipc	ra,0xffffd
    80003be0:	110080e7          	jalr	272(ra) # 80000cec <release>
}
    80003be4:	60e2                	ld	ra,24(sp)
    80003be6:	6442                	ld	s0,16(sp)
    80003be8:	64a2                	ld	s1,8(sp)
    80003bea:	6105                	add	sp,sp,32
    80003bec:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bee:	40bc                	lw	a5,64(s1)
    80003bf0:	dff9                	beqz	a5,80003bce <iput+0x24>
    80003bf2:	04a49783          	lh	a5,74(s1)
    80003bf6:	ffe1                	bnez	a5,80003bce <iput+0x24>
    80003bf8:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003bfa:	01048913          	add	s2,s1,16
    80003bfe:	854a                	mv	a0,s2
    80003c00:	00001097          	auipc	ra,0x1
    80003c04:	ab0080e7          	jalr	-1360(ra) # 800046b0 <acquiresleep>
    release(&itable.lock);
    80003c08:	0001b517          	auipc	a0,0x1b
    80003c0c:	47850513          	add	a0,a0,1144 # 8001f080 <itable>
    80003c10:	ffffd097          	auipc	ra,0xffffd
    80003c14:	0dc080e7          	jalr	220(ra) # 80000cec <release>
    itrunc(ip);
    80003c18:	8526                	mv	a0,s1
    80003c1a:	00000097          	auipc	ra,0x0
    80003c1e:	ee4080e7          	jalr	-284(ra) # 80003afe <itrunc>
    ip->type = 0;
    80003c22:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c26:	8526                	mv	a0,s1
    80003c28:	00000097          	auipc	ra,0x0
    80003c2c:	cf8080e7          	jalr	-776(ra) # 80003920 <iupdate>
    ip->valid = 0;
    80003c30:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c34:	854a                	mv	a0,s2
    80003c36:	00001097          	auipc	ra,0x1
    80003c3a:	ad0080e7          	jalr	-1328(ra) # 80004706 <releasesleep>
    acquire(&itable.lock);
    80003c3e:	0001b517          	auipc	a0,0x1b
    80003c42:	44250513          	add	a0,a0,1090 # 8001f080 <itable>
    80003c46:	ffffd097          	auipc	ra,0xffffd
    80003c4a:	ff2080e7          	jalr	-14(ra) # 80000c38 <acquire>
    80003c4e:	6902                	ld	s2,0(sp)
    80003c50:	bfbd                	j	80003bce <iput+0x24>

0000000080003c52 <iunlockput>:
{
    80003c52:	1101                	add	sp,sp,-32
    80003c54:	ec06                	sd	ra,24(sp)
    80003c56:	e822                	sd	s0,16(sp)
    80003c58:	e426                	sd	s1,8(sp)
    80003c5a:	1000                	add	s0,sp,32
    80003c5c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c5e:	00000097          	auipc	ra,0x0
    80003c62:	e54080e7          	jalr	-428(ra) # 80003ab2 <iunlock>
  iput(ip);
    80003c66:	8526                	mv	a0,s1
    80003c68:	00000097          	auipc	ra,0x0
    80003c6c:	f42080e7          	jalr	-190(ra) # 80003baa <iput>
}
    80003c70:	60e2                	ld	ra,24(sp)
    80003c72:	6442                	ld	s0,16(sp)
    80003c74:	64a2                	ld	s1,8(sp)
    80003c76:	6105                	add	sp,sp,32
    80003c78:	8082                	ret

0000000080003c7a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c7a:	1141                	add	sp,sp,-16
    80003c7c:	e422                	sd	s0,8(sp)
    80003c7e:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003c80:	411c                	lw	a5,0(a0)
    80003c82:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c84:	415c                	lw	a5,4(a0)
    80003c86:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c88:	04451783          	lh	a5,68(a0)
    80003c8c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c90:	04a51783          	lh	a5,74(a0)
    80003c94:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c98:	04c56783          	lwu	a5,76(a0)
    80003c9c:	e99c                	sd	a5,16(a1)
}
    80003c9e:	6422                	ld	s0,8(sp)
    80003ca0:	0141                	add	sp,sp,16
    80003ca2:	8082                	ret

0000000080003ca4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ca4:	457c                	lw	a5,76(a0)
    80003ca6:	10d7e563          	bltu	a5,a3,80003db0 <readi+0x10c>
{
    80003caa:	7159                	add	sp,sp,-112
    80003cac:	f486                	sd	ra,104(sp)
    80003cae:	f0a2                	sd	s0,96(sp)
    80003cb0:	eca6                	sd	s1,88(sp)
    80003cb2:	e0d2                	sd	s4,64(sp)
    80003cb4:	fc56                	sd	s5,56(sp)
    80003cb6:	f85a                	sd	s6,48(sp)
    80003cb8:	f45e                	sd	s7,40(sp)
    80003cba:	1880                	add	s0,sp,112
    80003cbc:	8b2a                	mv	s6,a0
    80003cbe:	8bae                	mv	s7,a1
    80003cc0:	8a32                	mv	s4,a2
    80003cc2:	84b6                	mv	s1,a3
    80003cc4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003cc6:	9f35                	addw	a4,a4,a3
    return 0;
    80003cc8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cca:	0cd76a63          	bltu	a4,a3,80003d9e <readi+0xfa>
    80003cce:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003cd0:	00e7f463          	bgeu	a5,a4,80003cd8 <readi+0x34>
    n = ip->size - off;
    80003cd4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cd8:	0a0a8963          	beqz	s5,80003d8a <readi+0xe6>
    80003cdc:	e8ca                	sd	s2,80(sp)
    80003cde:	f062                	sd	s8,32(sp)
    80003ce0:	ec66                	sd	s9,24(sp)
    80003ce2:	e86a                	sd	s10,16(sp)
    80003ce4:	e46e                	sd	s11,8(sp)
    80003ce6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ce8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cec:	5c7d                	li	s8,-1
    80003cee:	a82d                	j	80003d28 <readi+0x84>
    80003cf0:	020d1d93          	sll	s11,s10,0x20
    80003cf4:	020ddd93          	srl	s11,s11,0x20
    80003cf8:	05890613          	add	a2,s2,88
    80003cfc:	86ee                	mv	a3,s11
    80003cfe:	963a                	add	a2,a2,a4
    80003d00:	85d2                	mv	a1,s4
    80003d02:	855e                	mv	a0,s7
    80003d04:	fffff097          	auipc	ra,0xfffff
    80003d08:	aa6080e7          	jalr	-1370(ra) # 800027aa <either_copyout>
    80003d0c:	05850d63          	beq	a0,s8,80003d66 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d10:	854a                	mv	a0,s2
    80003d12:	fffff097          	auipc	ra,0xfffff
    80003d16:	5d6080e7          	jalr	1494(ra) # 800032e8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d1a:	013d09bb          	addw	s3,s10,s3
    80003d1e:	009d04bb          	addw	s1,s10,s1
    80003d22:	9a6e                	add	s4,s4,s11
    80003d24:	0559fd63          	bgeu	s3,s5,80003d7e <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003d28:	00a4d59b          	srlw	a1,s1,0xa
    80003d2c:	855a                	mv	a0,s6
    80003d2e:	00000097          	auipc	ra,0x0
    80003d32:	88e080e7          	jalr	-1906(ra) # 800035bc <bmap>
    80003d36:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d3a:	c9b1                	beqz	a1,80003d8e <readi+0xea>
    bp = bread(ip->dev, addr);
    80003d3c:	000b2503          	lw	a0,0(s6)
    80003d40:	fffff097          	auipc	ra,0xfffff
    80003d44:	478080e7          	jalr	1144(ra) # 800031b8 <bread>
    80003d48:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d4a:	3ff4f713          	and	a4,s1,1023
    80003d4e:	40ec87bb          	subw	a5,s9,a4
    80003d52:	413a86bb          	subw	a3,s5,s3
    80003d56:	8d3e                	mv	s10,a5
    80003d58:	2781                	sext.w	a5,a5
    80003d5a:	0006861b          	sext.w	a2,a3
    80003d5e:	f8f679e3          	bgeu	a2,a5,80003cf0 <readi+0x4c>
    80003d62:	8d36                	mv	s10,a3
    80003d64:	b771                	j	80003cf0 <readi+0x4c>
      brelse(bp);
    80003d66:	854a                	mv	a0,s2
    80003d68:	fffff097          	auipc	ra,0xfffff
    80003d6c:	580080e7          	jalr	1408(ra) # 800032e8 <brelse>
      tot = -1;
    80003d70:	59fd                	li	s3,-1
      break;
    80003d72:	6946                	ld	s2,80(sp)
    80003d74:	7c02                	ld	s8,32(sp)
    80003d76:	6ce2                	ld	s9,24(sp)
    80003d78:	6d42                	ld	s10,16(sp)
    80003d7a:	6da2                	ld	s11,8(sp)
    80003d7c:	a831                	j	80003d98 <readi+0xf4>
    80003d7e:	6946                	ld	s2,80(sp)
    80003d80:	7c02                	ld	s8,32(sp)
    80003d82:	6ce2                	ld	s9,24(sp)
    80003d84:	6d42                	ld	s10,16(sp)
    80003d86:	6da2                	ld	s11,8(sp)
    80003d88:	a801                	j	80003d98 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d8a:	89d6                	mv	s3,s5
    80003d8c:	a031                	j	80003d98 <readi+0xf4>
    80003d8e:	6946                	ld	s2,80(sp)
    80003d90:	7c02                	ld	s8,32(sp)
    80003d92:	6ce2                	ld	s9,24(sp)
    80003d94:	6d42                	ld	s10,16(sp)
    80003d96:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003d98:	0009851b          	sext.w	a0,s3
    80003d9c:	69a6                	ld	s3,72(sp)
}
    80003d9e:	70a6                	ld	ra,104(sp)
    80003da0:	7406                	ld	s0,96(sp)
    80003da2:	64e6                	ld	s1,88(sp)
    80003da4:	6a06                	ld	s4,64(sp)
    80003da6:	7ae2                	ld	s5,56(sp)
    80003da8:	7b42                	ld	s6,48(sp)
    80003daa:	7ba2                	ld	s7,40(sp)
    80003dac:	6165                	add	sp,sp,112
    80003dae:	8082                	ret
    return 0;
    80003db0:	4501                	li	a0,0
}
    80003db2:	8082                	ret

0000000080003db4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003db4:	457c                	lw	a5,76(a0)
    80003db6:	10d7ee63          	bltu	a5,a3,80003ed2 <writei+0x11e>
{
    80003dba:	7159                	add	sp,sp,-112
    80003dbc:	f486                	sd	ra,104(sp)
    80003dbe:	f0a2                	sd	s0,96(sp)
    80003dc0:	e8ca                	sd	s2,80(sp)
    80003dc2:	e0d2                	sd	s4,64(sp)
    80003dc4:	fc56                	sd	s5,56(sp)
    80003dc6:	f85a                	sd	s6,48(sp)
    80003dc8:	f45e                	sd	s7,40(sp)
    80003dca:	1880                	add	s0,sp,112
    80003dcc:	8aaa                	mv	s5,a0
    80003dce:	8bae                	mv	s7,a1
    80003dd0:	8a32                	mv	s4,a2
    80003dd2:	8936                	mv	s2,a3
    80003dd4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003dd6:	00e687bb          	addw	a5,a3,a4
    80003dda:	0ed7ee63          	bltu	a5,a3,80003ed6 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dde:	00043737          	lui	a4,0x43
    80003de2:	0ef76c63          	bltu	a4,a5,80003eda <writei+0x126>
    80003de6:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003de8:	0c0b0d63          	beqz	s6,80003ec2 <writei+0x10e>
    80003dec:	eca6                	sd	s1,88(sp)
    80003dee:	f062                	sd	s8,32(sp)
    80003df0:	ec66                	sd	s9,24(sp)
    80003df2:	e86a                	sd	s10,16(sp)
    80003df4:	e46e                	sd	s11,8(sp)
    80003df6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003df8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003dfc:	5c7d                	li	s8,-1
    80003dfe:	a091                	j	80003e42 <writei+0x8e>
    80003e00:	020d1d93          	sll	s11,s10,0x20
    80003e04:	020ddd93          	srl	s11,s11,0x20
    80003e08:	05848513          	add	a0,s1,88
    80003e0c:	86ee                	mv	a3,s11
    80003e0e:	8652                	mv	a2,s4
    80003e10:	85de                	mv	a1,s7
    80003e12:	953a                	add	a0,a0,a4
    80003e14:	fffff097          	auipc	ra,0xfffff
    80003e18:	9ec080e7          	jalr	-1556(ra) # 80002800 <either_copyin>
    80003e1c:	07850263          	beq	a0,s8,80003e80 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e20:	8526                	mv	a0,s1
    80003e22:	00000097          	auipc	ra,0x0
    80003e26:	770080e7          	jalr	1904(ra) # 80004592 <log_write>
    brelse(bp);
    80003e2a:	8526                	mv	a0,s1
    80003e2c:	fffff097          	auipc	ra,0xfffff
    80003e30:	4bc080e7          	jalr	1212(ra) # 800032e8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e34:	013d09bb          	addw	s3,s10,s3
    80003e38:	012d093b          	addw	s2,s10,s2
    80003e3c:	9a6e                	add	s4,s4,s11
    80003e3e:	0569f663          	bgeu	s3,s6,80003e8a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003e42:	00a9559b          	srlw	a1,s2,0xa
    80003e46:	8556                	mv	a0,s5
    80003e48:	fffff097          	auipc	ra,0xfffff
    80003e4c:	774080e7          	jalr	1908(ra) # 800035bc <bmap>
    80003e50:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e54:	c99d                	beqz	a1,80003e8a <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e56:	000aa503          	lw	a0,0(s5)
    80003e5a:	fffff097          	auipc	ra,0xfffff
    80003e5e:	35e080e7          	jalr	862(ra) # 800031b8 <bread>
    80003e62:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e64:	3ff97713          	and	a4,s2,1023
    80003e68:	40ec87bb          	subw	a5,s9,a4
    80003e6c:	413b06bb          	subw	a3,s6,s3
    80003e70:	8d3e                	mv	s10,a5
    80003e72:	2781                	sext.w	a5,a5
    80003e74:	0006861b          	sext.w	a2,a3
    80003e78:	f8f674e3          	bgeu	a2,a5,80003e00 <writei+0x4c>
    80003e7c:	8d36                	mv	s10,a3
    80003e7e:	b749                	j	80003e00 <writei+0x4c>
      brelse(bp);
    80003e80:	8526                	mv	a0,s1
    80003e82:	fffff097          	auipc	ra,0xfffff
    80003e86:	466080e7          	jalr	1126(ra) # 800032e8 <brelse>
  }

  if(off > ip->size)
    80003e8a:	04caa783          	lw	a5,76(s5)
    80003e8e:	0327fc63          	bgeu	a5,s2,80003ec6 <writei+0x112>
    ip->size = off;
    80003e92:	052aa623          	sw	s2,76(s5)
    80003e96:	64e6                	ld	s1,88(sp)
    80003e98:	7c02                	ld	s8,32(sp)
    80003e9a:	6ce2                	ld	s9,24(sp)
    80003e9c:	6d42                	ld	s10,16(sp)
    80003e9e:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ea0:	8556                	mv	a0,s5
    80003ea2:	00000097          	auipc	ra,0x0
    80003ea6:	a7e080e7          	jalr	-1410(ra) # 80003920 <iupdate>

  return tot;
    80003eaa:	0009851b          	sext.w	a0,s3
    80003eae:	69a6                	ld	s3,72(sp)
}
    80003eb0:	70a6                	ld	ra,104(sp)
    80003eb2:	7406                	ld	s0,96(sp)
    80003eb4:	6946                	ld	s2,80(sp)
    80003eb6:	6a06                	ld	s4,64(sp)
    80003eb8:	7ae2                	ld	s5,56(sp)
    80003eba:	7b42                	ld	s6,48(sp)
    80003ebc:	7ba2                	ld	s7,40(sp)
    80003ebe:	6165                	add	sp,sp,112
    80003ec0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ec2:	89da                	mv	s3,s6
    80003ec4:	bff1                	j	80003ea0 <writei+0xec>
    80003ec6:	64e6                	ld	s1,88(sp)
    80003ec8:	7c02                	ld	s8,32(sp)
    80003eca:	6ce2                	ld	s9,24(sp)
    80003ecc:	6d42                	ld	s10,16(sp)
    80003ece:	6da2                	ld	s11,8(sp)
    80003ed0:	bfc1                	j	80003ea0 <writei+0xec>
    return -1;
    80003ed2:	557d                	li	a0,-1
}
    80003ed4:	8082                	ret
    return -1;
    80003ed6:	557d                	li	a0,-1
    80003ed8:	bfe1                	j	80003eb0 <writei+0xfc>
    return -1;
    80003eda:	557d                	li	a0,-1
    80003edc:	bfd1                	j	80003eb0 <writei+0xfc>

0000000080003ede <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ede:	1141                	add	sp,sp,-16
    80003ee0:	e406                	sd	ra,8(sp)
    80003ee2:	e022                	sd	s0,0(sp)
    80003ee4:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ee6:	4639                	li	a2,14
    80003ee8:	ffffd097          	auipc	ra,0xffffd
    80003eec:	f1c080e7          	jalr	-228(ra) # 80000e04 <strncmp>
}
    80003ef0:	60a2                	ld	ra,8(sp)
    80003ef2:	6402                	ld	s0,0(sp)
    80003ef4:	0141                	add	sp,sp,16
    80003ef6:	8082                	ret

0000000080003ef8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ef8:	7139                	add	sp,sp,-64
    80003efa:	fc06                	sd	ra,56(sp)
    80003efc:	f822                	sd	s0,48(sp)
    80003efe:	f426                	sd	s1,40(sp)
    80003f00:	f04a                	sd	s2,32(sp)
    80003f02:	ec4e                	sd	s3,24(sp)
    80003f04:	e852                	sd	s4,16(sp)
    80003f06:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f08:	04451703          	lh	a4,68(a0)
    80003f0c:	4785                	li	a5,1
    80003f0e:	00f71a63          	bne	a4,a5,80003f22 <dirlookup+0x2a>
    80003f12:	892a                	mv	s2,a0
    80003f14:	89ae                	mv	s3,a1
    80003f16:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f18:	457c                	lw	a5,76(a0)
    80003f1a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f1c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f1e:	e79d                	bnez	a5,80003f4c <dirlookup+0x54>
    80003f20:	a8a5                	j	80003f98 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f22:	00004517          	auipc	a0,0x4
    80003f26:	5c650513          	add	a0,a0,1478 # 800084e8 <etext+0x4e8>
    80003f2a:	ffffc097          	auipc	ra,0xffffc
    80003f2e:	636080e7          	jalr	1590(ra) # 80000560 <panic>
      panic("dirlookup read");
    80003f32:	00004517          	auipc	a0,0x4
    80003f36:	5ce50513          	add	a0,a0,1486 # 80008500 <etext+0x500>
    80003f3a:	ffffc097          	auipc	ra,0xffffc
    80003f3e:	626080e7          	jalr	1574(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f42:	24c1                	addw	s1,s1,16
    80003f44:	04c92783          	lw	a5,76(s2)
    80003f48:	04f4f763          	bgeu	s1,a5,80003f96 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f4c:	4741                	li	a4,16
    80003f4e:	86a6                	mv	a3,s1
    80003f50:	fc040613          	add	a2,s0,-64
    80003f54:	4581                	li	a1,0
    80003f56:	854a                	mv	a0,s2
    80003f58:	00000097          	auipc	ra,0x0
    80003f5c:	d4c080e7          	jalr	-692(ra) # 80003ca4 <readi>
    80003f60:	47c1                	li	a5,16
    80003f62:	fcf518e3          	bne	a0,a5,80003f32 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f66:	fc045783          	lhu	a5,-64(s0)
    80003f6a:	dfe1                	beqz	a5,80003f42 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f6c:	fc240593          	add	a1,s0,-62
    80003f70:	854e                	mv	a0,s3
    80003f72:	00000097          	auipc	ra,0x0
    80003f76:	f6c080e7          	jalr	-148(ra) # 80003ede <namecmp>
    80003f7a:	f561                	bnez	a0,80003f42 <dirlookup+0x4a>
      if(poff)
    80003f7c:	000a0463          	beqz	s4,80003f84 <dirlookup+0x8c>
        *poff = off;
    80003f80:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f84:	fc045583          	lhu	a1,-64(s0)
    80003f88:	00092503          	lw	a0,0(s2)
    80003f8c:	fffff097          	auipc	ra,0xfffff
    80003f90:	720080e7          	jalr	1824(ra) # 800036ac <iget>
    80003f94:	a011                	j	80003f98 <dirlookup+0xa0>
  return 0;
    80003f96:	4501                	li	a0,0
}
    80003f98:	70e2                	ld	ra,56(sp)
    80003f9a:	7442                	ld	s0,48(sp)
    80003f9c:	74a2                	ld	s1,40(sp)
    80003f9e:	7902                	ld	s2,32(sp)
    80003fa0:	69e2                	ld	s3,24(sp)
    80003fa2:	6a42                	ld	s4,16(sp)
    80003fa4:	6121                	add	sp,sp,64
    80003fa6:	8082                	ret

0000000080003fa8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003fa8:	711d                	add	sp,sp,-96
    80003faa:	ec86                	sd	ra,88(sp)
    80003fac:	e8a2                	sd	s0,80(sp)
    80003fae:	e4a6                	sd	s1,72(sp)
    80003fb0:	e0ca                	sd	s2,64(sp)
    80003fb2:	fc4e                	sd	s3,56(sp)
    80003fb4:	f852                	sd	s4,48(sp)
    80003fb6:	f456                	sd	s5,40(sp)
    80003fb8:	f05a                	sd	s6,32(sp)
    80003fba:	ec5e                	sd	s7,24(sp)
    80003fbc:	e862                	sd	s8,16(sp)
    80003fbe:	e466                	sd	s9,8(sp)
    80003fc0:	1080                	add	s0,sp,96
    80003fc2:	84aa                	mv	s1,a0
    80003fc4:	8b2e                	mv	s6,a1
    80003fc6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003fc8:	00054703          	lbu	a4,0(a0)
    80003fcc:	02f00793          	li	a5,47
    80003fd0:	02f70263          	beq	a4,a5,80003ff4 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003fd4:	ffffe097          	auipc	ra,0xffffe
    80003fd8:	a8e080e7          	jalr	-1394(ra) # 80001a62 <myproc>
    80003fdc:	15053503          	ld	a0,336(a0)
    80003fe0:	00000097          	auipc	ra,0x0
    80003fe4:	9ce080e7          	jalr	-1586(ra) # 800039ae <idup>
    80003fe8:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003fea:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003fee:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ff0:	4b85                	li	s7,1
    80003ff2:	a875                	j	800040ae <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003ff4:	4585                	li	a1,1
    80003ff6:	4505                	li	a0,1
    80003ff8:	fffff097          	auipc	ra,0xfffff
    80003ffc:	6b4080e7          	jalr	1716(ra) # 800036ac <iget>
    80004000:	8a2a                	mv	s4,a0
    80004002:	b7e5                	j	80003fea <namex+0x42>
      iunlockput(ip);
    80004004:	8552                	mv	a0,s4
    80004006:	00000097          	auipc	ra,0x0
    8000400a:	c4c080e7          	jalr	-948(ra) # 80003c52 <iunlockput>
      return 0;
    8000400e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004010:	8552                	mv	a0,s4
    80004012:	60e6                	ld	ra,88(sp)
    80004014:	6446                	ld	s0,80(sp)
    80004016:	64a6                	ld	s1,72(sp)
    80004018:	6906                	ld	s2,64(sp)
    8000401a:	79e2                	ld	s3,56(sp)
    8000401c:	7a42                	ld	s4,48(sp)
    8000401e:	7aa2                	ld	s5,40(sp)
    80004020:	7b02                	ld	s6,32(sp)
    80004022:	6be2                	ld	s7,24(sp)
    80004024:	6c42                	ld	s8,16(sp)
    80004026:	6ca2                	ld	s9,8(sp)
    80004028:	6125                	add	sp,sp,96
    8000402a:	8082                	ret
      iunlock(ip);
    8000402c:	8552                	mv	a0,s4
    8000402e:	00000097          	auipc	ra,0x0
    80004032:	a84080e7          	jalr	-1404(ra) # 80003ab2 <iunlock>
      return ip;
    80004036:	bfe9                	j	80004010 <namex+0x68>
      iunlockput(ip);
    80004038:	8552                	mv	a0,s4
    8000403a:	00000097          	auipc	ra,0x0
    8000403e:	c18080e7          	jalr	-1000(ra) # 80003c52 <iunlockput>
      return 0;
    80004042:	8a4e                	mv	s4,s3
    80004044:	b7f1                	j	80004010 <namex+0x68>
  len = path - s;
    80004046:	40998633          	sub	a2,s3,s1
    8000404a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000404e:	099c5863          	bge	s8,s9,800040de <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004052:	4639                	li	a2,14
    80004054:	85a6                	mv	a1,s1
    80004056:	8556                	mv	a0,s5
    80004058:	ffffd097          	auipc	ra,0xffffd
    8000405c:	d38080e7          	jalr	-712(ra) # 80000d90 <memmove>
    80004060:	84ce                	mv	s1,s3
  while(*path == '/')
    80004062:	0004c783          	lbu	a5,0(s1)
    80004066:	01279763          	bne	a5,s2,80004074 <namex+0xcc>
    path++;
    8000406a:	0485                	add	s1,s1,1
  while(*path == '/')
    8000406c:	0004c783          	lbu	a5,0(s1)
    80004070:	ff278de3          	beq	a5,s2,8000406a <namex+0xc2>
    ilock(ip);
    80004074:	8552                	mv	a0,s4
    80004076:	00000097          	auipc	ra,0x0
    8000407a:	976080e7          	jalr	-1674(ra) # 800039ec <ilock>
    if(ip->type != T_DIR){
    8000407e:	044a1783          	lh	a5,68(s4)
    80004082:	f97791e3          	bne	a5,s7,80004004 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004086:	000b0563          	beqz	s6,80004090 <namex+0xe8>
    8000408a:	0004c783          	lbu	a5,0(s1)
    8000408e:	dfd9                	beqz	a5,8000402c <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004090:	4601                	li	a2,0
    80004092:	85d6                	mv	a1,s5
    80004094:	8552                	mv	a0,s4
    80004096:	00000097          	auipc	ra,0x0
    8000409a:	e62080e7          	jalr	-414(ra) # 80003ef8 <dirlookup>
    8000409e:	89aa                	mv	s3,a0
    800040a0:	dd41                	beqz	a0,80004038 <namex+0x90>
    iunlockput(ip);
    800040a2:	8552                	mv	a0,s4
    800040a4:	00000097          	auipc	ra,0x0
    800040a8:	bae080e7          	jalr	-1106(ra) # 80003c52 <iunlockput>
    ip = next;
    800040ac:	8a4e                	mv	s4,s3
  while(*path == '/')
    800040ae:	0004c783          	lbu	a5,0(s1)
    800040b2:	01279763          	bne	a5,s2,800040c0 <namex+0x118>
    path++;
    800040b6:	0485                	add	s1,s1,1
  while(*path == '/')
    800040b8:	0004c783          	lbu	a5,0(s1)
    800040bc:	ff278de3          	beq	a5,s2,800040b6 <namex+0x10e>
  if(*path == 0)
    800040c0:	cb9d                	beqz	a5,800040f6 <namex+0x14e>
  while(*path != '/' && *path != 0)
    800040c2:	0004c783          	lbu	a5,0(s1)
    800040c6:	89a6                	mv	s3,s1
  len = path - s;
    800040c8:	4c81                	li	s9,0
    800040ca:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800040cc:	01278963          	beq	a5,s2,800040de <namex+0x136>
    800040d0:	dbbd                	beqz	a5,80004046 <namex+0x9e>
    path++;
    800040d2:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    800040d4:	0009c783          	lbu	a5,0(s3)
    800040d8:	ff279ce3          	bne	a5,s2,800040d0 <namex+0x128>
    800040dc:	b7ad                	j	80004046 <namex+0x9e>
    memmove(name, s, len);
    800040de:	2601                	sext.w	a2,a2
    800040e0:	85a6                	mv	a1,s1
    800040e2:	8556                	mv	a0,s5
    800040e4:	ffffd097          	auipc	ra,0xffffd
    800040e8:	cac080e7          	jalr	-852(ra) # 80000d90 <memmove>
    name[len] = 0;
    800040ec:	9cd6                	add	s9,s9,s5
    800040ee:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800040f2:	84ce                	mv	s1,s3
    800040f4:	b7bd                	j	80004062 <namex+0xba>
  if(nameiparent){
    800040f6:	f00b0de3          	beqz	s6,80004010 <namex+0x68>
    iput(ip);
    800040fa:	8552                	mv	a0,s4
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	aae080e7          	jalr	-1362(ra) # 80003baa <iput>
    return 0;
    80004104:	4a01                	li	s4,0
    80004106:	b729                	j	80004010 <namex+0x68>

0000000080004108 <dirlink>:
{
    80004108:	7139                	add	sp,sp,-64
    8000410a:	fc06                	sd	ra,56(sp)
    8000410c:	f822                	sd	s0,48(sp)
    8000410e:	f04a                	sd	s2,32(sp)
    80004110:	ec4e                	sd	s3,24(sp)
    80004112:	e852                	sd	s4,16(sp)
    80004114:	0080                	add	s0,sp,64
    80004116:	892a                	mv	s2,a0
    80004118:	8a2e                	mv	s4,a1
    8000411a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000411c:	4601                	li	a2,0
    8000411e:	00000097          	auipc	ra,0x0
    80004122:	dda080e7          	jalr	-550(ra) # 80003ef8 <dirlookup>
    80004126:	ed25                	bnez	a0,8000419e <dirlink+0x96>
    80004128:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000412a:	04c92483          	lw	s1,76(s2)
    8000412e:	c49d                	beqz	s1,8000415c <dirlink+0x54>
    80004130:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004132:	4741                	li	a4,16
    80004134:	86a6                	mv	a3,s1
    80004136:	fc040613          	add	a2,s0,-64
    8000413a:	4581                	li	a1,0
    8000413c:	854a                	mv	a0,s2
    8000413e:	00000097          	auipc	ra,0x0
    80004142:	b66080e7          	jalr	-1178(ra) # 80003ca4 <readi>
    80004146:	47c1                	li	a5,16
    80004148:	06f51163          	bne	a0,a5,800041aa <dirlink+0xa2>
    if(de.inum == 0)
    8000414c:	fc045783          	lhu	a5,-64(s0)
    80004150:	c791                	beqz	a5,8000415c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004152:	24c1                	addw	s1,s1,16
    80004154:	04c92783          	lw	a5,76(s2)
    80004158:	fcf4ede3          	bltu	s1,a5,80004132 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000415c:	4639                	li	a2,14
    8000415e:	85d2                	mv	a1,s4
    80004160:	fc240513          	add	a0,s0,-62
    80004164:	ffffd097          	auipc	ra,0xffffd
    80004168:	cd6080e7          	jalr	-810(ra) # 80000e3a <strncpy>
  de.inum = inum;
    8000416c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004170:	4741                	li	a4,16
    80004172:	86a6                	mv	a3,s1
    80004174:	fc040613          	add	a2,s0,-64
    80004178:	4581                	li	a1,0
    8000417a:	854a                	mv	a0,s2
    8000417c:	00000097          	auipc	ra,0x0
    80004180:	c38080e7          	jalr	-968(ra) # 80003db4 <writei>
    80004184:	1541                	add	a0,a0,-16
    80004186:	00a03533          	snez	a0,a0
    8000418a:	40a00533          	neg	a0,a0
    8000418e:	74a2                	ld	s1,40(sp)
}
    80004190:	70e2                	ld	ra,56(sp)
    80004192:	7442                	ld	s0,48(sp)
    80004194:	7902                	ld	s2,32(sp)
    80004196:	69e2                	ld	s3,24(sp)
    80004198:	6a42                	ld	s4,16(sp)
    8000419a:	6121                	add	sp,sp,64
    8000419c:	8082                	ret
    iput(ip);
    8000419e:	00000097          	auipc	ra,0x0
    800041a2:	a0c080e7          	jalr	-1524(ra) # 80003baa <iput>
    return -1;
    800041a6:	557d                	li	a0,-1
    800041a8:	b7e5                	j	80004190 <dirlink+0x88>
      panic("dirlink read");
    800041aa:	00004517          	auipc	a0,0x4
    800041ae:	36650513          	add	a0,a0,870 # 80008510 <etext+0x510>
    800041b2:	ffffc097          	auipc	ra,0xffffc
    800041b6:	3ae080e7          	jalr	942(ra) # 80000560 <panic>

00000000800041ba <namei>:

struct inode*
namei(char *path)
{
    800041ba:	1101                	add	sp,sp,-32
    800041bc:	ec06                	sd	ra,24(sp)
    800041be:	e822                	sd	s0,16(sp)
    800041c0:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800041c2:	fe040613          	add	a2,s0,-32
    800041c6:	4581                	li	a1,0
    800041c8:	00000097          	auipc	ra,0x0
    800041cc:	de0080e7          	jalr	-544(ra) # 80003fa8 <namex>
}
    800041d0:	60e2                	ld	ra,24(sp)
    800041d2:	6442                	ld	s0,16(sp)
    800041d4:	6105                	add	sp,sp,32
    800041d6:	8082                	ret

00000000800041d8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041d8:	1141                	add	sp,sp,-16
    800041da:	e406                	sd	ra,8(sp)
    800041dc:	e022                	sd	s0,0(sp)
    800041de:	0800                	add	s0,sp,16
    800041e0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041e2:	4585                	li	a1,1
    800041e4:	00000097          	auipc	ra,0x0
    800041e8:	dc4080e7          	jalr	-572(ra) # 80003fa8 <namex>
}
    800041ec:	60a2                	ld	ra,8(sp)
    800041ee:	6402                	ld	s0,0(sp)
    800041f0:	0141                	add	sp,sp,16
    800041f2:	8082                	ret

00000000800041f4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041f4:	1101                	add	sp,sp,-32
    800041f6:	ec06                	sd	ra,24(sp)
    800041f8:	e822                	sd	s0,16(sp)
    800041fa:	e426                	sd	s1,8(sp)
    800041fc:	e04a                	sd	s2,0(sp)
    800041fe:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004200:	0001d917          	auipc	s2,0x1d
    80004204:	92890913          	add	s2,s2,-1752 # 80020b28 <log>
    80004208:	01892583          	lw	a1,24(s2)
    8000420c:	02892503          	lw	a0,40(s2)
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	fa8080e7          	jalr	-88(ra) # 800031b8 <bread>
    80004218:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000421a:	02c92603          	lw	a2,44(s2)
    8000421e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004220:	00c05f63          	blez	a2,8000423e <write_head+0x4a>
    80004224:	0001d717          	auipc	a4,0x1d
    80004228:	93470713          	add	a4,a4,-1740 # 80020b58 <log+0x30>
    8000422c:	87aa                	mv	a5,a0
    8000422e:	060a                	sll	a2,a2,0x2
    80004230:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004232:	4314                	lw	a3,0(a4)
    80004234:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004236:	0711                	add	a4,a4,4
    80004238:	0791                	add	a5,a5,4
    8000423a:	fec79ce3          	bne	a5,a2,80004232 <write_head+0x3e>
  }
  bwrite(buf);
    8000423e:	8526                	mv	a0,s1
    80004240:	fffff097          	auipc	ra,0xfffff
    80004244:	06a080e7          	jalr	106(ra) # 800032aa <bwrite>
  brelse(buf);
    80004248:	8526                	mv	a0,s1
    8000424a:	fffff097          	auipc	ra,0xfffff
    8000424e:	09e080e7          	jalr	158(ra) # 800032e8 <brelse>
}
    80004252:	60e2                	ld	ra,24(sp)
    80004254:	6442                	ld	s0,16(sp)
    80004256:	64a2                	ld	s1,8(sp)
    80004258:	6902                	ld	s2,0(sp)
    8000425a:	6105                	add	sp,sp,32
    8000425c:	8082                	ret

000000008000425e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000425e:	0001d797          	auipc	a5,0x1d
    80004262:	8f67a783          	lw	a5,-1802(a5) # 80020b54 <log+0x2c>
    80004266:	0af05d63          	blez	a5,80004320 <install_trans+0xc2>
{
    8000426a:	7139                	add	sp,sp,-64
    8000426c:	fc06                	sd	ra,56(sp)
    8000426e:	f822                	sd	s0,48(sp)
    80004270:	f426                	sd	s1,40(sp)
    80004272:	f04a                	sd	s2,32(sp)
    80004274:	ec4e                	sd	s3,24(sp)
    80004276:	e852                	sd	s4,16(sp)
    80004278:	e456                	sd	s5,8(sp)
    8000427a:	e05a                	sd	s6,0(sp)
    8000427c:	0080                	add	s0,sp,64
    8000427e:	8b2a                	mv	s6,a0
    80004280:	0001da97          	auipc	s5,0x1d
    80004284:	8d8a8a93          	add	s5,s5,-1832 # 80020b58 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004288:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000428a:	0001d997          	auipc	s3,0x1d
    8000428e:	89e98993          	add	s3,s3,-1890 # 80020b28 <log>
    80004292:	a00d                	j	800042b4 <install_trans+0x56>
    brelse(lbuf);
    80004294:	854a                	mv	a0,s2
    80004296:	fffff097          	auipc	ra,0xfffff
    8000429a:	052080e7          	jalr	82(ra) # 800032e8 <brelse>
    brelse(dbuf);
    8000429e:	8526                	mv	a0,s1
    800042a0:	fffff097          	auipc	ra,0xfffff
    800042a4:	048080e7          	jalr	72(ra) # 800032e8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042a8:	2a05                	addw	s4,s4,1
    800042aa:	0a91                	add	s5,s5,4
    800042ac:	02c9a783          	lw	a5,44(s3)
    800042b0:	04fa5e63          	bge	s4,a5,8000430c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042b4:	0189a583          	lw	a1,24(s3)
    800042b8:	014585bb          	addw	a1,a1,s4
    800042bc:	2585                	addw	a1,a1,1
    800042be:	0289a503          	lw	a0,40(s3)
    800042c2:	fffff097          	auipc	ra,0xfffff
    800042c6:	ef6080e7          	jalr	-266(ra) # 800031b8 <bread>
    800042ca:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800042cc:	000aa583          	lw	a1,0(s5)
    800042d0:	0289a503          	lw	a0,40(s3)
    800042d4:	fffff097          	auipc	ra,0xfffff
    800042d8:	ee4080e7          	jalr	-284(ra) # 800031b8 <bread>
    800042dc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042de:	40000613          	li	a2,1024
    800042e2:	05890593          	add	a1,s2,88
    800042e6:	05850513          	add	a0,a0,88
    800042ea:	ffffd097          	auipc	ra,0xffffd
    800042ee:	aa6080e7          	jalr	-1370(ra) # 80000d90 <memmove>
    bwrite(dbuf);  // write dst to disk
    800042f2:	8526                	mv	a0,s1
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	fb6080e7          	jalr	-74(ra) # 800032aa <bwrite>
    if(recovering == 0)
    800042fc:	f80b1ce3          	bnez	s6,80004294 <install_trans+0x36>
      bunpin(dbuf);
    80004300:	8526                	mv	a0,s1
    80004302:	fffff097          	auipc	ra,0xfffff
    80004306:	0be080e7          	jalr	190(ra) # 800033c0 <bunpin>
    8000430a:	b769                	j	80004294 <install_trans+0x36>
}
    8000430c:	70e2                	ld	ra,56(sp)
    8000430e:	7442                	ld	s0,48(sp)
    80004310:	74a2                	ld	s1,40(sp)
    80004312:	7902                	ld	s2,32(sp)
    80004314:	69e2                	ld	s3,24(sp)
    80004316:	6a42                	ld	s4,16(sp)
    80004318:	6aa2                	ld	s5,8(sp)
    8000431a:	6b02                	ld	s6,0(sp)
    8000431c:	6121                	add	sp,sp,64
    8000431e:	8082                	ret
    80004320:	8082                	ret

0000000080004322 <initlog>:
{
    80004322:	7179                	add	sp,sp,-48
    80004324:	f406                	sd	ra,40(sp)
    80004326:	f022                	sd	s0,32(sp)
    80004328:	ec26                	sd	s1,24(sp)
    8000432a:	e84a                	sd	s2,16(sp)
    8000432c:	e44e                	sd	s3,8(sp)
    8000432e:	1800                	add	s0,sp,48
    80004330:	892a                	mv	s2,a0
    80004332:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004334:	0001c497          	auipc	s1,0x1c
    80004338:	7f448493          	add	s1,s1,2036 # 80020b28 <log>
    8000433c:	00004597          	auipc	a1,0x4
    80004340:	1e458593          	add	a1,a1,484 # 80008520 <etext+0x520>
    80004344:	8526                	mv	a0,s1
    80004346:	ffffd097          	auipc	ra,0xffffd
    8000434a:	862080e7          	jalr	-1950(ra) # 80000ba8 <initlock>
  log.start = sb->logstart;
    8000434e:	0149a583          	lw	a1,20(s3)
    80004352:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004354:	0109a783          	lw	a5,16(s3)
    80004358:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000435a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000435e:	854a                	mv	a0,s2
    80004360:	fffff097          	auipc	ra,0xfffff
    80004364:	e58080e7          	jalr	-424(ra) # 800031b8 <bread>
  log.lh.n = lh->n;
    80004368:	4d30                	lw	a2,88(a0)
    8000436a:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000436c:	00c05f63          	blez	a2,8000438a <initlog+0x68>
    80004370:	87aa                	mv	a5,a0
    80004372:	0001c717          	auipc	a4,0x1c
    80004376:	7e670713          	add	a4,a4,2022 # 80020b58 <log+0x30>
    8000437a:	060a                	sll	a2,a2,0x2
    8000437c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000437e:	4ff4                	lw	a3,92(a5)
    80004380:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004382:	0791                	add	a5,a5,4
    80004384:	0711                	add	a4,a4,4
    80004386:	fec79ce3          	bne	a5,a2,8000437e <initlog+0x5c>
  brelse(buf);
    8000438a:	fffff097          	auipc	ra,0xfffff
    8000438e:	f5e080e7          	jalr	-162(ra) # 800032e8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004392:	4505                	li	a0,1
    80004394:	00000097          	auipc	ra,0x0
    80004398:	eca080e7          	jalr	-310(ra) # 8000425e <install_trans>
  log.lh.n = 0;
    8000439c:	0001c797          	auipc	a5,0x1c
    800043a0:	7a07ac23          	sw	zero,1976(a5) # 80020b54 <log+0x2c>
  write_head(); // clear the log
    800043a4:	00000097          	auipc	ra,0x0
    800043a8:	e50080e7          	jalr	-432(ra) # 800041f4 <write_head>
}
    800043ac:	70a2                	ld	ra,40(sp)
    800043ae:	7402                	ld	s0,32(sp)
    800043b0:	64e2                	ld	s1,24(sp)
    800043b2:	6942                	ld	s2,16(sp)
    800043b4:	69a2                	ld	s3,8(sp)
    800043b6:	6145                	add	sp,sp,48
    800043b8:	8082                	ret

00000000800043ba <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043ba:	1101                	add	sp,sp,-32
    800043bc:	ec06                	sd	ra,24(sp)
    800043be:	e822                	sd	s0,16(sp)
    800043c0:	e426                	sd	s1,8(sp)
    800043c2:	e04a                	sd	s2,0(sp)
    800043c4:	1000                	add	s0,sp,32
  acquire(&log.lock);
    800043c6:	0001c517          	auipc	a0,0x1c
    800043ca:	76250513          	add	a0,a0,1890 # 80020b28 <log>
    800043ce:	ffffd097          	auipc	ra,0xffffd
    800043d2:	86a080e7          	jalr	-1942(ra) # 80000c38 <acquire>
  while(1){
    if(log.committing){
    800043d6:	0001c497          	auipc	s1,0x1c
    800043da:	75248493          	add	s1,s1,1874 # 80020b28 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043de:	4979                	li	s2,30
    800043e0:	a039                	j	800043ee <begin_op+0x34>
      sleep(&log, &log.lock);
    800043e2:	85a6                	mv	a1,s1
    800043e4:	8526                	mv	a0,s1
    800043e6:	ffffe097          	auipc	ra,0xffffe
    800043ea:	fa4080e7          	jalr	-92(ra) # 8000238a <sleep>
    if(log.committing){
    800043ee:	50dc                	lw	a5,36(s1)
    800043f0:	fbed                	bnez	a5,800043e2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043f2:	5098                	lw	a4,32(s1)
    800043f4:	2705                	addw	a4,a4,1
    800043f6:	0027179b          	sllw	a5,a4,0x2
    800043fa:	9fb9                	addw	a5,a5,a4
    800043fc:	0017979b          	sllw	a5,a5,0x1
    80004400:	54d4                	lw	a3,44(s1)
    80004402:	9fb5                	addw	a5,a5,a3
    80004404:	00f95963          	bge	s2,a5,80004416 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004408:	85a6                	mv	a1,s1
    8000440a:	8526                	mv	a0,s1
    8000440c:	ffffe097          	auipc	ra,0xffffe
    80004410:	f7e080e7          	jalr	-130(ra) # 8000238a <sleep>
    80004414:	bfe9                	j	800043ee <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004416:	0001c517          	auipc	a0,0x1c
    8000441a:	71250513          	add	a0,a0,1810 # 80020b28 <log>
    8000441e:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004420:	ffffd097          	auipc	ra,0xffffd
    80004424:	8cc080e7          	jalr	-1844(ra) # 80000cec <release>
      break;
    }
  }
}
    80004428:	60e2                	ld	ra,24(sp)
    8000442a:	6442                	ld	s0,16(sp)
    8000442c:	64a2                	ld	s1,8(sp)
    8000442e:	6902                	ld	s2,0(sp)
    80004430:	6105                	add	sp,sp,32
    80004432:	8082                	ret

0000000080004434 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004434:	7139                	add	sp,sp,-64
    80004436:	fc06                	sd	ra,56(sp)
    80004438:	f822                	sd	s0,48(sp)
    8000443a:	f426                	sd	s1,40(sp)
    8000443c:	f04a                	sd	s2,32(sp)
    8000443e:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004440:	0001c497          	auipc	s1,0x1c
    80004444:	6e848493          	add	s1,s1,1768 # 80020b28 <log>
    80004448:	8526                	mv	a0,s1
    8000444a:	ffffc097          	auipc	ra,0xffffc
    8000444e:	7ee080e7          	jalr	2030(ra) # 80000c38 <acquire>
  log.outstanding -= 1;
    80004452:	509c                	lw	a5,32(s1)
    80004454:	37fd                	addw	a5,a5,-1
    80004456:	0007891b          	sext.w	s2,a5
    8000445a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000445c:	50dc                	lw	a5,36(s1)
    8000445e:	e7b9                	bnez	a5,800044ac <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    80004460:	06091163          	bnez	s2,800044c2 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004464:	0001c497          	auipc	s1,0x1c
    80004468:	6c448493          	add	s1,s1,1732 # 80020b28 <log>
    8000446c:	4785                	li	a5,1
    8000446e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004470:	8526                	mv	a0,s1
    80004472:	ffffd097          	auipc	ra,0xffffd
    80004476:	87a080e7          	jalr	-1926(ra) # 80000cec <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000447a:	54dc                	lw	a5,44(s1)
    8000447c:	06f04763          	bgtz	a5,800044ea <end_op+0xb6>
    acquire(&log.lock);
    80004480:	0001c497          	auipc	s1,0x1c
    80004484:	6a848493          	add	s1,s1,1704 # 80020b28 <log>
    80004488:	8526                	mv	a0,s1
    8000448a:	ffffc097          	auipc	ra,0xffffc
    8000448e:	7ae080e7          	jalr	1966(ra) # 80000c38 <acquire>
    log.committing = 0;
    80004492:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004496:	8526                	mv	a0,s1
    80004498:	ffffe097          	auipc	ra,0xffffe
    8000449c:	f56080e7          	jalr	-170(ra) # 800023ee <wakeup>
    release(&log.lock);
    800044a0:	8526                	mv	a0,s1
    800044a2:	ffffd097          	auipc	ra,0xffffd
    800044a6:	84a080e7          	jalr	-1974(ra) # 80000cec <release>
}
    800044aa:	a815                	j	800044de <end_op+0xaa>
    800044ac:	ec4e                	sd	s3,24(sp)
    800044ae:	e852                	sd	s4,16(sp)
    800044b0:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800044b2:	00004517          	auipc	a0,0x4
    800044b6:	07650513          	add	a0,a0,118 # 80008528 <etext+0x528>
    800044ba:	ffffc097          	auipc	ra,0xffffc
    800044be:	0a6080e7          	jalr	166(ra) # 80000560 <panic>
    wakeup(&log);
    800044c2:	0001c497          	auipc	s1,0x1c
    800044c6:	66648493          	add	s1,s1,1638 # 80020b28 <log>
    800044ca:	8526                	mv	a0,s1
    800044cc:	ffffe097          	auipc	ra,0xffffe
    800044d0:	f22080e7          	jalr	-222(ra) # 800023ee <wakeup>
  release(&log.lock);
    800044d4:	8526                	mv	a0,s1
    800044d6:	ffffd097          	auipc	ra,0xffffd
    800044da:	816080e7          	jalr	-2026(ra) # 80000cec <release>
}
    800044de:	70e2                	ld	ra,56(sp)
    800044e0:	7442                	ld	s0,48(sp)
    800044e2:	74a2                	ld	s1,40(sp)
    800044e4:	7902                	ld	s2,32(sp)
    800044e6:	6121                	add	sp,sp,64
    800044e8:	8082                	ret
    800044ea:	ec4e                	sd	s3,24(sp)
    800044ec:	e852                	sd	s4,16(sp)
    800044ee:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800044f0:	0001ca97          	auipc	s5,0x1c
    800044f4:	668a8a93          	add	s5,s5,1640 # 80020b58 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044f8:	0001ca17          	auipc	s4,0x1c
    800044fc:	630a0a13          	add	s4,s4,1584 # 80020b28 <log>
    80004500:	018a2583          	lw	a1,24(s4)
    80004504:	012585bb          	addw	a1,a1,s2
    80004508:	2585                	addw	a1,a1,1
    8000450a:	028a2503          	lw	a0,40(s4)
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	caa080e7          	jalr	-854(ra) # 800031b8 <bread>
    80004516:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004518:	000aa583          	lw	a1,0(s5)
    8000451c:	028a2503          	lw	a0,40(s4)
    80004520:	fffff097          	auipc	ra,0xfffff
    80004524:	c98080e7          	jalr	-872(ra) # 800031b8 <bread>
    80004528:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000452a:	40000613          	li	a2,1024
    8000452e:	05850593          	add	a1,a0,88
    80004532:	05848513          	add	a0,s1,88
    80004536:	ffffd097          	auipc	ra,0xffffd
    8000453a:	85a080e7          	jalr	-1958(ra) # 80000d90 <memmove>
    bwrite(to);  // write the log
    8000453e:	8526                	mv	a0,s1
    80004540:	fffff097          	auipc	ra,0xfffff
    80004544:	d6a080e7          	jalr	-662(ra) # 800032aa <bwrite>
    brelse(from);
    80004548:	854e                	mv	a0,s3
    8000454a:	fffff097          	auipc	ra,0xfffff
    8000454e:	d9e080e7          	jalr	-610(ra) # 800032e8 <brelse>
    brelse(to);
    80004552:	8526                	mv	a0,s1
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	d94080e7          	jalr	-620(ra) # 800032e8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000455c:	2905                	addw	s2,s2,1
    8000455e:	0a91                	add	s5,s5,4
    80004560:	02ca2783          	lw	a5,44(s4)
    80004564:	f8f94ee3          	blt	s2,a5,80004500 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004568:	00000097          	auipc	ra,0x0
    8000456c:	c8c080e7          	jalr	-884(ra) # 800041f4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004570:	4501                	li	a0,0
    80004572:	00000097          	auipc	ra,0x0
    80004576:	cec080e7          	jalr	-788(ra) # 8000425e <install_trans>
    log.lh.n = 0;
    8000457a:	0001c797          	auipc	a5,0x1c
    8000457e:	5c07ad23          	sw	zero,1498(a5) # 80020b54 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004582:	00000097          	auipc	ra,0x0
    80004586:	c72080e7          	jalr	-910(ra) # 800041f4 <write_head>
    8000458a:	69e2                	ld	s3,24(sp)
    8000458c:	6a42                	ld	s4,16(sp)
    8000458e:	6aa2                	ld	s5,8(sp)
    80004590:	bdc5                	j	80004480 <end_op+0x4c>

0000000080004592 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004592:	1101                	add	sp,sp,-32
    80004594:	ec06                	sd	ra,24(sp)
    80004596:	e822                	sd	s0,16(sp)
    80004598:	e426                	sd	s1,8(sp)
    8000459a:	e04a                	sd	s2,0(sp)
    8000459c:	1000                	add	s0,sp,32
    8000459e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800045a0:	0001c917          	auipc	s2,0x1c
    800045a4:	58890913          	add	s2,s2,1416 # 80020b28 <log>
    800045a8:	854a                	mv	a0,s2
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	68e080e7          	jalr	1678(ra) # 80000c38 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800045b2:	02c92603          	lw	a2,44(s2)
    800045b6:	47f5                	li	a5,29
    800045b8:	06c7c563          	blt	a5,a2,80004622 <log_write+0x90>
    800045bc:	0001c797          	auipc	a5,0x1c
    800045c0:	5887a783          	lw	a5,1416(a5) # 80020b44 <log+0x1c>
    800045c4:	37fd                	addw	a5,a5,-1
    800045c6:	04f65e63          	bge	a2,a5,80004622 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045ca:	0001c797          	auipc	a5,0x1c
    800045ce:	57e7a783          	lw	a5,1406(a5) # 80020b48 <log+0x20>
    800045d2:	06f05063          	blez	a5,80004632 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045d6:	4781                	li	a5,0
    800045d8:	06c05563          	blez	a2,80004642 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045dc:	44cc                	lw	a1,12(s1)
    800045de:	0001c717          	auipc	a4,0x1c
    800045e2:	57a70713          	add	a4,a4,1402 # 80020b58 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800045e6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045e8:	4314                	lw	a3,0(a4)
    800045ea:	04b68c63          	beq	a3,a1,80004642 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800045ee:	2785                	addw	a5,a5,1
    800045f0:	0711                	add	a4,a4,4
    800045f2:	fef61be3          	bne	a2,a5,800045e8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045f6:	0621                	add	a2,a2,8
    800045f8:	060a                	sll	a2,a2,0x2
    800045fa:	0001c797          	auipc	a5,0x1c
    800045fe:	52e78793          	add	a5,a5,1326 # 80020b28 <log>
    80004602:	97b2                	add	a5,a5,a2
    80004604:	44d8                	lw	a4,12(s1)
    80004606:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004608:	8526                	mv	a0,s1
    8000460a:	fffff097          	auipc	ra,0xfffff
    8000460e:	d7a080e7          	jalr	-646(ra) # 80003384 <bpin>
    log.lh.n++;
    80004612:	0001c717          	auipc	a4,0x1c
    80004616:	51670713          	add	a4,a4,1302 # 80020b28 <log>
    8000461a:	575c                	lw	a5,44(a4)
    8000461c:	2785                	addw	a5,a5,1
    8000461e:	d75c                	sw	a5,44(a4)
    80004620:	a82d                	j	8000465a <log_write+0xc8>
    panic("too big a transaction");
    80004622:	00004517          	auipc	a0,0x4
    80004626:	f1650513          	add	a0,a0,-234 # 80008538 <etext+0x538>
    8000462a:	ffffc097          	auipc	ra,0xffffc
    8000462e:	f36080e7          	jalr	-202(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004632:	00004517          	auipc	a0,0x4
    80004636:	f1e50513          	add	a0,a0,-226 # 80008550 <etext+0x550>
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	f26080e7          	jalr	-218(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004642:	00878693          	add	a3,a5,8
    80004646:	068a                	sll	a3,a3,0x2
    80004648:	0001c717          	auipc	a4,0x1c
    8000464c:	4e070713          	add	a4,a4,1248 # 80020b28 <log>
    80004650:	9736                	add	a4,a4,a3
    80004652:	44d4                	lw	a3,12(s1)
    80004654:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004656:	faf609e3          	beq	a2,a5,80004608 <log_write+0x76>
  }
  release(&log.lock);
    8000465a:	0001c517          	auipc	a0,0x1c
    8000465e:	4ce50513          	add	a0,a0,1230 # 80020b28 <log>
    80004662:	ffffc097          	auipc	ra,0xffffc
    80004666:	68a080e7          	jalr	1674(ra) # 80000cec <release>
}
    8000466a:	60e2                	ld	ra,24(sp)
    8000466c:	6442                	ld	s0,16(sp)
    8000466e:	64a2                	ld	s1,8(sp)
    80004670:	6902                	ld	s2,0(sp)
    80004672:	6105                	add	sp,sp,32
    80004674:	8082                	ret

0000000080004676 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004676:	1101                	add	sp,sp,-32
    80004678:	ec06                	sd	ra,24(sp)
    8000467a:	e822                	sd	s0,16(sp)
    8000467c:	e426                	sd	s1,8(sp)
    8000467e:	e04a                	sd	s2,0(sp)
    80004680:	1000                	add	s0,sp,32
    80004682:	84aa                	mv	s1,a0
    80004684:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004686:	00004597          	auipc	a1,0x4
    8000468a:	eea58593          	add	a1,a1,-278 # 80008570 <etext+0x570>
    8000468e:	0521                	add	a0,a0,8
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	518080e7          	jalr	1304(ra) # 80000ba8 <initlock>
  lk->name = name;
    80004698:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000469c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046a0:	0204a423          	sw	zero,40(s1)
}
    800046a4:	60e2                	ld	ra,24(sp)
    800046a6:	6442                	ld	s0,16(sp)
    800046a8:	64a2                	ld	s1,8(sp)
    800046aa:	6902                	ld	s2,0(sp)
    800046ac:	6105                	add	sp,sp,32
    800046ae:	8082                	ret

00000000800046b0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800046b0:	1101                	add	sp,sp,-32
    800046b2:	ec06                	sd	ra,24(sp)
    800046b4:	e822                	sd	s0,16(sp)
    800046b6:	e426                	sd	s1,8(sp)
    800046b8:	e04a                	sd	s2,0(sp)
    800046ba:	1000                	add	s0,sp,32
    800046bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046be:	00850913          	add	s2,a0,8
    800046c2:	854a                	mv	a0,s2
    800046c4:	ffffc097          	auipc	ra,0xffffc
    800046c8:	574080e7          	jalr	1396(ra) # 80000c38 <acquire>
  while (lk->locked) {
    800046cc:	409c                	lw	a5,0(s1)
    800046ce:	cb89                	beqz	a5,800046e0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046d0:	85ca                	mv	a1,s2
    800046d2:	8526                	mv	a0,s1
    800046d4:	ffffe097          	auipc	ra,0xffffe
    800046d8:	cb6080e7          	jalr	-842(ra) # 8000238a <sleep>
  while (lk->locked) {
    800046dc:	409c                	lw	a5,0(s1)
    800046de:	fbed                	bnez	a5,800046d0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046e0:	4785                	li	a5,1
    800046e2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046e4:	ffffd097          	auipc	ra,0xffffd
    800046e8:	37e080e7          	jalr	894(ra) # 80001a62 <myproc>
    800046ec:	591c                	lw	a5,48(a0)
    800046ee:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046f0:	854a                	mv	a0,s2
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	5fa080e7          	jalr	1530(ra) # 80000cec <release>
}
    800046fa:	60e2                	ld	ra,24(sp)
    800046fc:	6442                	ld	s0,16(sp)
    800046fe:	64a2                	ld	s1,8(sp)
    80004700:	6902                	ld	s2,0(sp)
    80004702:	6105                	add	sp,sp,32
    80004704:	8082                	ret

0000000080004706 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004706:	1101                	add	sp,sp,-32
    80004708:	ec06                	sd	ra,24(sp)
    8000470a:	e822                	sd	s0,16(sp)
    8000470c:	e426                	sd	s1,8(sp)
    8000470e:	e04a                	sd	s2,0(sp)
    80004710:	1000                	add	s0,sp,32
    80004712:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004714:	00850913          	add	s2,a0,8
    80004718:	854a                	mv	a0,s2
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	51e080e7          	jalr	1310(ra) # 80000c38 <acquire>
  lk->locked = 0;
    80004722:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004726:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000472a:	8526                	mv	a0,s1
    8000472c:	ffffe097          	auipc	ra,0xffffe
    80004730:	cc2080e7          	jalr	-830(ra) # 800023ee <wakeup>
  release(&lk->lk);
    80004734:	854a                	mv	a0,s2
    80004736:	ffffc097          	auipc	ra,0xffffc
    8000473a:	5b6080e7          	jalr	1462(ra) # 80000cec <release>
}
    8000473e:	60e2                	ld	ra,24(sp)
    80004740:	6442                	ld	s0,16(sp)
    80004742:	64a2                	ld	s1,8(sp)
    80004744:	6902                	ld	s2,0(sp)
    80004746:	6105                	add	sp,sp,32
    80004748:	8082                	ret

000000008000474a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000474a:	7179                	add	sp,sp,-48
    8000474c:	f406                	sd	ra,40(sp)
    8000474e:	f022                	sd	s0,32(sp)
    80004750:	ec26                	sd	s1,24(sp)
    80004752:	e84a                	sd	s2,16(sp)
    80004754:	1800                	add	s0,sp,48
    80004756:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004758:	00850913          	add	s2,a0,8
    8000475c:	854a                	mv	a0,s2
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	4da080e7          	jalr	1242(ra) # 80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004766:	409c                	lw	a5,0(s1)
    80004768:	ef91                	bnez	a5,80004784 <holdingsleep+0x3a>
    8000476a:	4481                	li	s1,0
  release(&lk->lk);
    8000476c:	854a                	mv	a0,s2
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	57e080e7          	jalr	1406(ra) # 80000cec <release>
  return r;
}
    80004776:	8526                	mv	a0,s1
    80004778:	70a2                	ld	ra,40(sp)
    8000477a:	7402                	ld	s0,32(sp)
    8000477c:	64e2                	ld	s1,24(sp)
    8000477e:	6942                	ld	s2,16(sp)
    80004780:	6145                	add	sp,sp,48
    80004782:	8082                	ret
    80004784:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004786:	0284a983          	lw	s3,40(s1)
    8000478a:	ffffd097          	auipc	ra,0xffffd
    8000478e:	2d8080e7          	jalr	728(ra) # 80001a62 <myproc>
    80004792:	5904                	lw	s1,48(a0)
    80004794:	413484b3          	sub	s1,s1,s3
    80004798:	0014b493          	seqz	s1,s1
    8000479c:	69a2                	ld	s3,8(sp)
    8000479e:	b7f9                	j	8000476c <holdingsleep+0x22>

00000000800047a0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800047a0:	1141                	add	sp,sp,-16
    800047a2:	e406                	sd	ra,8(sp)
    800047a4:	e022                	sd	s0,0(sp)
    800047a6:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800047a8:	00004597          	auipc	a1,0x4
    800047ac:	dd858593          	add	a1,a1,-552 # 80008580 <etext+0x580>
    800047b0:	0001c517          	auipc	a0,0x1c
    800047b4:	4c050513          	add	a0,a0,1216 # 80020c70 <ftable>
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	3f0080e7          	jalr	1008(ra) # 80000ba8 <initlock>
}
    800047c0:	60a2                	ld	ra,8(sp)
    800047c2:	6402                	ld	s0,0(sp)
    800047c4:	0141                	add	sp,sp,16
    800047c6:	8082                	ret

00000000800047c8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047c8:	1101                	add	sp,sp,-32
    800047ca:	ec06                	sd	ra,24(sp)
    800047cc:	e822                	sd	s0,16(sp)
    800047ce:	e426                	sd	s1,8(sp)
    800047d0:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047d2:	0001c517          	auipc	a0,0x1c
    800047d6:	49e50513          	add	a0,a0,1182 # 80020c70 <ftable>
    800047da:	ffffc097          	auipc	ra,0xffffc
    800047de:	45e080e7          	jalr	1118(ra) # 80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047e2:	0001c497          	auipc	s1,0x1c
    800047e6:	4a648493          	add	s1,s1,1190 # 80020c88 <ftable+0x18>
    800047ea:	0001d717          	auipc	a4,0x1d
    800047ee:	43e70713          	add	a4,a4,1086 # 80021c28 <disk>
    if(f->ref == 0){
    800047f2:	40dc                	lw	a5,4(s1)
    800047f4:	cf99                	beqz	a5,80004812 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047f6:	02848493          	add	s1,s1,40
    800047fa:	fee49ce3          	bne	s1,a4,800047f2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047fe:	0001c517          	auipc	a0,0x1c
    80004802:	47250513          	add	a0,a0,1138 # 80020c70 <ftable>
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	4e6080e7          	jalr	1254(ra) # 80000cec <release>
  return 0;
    8000480e:	4481                	li	s1,0
    80004810:	a819                	j	80004826 <filealloc+0x5e>
      f->ref = 1;
    80004812:	4785                	li	a5,1
    80004814:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004816:	0001c517          	auipc	a0,0x1c
    8000481a:	45a50513          	add	a0,a0,1114 # 80020c70 <ftable>
    8000481e:	ffffc097          	auipc	ra,0xffffc
    80004822:	4ce080e7          	jalr	1230(ra) # 80000cec <release>
}
    80004826:	8526                	mv	a0,s1
    80004828:	60e2                	ld	ra,24(sp)
    8000482a:	6442                	ld	s0,16(sp)
    8000482c:	64a2                	ld	s1,8(sp)
    8000482e:	6105                	add	sp,sp,32
    80004830:	8082                	ret

0000000080004832 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004832:	1101                	add	sp,sp,-32
    80004834:	ec06                	sd	ra,24(sp)
    80004836:	e822                	sd	s0,16(sp)
    80004838:	e426                	sd	s1,8(sp)
    8000483a:	1000                	add	s0,sp,32
    8000483c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000483e:	0001c517          	auipc	a0,0x1c
    80004842:	43250513          	add	a0,a0,1074 # 80020c70 <ftable>
    80004846:	ffffc097          	auipc	ra,0xffffc
    8000484a:	3f2080e7          	jalr	1010(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    8000484e:	40dc                	lw	a5,4(s1)
    80004850:	02f05263          	blez	a5,80004874 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004854:	2785                	addw	a5,a5,1
    80004856:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004858:	0001c517          	auipc	a0,0x1c
    8000485c:	41850513          	add	a0,a0,1048 # 80020c70 <ftable>
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	48c080e7          	jalr	1164(ra) # 80000cec <release>
  return f;
}
    80004868:	8526                	mv	a0,s1
    8000486a:	60e2                	ld	ra,24(sp)
    8000486c:	6442                	ld	s0,16(sp)
    8000486e:	64a2                	ld	s1,8(sp)
    80004870:	6105                	add	sp,sp,32
    80004872:	8082                	ret
    panic("filedup");
    80004874:	00004517          	auipc	a0,0x4
    80004878:	d1450513          	add	a0,a0,-748 # 80008588 <etext+0x588>
    8000487c:	ffffc097          	auipc	ra,0xffffc
    80004880:	ce4080e7          	jalr	-796(ra) # 80000560 <panic>

0000000080004884 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004884:	7139                	add	sp,sp,-64
    80004886:	fc06                	sd	ra,56(sp)
    80004888:	f822                	sd	s0,48(sp)
    8000488a:	f426                	sd	s1,40(sp)
    8000488c:	0080                	add	s0,sp,64
    8000488e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004890:	0001c517          	auipc	a0,0x1c
    80004894:	3e050513          	add	a0,a0,992 # 80020c70 <ftable>
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	3a0080e7          	jalr	928(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    800048a0:	40dc                	lw	a5,4(s1)
    800048a2:	04f05c63          	blez	a5,800048fa <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    800048a6:	37fd                	addw	a5,a5,-1
    800048a8:	0007871b          	sext.w	a4,a5
    800048ac:	c0dc                	sw	a5,4(s1)
    800048ae:	06e04263          	bgtz	a4,80004912 <fileclose+0x8e>
    800048b2:	f04a                	sd	s2,32(sp)
    800048b4:	ec4e                	sd	s3,24(sp)
    800048b6:	e852                	sd	s4,16(sp)
    800048b8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800048ba:	0004a903          	lw	s2,0(s1)
    800048be:	0094ca83          	lbu	s5,9(s1)
    800048c2:	0104ba03          	ld	s4,16(s1)
    800048c6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048ca:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048ce:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048d2:	0001c517          	auipc	a0,0x1c
    800048d6:	39e50513          	add	a0,a0,926 # 80020c70 <ftable>
    800048da:	ffffc097          	auipc	ra,0xffffc
    800048de:	412080e7          	jalr	1042(ra) # 80000cec <release>

  if(ff.type == FD_PIPE){
    800048e2:	4785                	li	a5,1
    800048e4:	04f90463          	beq	s2,a5,8000492c <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048e8:	3979                	addw	s2,s2,-2
    800048ea:	4785                	li	a5,1
    800048ec:	0527fb63          	bgeu	a5,s2,80004942 <fileclose+0xbe>
    800048f0:	7902                	ld	s2,32(sp)
    800048f2:	69e2                	ld	s3,24(sp)
    800048f4:	6a42                	ld	s4,16(sp)
    800048f6:	6aa2                	ld	s5,8(sp)
    800048f8:	a02d                	j	80004922 <fileclose+0x9e>
    800048fa:	f04a                	sd	s2,32(sp)
    800048fc:	ec4e                	sd	s3,24(sp)
    800048fe:	e852                	sd	s4,16(sp)
    80004900:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004902:	00004517          	auipc	a0,0x4
    80004906:	c8e50513          	add	a0,a0,-882 # 80008590 <etext+0x590>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	c56080e7          	jalr	-938(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004912:	0001c517          	auipc	a0,0x1c
    80004916:	35e50513          	add	a0,a0,862 # 80020c70 <ftable>
    8000491a:	ffffc097          	auipc	ra,0xffffc
    8000491e:	3d2080e7          	jalr	978(ra) # 80000cec <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004922:	70e2                	ld	ra,56(sp)
    80004924:	7442                	ld	s0,48(sp)
    80004926:	74a2                	ld	s1,40(sp)
    80004928:	6121                	add	sp,sp,64
    8000492a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000492c:	85d6                	mv	a1,s5
    8000492e:	8552                	mv	a0,s4
    80004930:	00000097          	auipc	ra,0x0
    80004934:	3a2080e7          	jalr	930(ra) # 80004cd2 <pipeclose>
    80004938:	7902                	ld	s2,32(sp)
    8000493a:	69e2                	ld	s3,24(sp)
    8000493c:	6a42                	ld	s4,16(sp)
    8000493e:	6aa2                	ld	s5,8(sp)
    80004940:	b7cd                	j	80004922 <fileclose+0x9e>
    begin_op();
    80004942:	00000097          	auipc	ra,0x0
    80004946:	a78080e7          	jalr	-1416(ra) # 800043ba <begin_op>
    iput(ff.ip);
    8000494a:	854e                	mv	a0,s3
    8000494c:	fffff097          	auipc	ra,0xfffff
    80004950:	25e080e7          	jalr	606(ra) # 80003baa <iput>
    end_op();
    80004954:	00000097          	auipc	ra,0x0
    80004958:	ae0080e7          	jalr	-1312(ra) # 80004434 <end_op>
    8000495c:	7902                	ld	s2,32(sp)
    8000495e:	69e2                	ld	s3,24(sp)
    80004960:	6a42                	ld	s4,16(sp)
    80004962:	6aa2                	ld	s5,8(sp)
    80004964:	bf7d                	j	80004922 <fileclose+0x9e>

0000000080004966 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004966:	715d                	add	sp,sp,-80
    80004968:	e486                	sd	ra,72(sp)
    8000496a:	e0a2                	sd	s0,64(sp)
    8000496c:	fc26                	sd	s1,56(sp)
    8000496e:	f44e                	sd	s3,40(sp)
    80004970:	0880                	add	s0,sp,80
    80004972:	84aa                	mv	s1,a0
    80004974:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004976:	ffffd097          	auipc	ra,0xffffd
    8000497a:	0ec080e7          	jalr	236(ra) # 80001a62 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000497e:	409c                	lw	a5,0(s1)
    80004980:	37f9                	addw	a5,a5,-2
    80004982:	4705                	li	a4,1
    80004984:	04f76863          	bltu	a4,a5,800049d4 <filestat+0x6e>
    80004988:	f84a                	sd	s2,48(sp)
    8000498a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000498c:	6c88                	ld	a0,24(s1)
    8000498e:	fffff097          	auipc	ra,0xfffff
    80004992:	05e080e7          	jalr	94(ra) # 800039ec <ilock>
    stati(f->ip, &st);
    80004996:	fb840593          	add	a1,s0,-72
    8000499a:	6c88                	ld	a0,24(s1)
    8000499c:	fffff097          	auipc	ra,0xfffff
    800049a0:	2de080e7          	jalr	734(ra) # 80003c7a <stati>
    iunlock(f->ip);
    800049a4:	6c88                	ld	a0,24(s1)
    800049a6:	fffff097          	auipc	ra,0xfffff
    800049aa:	10c080e7          	jalr	268(ra) # 80003ab2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800049ae:	46e1                	li	a3,24
    800049b0:	fb840613          	add	a2,s0,-72
    800049b4:	85ce                	mv	a1,s3
    800049b6:	05093503          	ld	a0,80(s2)
    800049ba:	ffffd097          	auipc	ra,0xffffd
    800049be:	d28080e7          	jalr	-728(ra) # 800016e2 <copyout>
    800049c2:	41f5551b          	sraw	a0,a0,0x1f
    800049c6:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800049c8:	60a6                	ld	ra,72(sp)
    800049ca:	6406                	ld	s0,64(sp)
    800049cc:	74e2                	ld	s1,56(sp)
    800049ce:	79a2                	ld	s3,40(sp)
    800049d0:	6161                	add	sp,sp,80
    800049d2:	8082                	ret
  return -1;
    800049d4:	557d                	li	a0,-1
    800049d6:	bfcd                	j	800049c8 <filestat+0x62>

00000000800049d8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800049d8:	7179                	add	sp,sp,-48
    800049da:	f406                	sd	ra,40(sp)
    800049dc:	f022                	sd	s0,32(sp)
    800049de:	e84a                	sd	s2,16(sp)
    800049e0:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049e2:	00854783          	lbu	a5,8(a0)
    800049e6:	cbc5                	beqz	a5,80004a96 <fileread+0xbe>
    800049e8:	ec26                	sd	s1,24(sp)
    800049ea:	e44e                	sd	s3,8(sp)
    800049ec:	84aa                	mv	s1,a0
    800049ee:	89ae                	mv	s3,a1
    800049f0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800049f2:	411c                	lw	a5,0(a0)
    800049f4:	4705                	li	a4,1
    800049f6:	04e78963          	beq	a5,a4,80004a48 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049fa:	470d                	li	a4,3
    800049fc:	04e78f63          	beq	a5,a4,80004a5a <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a00:	4709                	li	a4,2
    80004a02:	08e79263          	bne	a5,a4,80004a86 <fileread+0xae>
    ilock(f->ip);
    80004a06:	6d08                	ld	a0,24(a0)
    80004a08:	fffff097          	auipc	ra,0xfffff
    80004a0c:	fe4080e7          	jalr	-28(ra) # 800039ec <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a10:	874a                	mv	a4,s2
    80004a12:	5094                	lw	a3,32(s1)
    80004a14:	864e                	mv	a2,s3
    80004a16:	4585                	li	a1,1
    80004a18:	6c88                	ld	a0,24(s1)
    80004a1a:	fffff097          	auipc	ra,0xfffff
    80004a1e:	28a080e7          	jalr	650(ra) # 80003ca4 <readi>
    80004a22:	892a                	mv	s2,a0
    80004a24:	00a05563          	blez	a0,80004a2e <fileread+0x56>
      f->off += r;
    80004a28:	509c                	lw	a5,32(s1)
    80004a2a:	9fa9                	addw	a5,a5,a0
    80004a2c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a2e:	6c88                	ld	a0,24(s1)
    80004a30:	fffff097          	auipc	ra,0xfffff
    80004a34:	082080e7          	jalr	130(ra) # 80003ab2 <iunlock>
    80004a38:	64e2                	ld	s1,24(sp)
    80004a3a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004a3c:	854a                	mv	a0,s2
    80004a3e:	70a2                	ld	ra,40(sp)
    80004a40:	7402                	ld	s0,32(sp)
    80004a42:	6942                	ld	s2,16(sp)
    80004a44:	6145                	add	sp,sp,48
    80004a46:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a48:	6908                	ld	a0,16(a0)
    80004a4a:	00000097          	auipc	ra,0x0
    80004a4e:	400080e7          	jalr	1024(ra) # 80004e4a <piperead>
    80004a52:	892a                	mv	s2,a0
    80004a54:	64e2                	ld	s1,24(sp)
    80004a56:	69a2                	ld	s3,8(sp)
    80004a58:	b7d5                	j	80004a3c <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a5a:	02451783          	lh	a5,36(a0)
    80004a5e:	03079693          	sll	a3,a5,0x30
    80004a62:	92c1                	srl	a3,a3,0x30
    80004a64:	4725                	li	a4,9
    80004a66:	02d76a63          	bltu	a4,a3,80004a9a <fileread+0xc2>
    80004a6a:	0792                	sll	a5,a5,0x4
    80004a6c:	0001c717          	auipc	a4,0x1c
    80004a70:	16470713          	add	a4,a4,356 # 80020bd0 <devsw>
    80004a74:	97ba                	add	a5,a5,a4
    80004a76:	639c                	ld	a5,0(a5)
    80004a78:	c78d                	beqz	a5,80004aa2 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004a7a:	4505                	li	a0,1
    80004a7c:	9782                	jalr	a5
    80004a7e:	892a                	mv	s2,a0
    80004a80:	64e2                	ld	s1,24(sp)
    80004a82:	69a2                	ld	s3,8(sp)
    80004a84:	bf65                	j	80004a3c <fileread+0x64>
    panic("fileread");
    80004a86:	00004517          	auipc	a0,0x4
    80004a8a:	b1a50513          	add	a0,a0,-1254 # 800085a0 <etext+0x5a0>
    80004a8e:	ffffc097          	auipc	ra,0xffffc
    80004a92:	ad2080e7          	jalr	-1326(ra) # 80000560 <panic>
    return -1;
    80004a96:	597d                	li	s2,-1
    80004a98:	b755                	j	80004a3c <fileread+0x64>
      return -1;
    80004a9a:	597d                	li	s2,-1
    80004a9c:	64e2                	ld	s1,24(sp)
    80004a9e:	69a2                	ld	s3,8(sp)
    80004aa0:	bf71                	j	80004a3c <fileread+0x64>
    80004aa2:	597d                	li	s2,-1
    80004aa4:	64e2                	ld	s1,24(sp)
    80004aa6:	69a2                	ld	s3,8(sp)
    80004aa8:	bf51                	j	80004a3c <fileread+0x64>

0000000080004aaa <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004aaa:	00954783          	lbu	a5,9(a0)
    80004aae:	12078963          	beqz	a5,80004be0 <filewrite+0x136>
{
    80004ab2:	715d                	add	sp,sp,-80
    80004ab4:	e486                	sd	ra,72(sp)
    80004ab6:	e0a2                	sd	s0,64(sp)
    80004ab8:	f84a                	sd	s2,48(sp)
    80004aba:	f052                	sd	s4,32(sp)
    80004abc:	e85a                	sd	s6,16(sp)
    80004abe:	0880                	add	s0,sp,80
    80004ac0:	892a                	mv	s2,a0
    80004ac2:	8b2e                	mv	s6,a1
    80004ac4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ac6:	411c                	lw	a5,0(a0)
    80004ac8:	4705                	li	a4,1
    80004aca:	02e78763          	beq	a5,a4,80004af8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ace:	470d                	li	a4,3
    80004ad0:	02e78a63          	beq	a5,a4,80004b04 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ad4:	4709                	li	a4,2
    80004ad6:	0ee79863          	bne	a5,a4,80004bc6 <filewrite+0x11c>
    80004ada:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004adc:	0cc05463          	blez	a2,80004ba4 <filewrite+0xfa>
    80004ae0:	fc26                	sd	s1,56(sp)
    80004ae2:	ec56                	sd	s5,24(sp)
    80004ae4:	e45e                	sd	s7,8(sp)
    80004ae6:	e062                	sd	s8,0(sp)
    int i = 0;
    80004ae8:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004aea:	6b85                	lui	s7,0x1
    80004aec:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004af0:	6c05                	lui	s8,0x1
    80004af2:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004af6:	a851                	j	80004b8a <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004af8:	6908                	ld	a0,16(a0)
    80004afa:	00000097          	auipc	ra,0x0
    80004afe:	248080e7          	jalr	584(ra) # 80004d42 <pipewrite>
    80004b02:	a85d                	j	80004bb8 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b04:	02451783          	lh	a5,36(a0)
    80004b08:	03079693          	sll	a3,a5,0x30
    80004b0c:	92c1                	srl	a3,a3,0x30
    80004b0e:	4725                	li	a4,9
    80004b10:	0cd76a63          	bltu	a4,a3,80004be4 <filewrite+0x13a>
    80004b14:	0792                	sll	a5,a5,0x4
    80004b16:	0001c717          	auipc	a4,0x1c
    80004b1a:	0ba70713          	add	a4,a4,186 # 80020bd0 <devsw>
    80004b1e:	97ba                	add	a5,a5,a4
    80004b20:	679c                	ld	a5,8(a5)
    80004b22:	c3f9                	beqz	a5,80004be8 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004b24:	4505                	li	a0,1
    80004b26:	9782                	jalr	a5
    80004b28:	a841                	j	80004bb8 <filewrite+0x10e>
      if(n1 > max)
    80004b2a:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004b2e:	00000097          	auipc	ra,0x0
    80004b32:	88c080e7          	jalr	-1908(ra) # 800043ba <begin_op>
      ilock(f->ip);
    80004b36:	01893503          	ld	a0,24(s2)
    80004b3a:	fffff097          	auipc	ra,0xfffff
    80004b3e:	eb2080e7          	jalr	-334(ra) # 800039ec <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b42:	8756                	mv	a4,s5
    80004b44:	02092683          	lw	a3,32(s2)
    80004b48:	01698633          	add	a2,s3,s6
    80004b4c:	4585                	li	a1,1
    80004b4e:	01893503          	ld	a0,24(s2)
    80004b52:	fffff097          	auipc	ra,0xfffff
    80004b56:	262080e7          	jalr	610(ra) # 80003db4 <writei>
    80004b5a:	84aa                	mv	s1,a0
    80004b5c:	00a05763          	blez	a0,80004b6a <filewrite+0xc0>
        f->off += r;
    80004b60:	02092783          	lw	a5,32(s2)
    80004b64:	9fa9                	addw	a5,a5,a0
    80004b66:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b6a:	01893503          	ld	a0,24(s2)
    80004b6e:	fffff097          	auipc	ra,0xfffff
    80004b72:	f44080e7          	jalr	-188(ra) # 80003ab2 <iunlock>
      end_op();
    80004b76:	00000097          	auipc	ra,0x0
    80004b7a:	8be080e7          	jalr	-1858(ra) # 80004434 <end_op>

      if(r != n1){
    80004b7e:	029a9563          	bne	s5,s1,80004ba8 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004b82:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b86:	0149da63          	bge	s3,s4,80004b9a <filewrite+0xf0>
      int n1 = n - i;
    80004b8a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004b8e:	0004879b          	sext.w	a5,s1
    80004b92:	f8fbdce3          	bge	s7,a5,80004b2a <filewrite+0x80>
    80004b96:	84e2                	mv	s1,s8
    80004b98:	bf49                	j	80004b2a <filewrite+0x80>
    80004b9a:	74e2                	ld	s1,56(sp)
    80004b9c:	6ae2                	ld	s5,24(sp)
    80004b9e:	6ba2                	ld	s7,8(sp)
    80004ba0:	6c02                	ld	s8,0(sp)
    80004ba2:	a039                	j	80004bb0 <filewrite+0x106>
    int i = 0;
    80004ba4:	4981                	li	s3,0
    80004ba6:	a029                	j	80004bb0 <filewrite+0x106>
    80004ba8:	74e2                	ld	s1,56(sp)
    80004baa:	6ae2                	ld	s5,24(sp)
    80004bac:	6ba2                	ld	s7,8(sp)
    80004bae:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004bb0:	033a1e63          	bne	s4,s3,80004bec <filewrite+0x142>
    80004bb4:	8552                	mv	a0,s4
    80004bb6:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004bb8:	60a6                	ld	ra,72(sp)
    80004bba:	6406                	ld	s0,64(sp)
    80004bbc:	7942                	ld	s2,48(sp)
    80004bbe:	7a02                	ld	s4,32(sp)
    80004bc0:	6b42                	ld	s6,16(sp)
    80004bc2:	6161                	add	sp,sp,80
    80004bc4:	8082                	ret
    80004bc6:	fc26                	sd	s1,56(sp)
    80004bc8:	f44e                	sd	s3,40(sp)
    80004bca:	ec56                	sd	s5,24(sp)
    80004bcc:	e45e                	sd	s7,8(sp)
    80004bce:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004bd0:	00004517          	auipc	a0,0x4
    80004bd4:	9e050513          	add	a0,a0,-1568 # 800085b0 <etext+0x5b0>
    80004bd8:	ffffc097          	auipc	ra,0xffffc
    80004bdc:	988080e7          	jalr	-1656(ra) # 80000560 <panic>
    return -1;
    80004be0:	557d                	li	a0,-1
}
    80004be2:	8082                	ret
      return -1;
    80004be4:	557d                	li	a0,-1
    80004be6:	bfc9                	j	80004bb8 <filewrite+0x10e>
    80004be8:	557d                	li	a0,-1
    80004bea:	b7f9                	j	80004bb8 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004bec:	557d                	li	a0,-1
    80004bee:	79a2                	ld	s3,40(sp)
    80004bf0:	b7e1                	j	80004bb8 <filewrite+0x10e>

0000000080004bf2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004bf2:	7179                	add	sp,sp,-48
    80004bf4:	f406                	sd	ra,40(sp)
    80004bf6:	f022                	sd	s0,32(sp)
    80004bf8:	ec26                	sd	s1,24(sp)
    80004bfa:	e052                	sd	s4,0(sp)
    80004bfc:	1800                	add	s0,sp,48
    80004bfe:	84aa                	mv	s1,a0
    80004c00:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c02:	0005b023          	sd	zero,0(a1)
    80004c06:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c0a:	00000097          	auipc	ra,0x0
    80004c0e:	bbe080e7          	jalr	-1090(ra) # 800047c8 <filealloc>
    80004c12:	e088                	sd	a0,0(s1)
    80004c14:	cd49                	beqz	a0,80004cae <pipealloc+0xbc>
    80004c16:	00000097          	auipc	ra,0x0
    80004c1a:	bb2080e7          	jalr	-1102(ra) # 800047c8 <filealloc>
    80004c1e:	00aa3023          	sd	a0,0(s4)
    80004c22:	c141                	beqz	a0,80004ca2 <pipealloc+0xb0>
    80004c24:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c26:	ffffc097          	auipc	ra,0xffffc
    80004c2a:	f22080e7          	jalr	-222(ra) # 80000b48 <kalloc>
    80004c2e:	892a                	mv	s2,a0
    80004c30:	c13d                	beqz	a0,80004c96 <pipealloc+0xa4>
    80004c32:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004c34:	4985                	li	s3,1
    80004c36:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c3a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c3e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c42:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c46:	00004597          	auipc	a1,0x4
    80004c4a:	97a58593          	add	a1,a1,-1670 # 800085c0 <etext+0x5c0>
    80004c4e:	ffffc097          	auipc	ra,0xffffc
    80004c52:	f5a080e7          	jalr	-166(ra) # 80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004c56:	609c                	ld	a5,0(s1)
    80004c58:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c5c:	609c                	ld	a5,0(s1)
    80004c5e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c62:	609c                	ld	a5,0(s1)
    80004c64:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c68:	609c                	ld	a5,0(s1)
    80004c6a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c6e:	000a3783          	ld	a5,0(s4)
    80004c72:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c76:	000a3783          	ld	a5,0(s4)
    80004c7a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c7e:	000a3783          	ld	a5,0(s4)
    80004c82:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c86:	000a3783          	ld	a5,0(s4)
    80004c8a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c8e:	4501                	li	a0,0
    80004c90:	6942                	ld	s2,16(sp)
    80004c92:	69a2                	ld	s3,8(sp)
    80004c94:	a03d                	j	80004cc2 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c96:	6088                	ld	a0,0(s1)
    80004c98:	c119                	beqz	a0,80004c9e <pipealloc+0xac>
    80004c9a:	6942                	ld	s2,16(sp)
    80004c9c:	a029                	j	80004ca6 <pipealloc+0xb4>
    80004c9e:	6942                	ld	s2,16(sp)
    80004ca0:	a039                	j	80004cae <pipealloc+0xbc>
    80004ca2:	6088                	ld	a0,0(s1)
    80004ca4:	c50d                	beqz	a0,80004cce <pipealloc+0xdc>
    fileclose(*f0);
    80004ca6:	00000097          	auipc	ra,0x0
    80004caa:	bde080e7          	jalr	-1058(ra) # 80004884 <fileclose>
  if(*f1)
    80004cae:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004cb2:	557d                	li	a0,-1
  if(*f1)
    80004cb4:	c799                	beqz	a5,80004cc2 <pipealloc+0xd0>
    fileclose(*f1);
    80004cb6:	853e                	mv	a0,a5
    80004cb8:	00000097          	auipc	ra,0x0
    80004cbc:	bcc080e7          	jalr	-1076(ra) # 80004884 <fileclose>
  return -1;
    80004cc0:	557d                	li	a0,-1
}
    80004cc2:	70a2                	ld	ra,40(sp)
    80004cc4:	7402                	ld	s0,32(sp)
    80004cc6:	64e2                	ld	s1,24(sp)
    80004cc8:	6a02                	ld	s4,0(sp)
    80004cca:	6145                	add	sp,sp,48
    80004ccc:	8082                	ret
  return -1;
    80004cce:	557d                	li	a0,-1
    80004cd0:	bfcd                	j	80004cc2 <pipealloc+0xd0>

0000000080004cd2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004cd2:	1101                	add	sp,sp,-32
    80004cd4:	ec06                	sd	ra,24(sp)
    80004cd6:	e822                	sd	s0,16(sp)
    80004cd8:	e426                	sd	s1,8(sp)
    80004cda:	e04a                	sd	s2,0(sp)
    80004cdc:	1000                	add	s0,sp,32
    80004cde:	84aa                	mv	s1,a0
    80004ce0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ce2:	ffffc097          	auipc	ra,0xffffc
    80004ce6:	f56080e7          	jalr	-170(ra) # 80000c38 <acquire>
  if(writable){
    80004cea:	02090d63          	beqz	s2,80004d24 <pipeclose+0x52>
    pi->writeopen = 0;
    80004cee:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004cf2:	21848513          	add	a0,s1,536
    80004cf6:	ffffd097          	auipc	ra,0xffffd
    80004cfa:	6f8080e7          	jalr	1784(ra) # 800023ee <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004cfe:	2204b783          	ld	a5,544(s1)
    80004d02:	eb95                	bnez	a5,80004d36 <pipeclose+0x64>
    release(&pi->lock);
    80004d04:	8526                	mv	a0,s1
    80004d06:	ffffc097          	auipc	ra,0xffffc
    80004d0a:	fe6080e7          	jalr	-26(ra) # 80000cec <release>
    kfree((char*)pi);
    80004d0e:	8526                	mv	a0,s1
    80004d10:	ffffc097          	auipc	ra,0xffffc
    80004d14:	d3a080e7          	jalr	-710(ra) # 80000a4a <kfree>
  } else
    release(&pi->lock);
}
    80004d18:	60e2                	ld	ra,24(sp)
    80004d1a:	6442                	ld	s0,16(sp)
    80004d1c:	64a2                	ld	s1,8(sp)
    80004d1e:	6902                	ld	s2,0(sp)
    80004d20:	6105                	add	sp,sp,32
    80004d22:	8082                	ret
    pi->readopen = 0;
    80004d24:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d28:	21c48513          	add	a0,s1,540
    80004d2c:	ffffd097          	auipc	ra,0xffffd
    80004d30:	6c2080e7          	jalr	1730(ra) # 800023ee <wakeup>
    80004d34:	b7e9                	j	80004cfe <pipeclose+0x2c>
    release(&pi->lock);
    80004d36:	8526                	mv	a0,s1
    80004d38:	ffffc097          	auipc	ra,0xffffc
    80004d3c:	fb4080e7          	jalr	-76(ra) # 80000cec <release>
}
    80004d40:	bfe1                	j	80004d18 <pipeclose+0x46>

0000000080004d42 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d42:	711d                	add	sp,sp,-96
    80004d44:	ec86                	sd	ra,88(sp)
    80004d46:	e8a2                	sd	s0,80(sp)
    80004d48:	e4a6                	sd	s1,72(sp)
    80004d4a:	e0ca                	sd	s2,64(sp)
    80004d4c:	fc4e                	sd	s3,56(sp)
    80004d4e:	f852                	sd	s4,48(sp)
    80004d50:	f456                	sd	s5,40(sp)
    80004d52:	1080                	add	s0,sp,96
    80004d54:	84aa                	mv	s1,a0
    80004d56:	8aae                	mv	s5,a1
    80004d58:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d5a:	ffffd097          	auipc	ra,0xffffd
    80004d5e:	d08080e7          	jalr	-760(ra) # 80001a62 <myproc>
    80004d62:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d64:	8526                	mv	a0,s1
    80004d66:	ffffc097          	auipc	ra,0xffffc
    80004d6a:	ed2080e7          	jalr	-302(ra) # 80000c38 <acquire>
  while(i < n){
    80004d6e:	0d405863          	blez	s4,80004e3e <pipewrite+0xfc>
    80004d72:	f05a                	sd	s6,32(sp)
    80004d74:	ec5e                	sd	s7,24(sp)
    80004d76:	e862                	sd	s8,16(sp)
  int i = 0;
    80004d78:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d7a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d7c:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d80:	21c48b93          	add	s7,s1,540
    80004d84:	a089                	j	80004dc6 <pipewrite+0x84>
      release(&pi->lock);
    80004d86:	8526                	mv	a0,s1
    80004d88:	ffffc097          	auipc	ra,0xffffc
    80004d8c:	f64080e7          	jalr	-156(ra) # 80000cec <release>
      return -1;
    80004d90:	597d                	li	s2,-1
    80004d92:	7b02                	ld	s6,32(sp)
    80004d94:	6be2                	ld	s7,24(sp)
    80004d96:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d98:	854a                	mv	a0,s2
    80004d9a:	60e6                	ld	ra,88(sp)
    80004d9c:	6446                	ld	s0,80(sp)
    80004d9e:	64a6                	ld	s1,72(sp)
    80004da0:	6906                	ld	s2,64(sp)
    80004da2:	79e2                	ld	s3,56(sp)
    80004da4:	7a42                	ld	s4,48(sp)
    80004da6:	7aa2                	ld	s5,40(sp)
    80004da8:	6125                	add	sp,sp,96
    80004daa:	8082                	ret
      wakeup(&pi->nread);
    80004dac:	8562                	mv	a0,s8
    80004dae:	ffffd097          	auipc	ra,0xffffd
    80004db2:	640080e7          	jalr	1600(ra) # 800023ee <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004db6:	85a6                	mv	a1,s1
    80004db8:	855e                	mv	a0,s7
    80004dba:	ffffd097          	auipc	ra,0xffffd
    80004dbe:	5d0080e7          	jalr	1488(ra) # 8000238a <sleep>
  while(i < n){
    80004dc2:	05495f63          	bge	s2,s4,80004e20 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004dc6:	2204a783          	lw	a5,544(s1)
    80004dca:	dfd5                	beqz	a5,80004d86 <pipewrite+0x44>
    80004dcc:	854e                	mv	a0,s3
    80004dce:	ffffe097          	auipc	ra,0xffffe
    80004dd2:	87c080e7          	jalr	-1924(ra) # 8000264a <killed>
    80004dd6:	f945                	bnez	a0,80004d86 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004dd8:	2184a783          	lw	a5,536(s1)
    80004ddc:	21c4a703          	lw	a4,540(s1)
    80004de0:	2007879b          	addw	a5,a5,512
    80004de4:	fcf704e3          	beq	a4,a5,80004dac <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004de8:	4685                	li	a3,1
    80004dea:	01590633          	add	a2,s2,s5
    80004dee:	faf40593          	add	a1,s0,-81
    80004df2:	0509b503          	ld	a0,80(s3)
    80004df6:	ffffd097          	auipc	ra,0xffffd
    80004dfa:	978080e7          	jalr	-1672(ra) # 8000176e <copyin>
    80004dfe:	05650263          	beq	a0,s6,80004e42 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e02:	21c4a783          	lw	a5,540(s1)
    80004e06:	0017871b          	addw	a4,a5,1
    80004e0a:	20e4ae23          	sw	a4,540(s1)
    80004e0e:	1ff7f793          	and	a5,a5,511
    80004e12:	97a6                	add	a5,a5,s1
    80004e14:	faf44703          	lbu	a4,-81(s0)
    80004e18:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e1c:	2905                	addw	s2,s2,1
    80004e1e:	b755                	j	80004dc2 <pipewrite+0x80>
    80004e20:	7b02                	ld	s6,32(sp)
    80004e22:	6be2                	ld	s7,24(sp)
    80004e24:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004e26:	21848513          	add	a0,s1,536
    80004e2a:	ffffd097          	auipc	ra,0xffffd
    80004e2e:	5c4080e7          	jalr	1476(ra) # 800023ee <wakeup>
  release(&pi->lock);
    80004e32:	8526                	mv	a0,s1
    80004e34:	ffffc097          	auipc	ra,0xffffc
    80004e38:	eb8080e7          	jalr	-328(ra) # 80000cec <release>
  return i;
    80004e3c:	bfb1                	j	80004d98 <pipewrite+0x56>
  int i = 0;
    80004e3e:	4901                	li	s2,0
    80004e40:	b7dd                	j	80004e26 <pipewrite+0xe4>
    80004e42:	7b02                	ld	s6,32(sp)
    80004e44:	6be2                	ld	s7,24(sp)
    80004e46:	6c42                	ld	s8,16(sp)
    80004e48:	bff9                	j	80004e26 <pipewrite+0xe4>

0000000080004e4a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e4a:	715d                	add	sp,sp,-80
    80004e4c:	e486                	sd	ra,72(sp)
    80004e4e:	e0a2                	sd	s0,64(sp)
    80004e50:	fc26                	sd	s1,56(sp)
    80004e52:	f84a                	sd	s2,48(sp)
    80004e54:	f44e                	sd	s3,40(sp)
    80004e56:	f052                	sd	s4,32(sp)
    80004e58:	ec56                	sd	s5,24(sp)
    80004e5a:	0880                	add	s0,sp,80
    80004e5c:	84aa                	mv	s1,a0
    80004e5e:	892e                	mv	s2,a1
    80004e60:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e62:	ffffd097          	auipc	ra,0xffffd
    80004e66:	c00080e7          	jalr	-1024(ra) # 80001a62 <myproc>
    80004e6a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e6c:	8526                	mv	a0,s1
    80004e6e:	ffffc097          	auipc	ra,0xffffc
    80004e72:	dca080e7          	jalr	-566(ra) # 80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e76:	2184a703          	lw	a4,536(s1)
    80004e7a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e7e:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e82:	02f71963          	bne	a4,a5,80004eb4 <piperead+0x6a>
    80004e86:	2244a783          	lw	a5,548(s1)
    80004e8a:	cf95                	beqz	a5,80004ec6 <piperead+0x7c>
    if(killed(pr)){
    80004e8c:	8552                	mv	a0,s4
    80004e8e:	ffffd097          	auipc	ra,0xffffd
    80004e92:	7bc080e7          	jalr	1980(ra) # 8000264a <killed>
    80004e96:	e10d                	bnez	a0,80004eb8 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e98:	85a6                	mv	a1,s1
    80004e9a:	854e                	mv	a0,s3
    80004e9c:	ffffd097          	auipc	ra,0xffffd
    80004ea0:	4ee080e7          	jalr	1262(ra) # 8000238a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ea4:	2184a703          	lw	a4,536(s1)
    80004ea8:	21c4a783          	lw	a5,540(s1)
    80004eac:	fcf70de3          	beq	a4,a5,80004e86 <piperead+0x3c>
    80004eb0:	e85a                	sd	s6,16(sp)
    80004eb2:	a819                	j	80004ec8 <piperead+0x7e>
    80004eb4:	e85a                	sd	s6,16(sp)
    80004eb6:	a809                	j	80004ec8 <piperead+0x7e>
      release(&pi->lock);
    80004eb8:	8526                	mv	a0,s1
    80004eba:	ffffc097          	auipc	ra,0xffffc
    80004ebe:	e32080e7          	jalr	-462(ra) # 80000cec <release>
      return -1;
    80004ec2:	59fd                	li	s3,-1
    80004ec4:	a0a5                	j	80004f2c <piperead+0xe2>
    80004ec6:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ec8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004eca:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ecc:	05505463          	blez	s5,80004f14 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80004ed0:	2184a783          	lw	a5,536(s1)
    80004ed4:	21c4a703          	lw	a4,540(s1)
    80004ed8:	02f70e63          	beq	a4,a5,80004f14 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004edc:	0017871b          	addw	a4,a5,1
    80004ee0:	20e4ac23          	sw	a4,536(s1)
    80004ee4:	1ff7f793          	and	a5,a5,511
    80004ee8:	97a6                	add	a5,a5,s1
    80004eea:	0187c783          	lbu	a5,24(a5)
    80004eee:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ef2:	4685                	li	a3,1
    80004ef4:	fbf40613          	add	a2,s0,-65
    80004ef8:	85ca                	mv	a1,s2
    80004efa:	050a3503          	ld	a0,80(s4)
    80004efe:	ffffc097          	auipc	ra,0xffffc
    80004f02:	7e4080e7          	jalr	2020(ra) # 800016e2 <copyout>
    80004f06:	01650763          	beq	a0,s6,80004f14 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f0a:	2985                	addw	s3,s3,1
    80004f0c:	0905                	add	s2,s2,1
    80004f0e:	fd3a91e3          	bne	s5,s3,80004ed0 <piperead+0x86>
    80004f12:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f14:	21c48513          	add	a0,s1,540
    80004f18:	ffffd097          	auipc	ra,0xffffd
    80004f1c:	4d6080e7          	jalr	1238(ra) # 800023ee <wakeup>
  release(&pi->lock);
    80004f20:	8526                	mv	a0,s1
    80004f22:	ffffc097          	auipc	ra,0xffffc
    80004f26:	dca080e7          	jalr	-566(ra) # 80000cec <release>
    80004f2a:	6b42                	ld	s6,16(sp)
  return i;
}
    80004f2c:	854e                	mv	a0,s3
    80004f2e:	60a6                	ld	ra,72(sp)
    80004f30:	6406                	ld	s0,64(sp)
    80004f32:	74e2                	ld	s1,56(sp)
    80004f34:	7942                	ld	s2,48(sp)
    80004f36:	79a2                	ld	s3,40(sp)
    80004f38:	7a02                	ld	s4,32(sp)
    80004f3a:	6ae2                	ld	s5,24(sp)
    80004f3c:	6161                	add	sp,sp,80
    80004f3e:	8082                	ret

0000000080004f40 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004f40:	1141                	add	sp,sp,-16
    80004f42:	e422                	sd	s0,8(sp)
    80004f44:	0800                	add	s0,sp,16
    80004f46:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004f48:	8905                	and	a0,a0,1
    80004f4a:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004f4c:	8b89                	and	a5,a5,2
    80004f4e:	c399                	beqz	a5,80004f54 <flags2perm+0x14>
      perm |= PTE_W;
    80004f50:	00456513          	or	a0,a0,4
    return perm;
}
    80004f54:	6422                	ld	s0,8(sp)
    80004f56:	0141                	add	sp,sp,16
    80004f58:	8082                	ret

0000000080004f5a <exec>:

int
exec(char *path, char **argv)
{
    80004f5a:	df010113          	add	sp,sp,-528
    80004f5e:	20113423          	sd	ra,520(sp)
    80004f62:	20813023          	sd	s0,512(sp)
    80004f66:	ffa6                	sd	s1,504(sp)
    80004f68:	fbca                	sd	s2,496(sp)
    80004f6a:	0c00                	add	s0,sp,528
    80004f6c:	892a                	mv	s2,a0
    80004f6e:	dea43c23          	sd	a0,-520(s0)
    80004f72:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f76:	ffffd097          	auipc	ra,0xffffd
    80004f7a:	aec080e7          	jalr	-1300(ra) # 80001a62 <myproc>
    80004f7e:	84aa                	mv	s1,a0

  begin_op();
    80004f80:	fffff097          	auipc	ra,0xfffff
    80004f84:	43a080e7          	jalr	1082(ra) # 800043ba <begin_op>

  if((ip = namei(path)) == 0){
    80004f88:	854a                	mv	a0,s2
    80004f8a:	fffff097          	auipc	ra,0xfffff
    80004f8e:	230080e7          	jalr	560(ra) # 800041ba <namei>
    80004f92:	c135                	beqz	a0,80004ff6 <exec+0x9c>
    80004f94:	f3d2                	sd	s4,480(sp)
    80004f96:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f98:	fffff097          	auipc	ra,0xfffff
    80004f9c:	a54080e7          	jalr	-1452(ra) # 800039ec <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004fa0:	04000713          	li	a4,64
    80004fa4:	4681                	li	a3,0
    80004fa6:	e5040613          	add	a2,s0,-432
    80004faa:	4581                	li	a1,0
    80004fac:	8552                	mv	a0,s4
    80004fae:	fffff097          	auipc	ra,0xfffff
    80004fb2:	cf6080e7          	jalr	-778(ra) # 80003ca4 <readi>
    80004fb6:	04000793          	li	a5,64
    80004fba:	00f51a63          	bne	a0,a5,80004fce <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004fbe:	e5042703          	lw	a4,-432(s0)
    80004fc2:	464c47b7          	lui	a5,0x464c4
    80004fc6:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004fca:	02f70c63          	beq	a4,a5,80005002 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004fce:	8552                	mv	a0,s4
    80004fd0:	fffff097          	auipc	ra,0xfffff
    80004fd4:	c82080e7          	jalr	-894(ra) # 80003c52 <iunlockput>
    end_op();
    80004fd8:	fffff097          	auipc	ra,0xfffff
    80004fdc:	45c080e7          	jalr	1116(ra) # 80004434 <end_op>
  }
  return -1;
    80004fe0:	557d                	li	a0,-1
    80004fe2:	7a1e                	ld	s4,480(sp)
}
    80004fe4:	20813083          	ld	ra,520(sp)
    80004fe8:	20013403          	ld	s0,512(sp)
    80004fec:	74fe                	ld	s1,504(sp)
    80004fee:	795e                	ld	s2,496(sp)
    80004ff0:	21010113          	add	sp,sp,528
    80004ff4:	8082                	ret
    end_op();
    80004ff6:	fffff097          	auipc	ra,0xfffff
    80004ffa:	43e080e7          	jalr	1086(ra) # 80004434 <end_op>
    return -1;
    80004ffe:	557d                	li	a0,-1
    80005000:	b7d5                	j	80004fe4 <exec+0x8a>
    80005002:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005004:	8526                	mv	a0,s1
    80005006:	ffffd097          	auipc	ra,0xffffd
    8000500a:	b66080e7          	jalr	-1178(ra) # 80001b6c <proc_pagetable>
    8000500e:	8b2a                	mv	s6,a0
    80005010:	30050f63          	beqz	a0,8000532e <exec+0x3d4>
    80005014:	f7ce                	sd	s3,488(sp)
    80005016:	efd6                	sd	s5,472(sp)
    80005018:	e7de                	sd	s7,456(sp)
    8000501a:	e3e2                	sd	s8,448(sp)
    8000501c:	ff66                	sd	s9,440(sp)
    8000501e:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005020:	e7042d03          	lw	s10,-400(s0)
    80005024:	e8845783          	lhu	a5,-376(s0)
    80005028:	14078d63          	beqz	a5,80005182 <exec+0x228>
    8000502c:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000502e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005030:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005032:	6c85                	lui	s9,0x1
    80005034:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005038:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000503c:	6a85                	lui	s5,0x1
    8000503e:	a0b5                	j	800050aa <exec+0x150>
      panic("loadseg: address should exist");
    80005040:	00003517          	auipc	a0,0x3
    80005044:	58850513          	add	a0,a0,1416 # 800085c8 <etext+0x5c8>
    80005048:	ffffb097          	auipc	ra,0xffffb
    8000504c:	518080e7          	jalr	1304(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80005050:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005052:	8726                	mv	a4,s1
    80005054:	012c06bb          	addw	a3,s8,s2
    80005058:	4581                	li	a1,0
    8000505a:	8552                	mv	a0,s4
    8000505c:	fffff097          	auipc	ra,0xfffff
    80005060:	c48080e7          	jalr	-952(ra) # 80003ca4 <readi>
    80005064:	2501                	sext.w	a0,a0
    80005066:	28a49863          	bne	s1,a0,800052f6 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    8000506a:	012a893b          	addw	s2,s5,s2
    8000506e:	03397563          	bgeu	s2,s3,80005098 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80005072:	02091593          	sll	a1,s2,0x20
    80005076:	9181                	srl	a1,a1,0x20
    80005078:	95de                	add	a1,a1,s7
    8000507a:	855a                	mv	a0,s6
    8000507c:	ffffc097          	auipc	ra,0xffffc
    80005080:	03a080e7          	jalr	58(ra) # 800010b6 <walkaddr>
    80005084:	862a                	mv	a2,a0
    if(pa == 0)
    80005086:	dd4d                	beqz	a0,80005040 <exec+0xe6>
    if(sz - i < PGSIZE)
    80005088:	412984bb          	subw	s1,s3,s2
    8000508c:	0004879b          	sext.w	a5,s1
    80005090:	fcfcf0e3          	bgeu	s9,a5,80005050 <exec+0xf6>
    80005094:	84d6                	mv	s1,s5
    80005096:	bf6d                	j	80005050 <exec+0xf6>
    sz = sz1;
    80005098:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000509c:	2d85                	addw	s11,s11,1
    8000509e:	038d0d1b          	addw	s10,s10,56
    800050a2:	e8845783          	lhu	a5,-376(s0)
    800050a6:	08fdd663          	bge	s11,a5,80005132 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050aa:	2d01                	sext.w	s10,s10
    800050ac:	03800713          	li	a4,56
    800050b0:	86ea                	mv	a3,s10
    800050b2:	e1840613          	add	a2,s0,-488
    800050b6:	4581                	li	a1,0
    800050b8:	8552                	mv	a0,s4
    800050ba:	fffff097          	auipc	ra,0xfffff
    800050be:	bea080e7          	jalr	-1046(ra) # 80003ca4 <readi>
    800050c2:	03800793          	li	a5,56
    800050c6:	20f51063          	bne	a0,a5,800052c6 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    800050ca:	e1842783          	lw	a5,-488(s0)
    800050ce:	4705                	li	a4,1
    800050d0:	fce796e3          	bne	a5,a4,8000509c <exec+0x142>
    if(ph.memsz < ph.filesz)
    800050d4:	e4043483          	ld	s1,-448(s0)
    800050d8:	e3843783          	ld	a5,-456(s0)
    800050dc:	1ef4e963          	bltu	s1,a5,800052ce <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800050e0:	e2843783          	ld	a5,-472(s0)
    800050e4:	94be                	add	s1,s1,a5
    800050e6:	1ef4e863          	bltu	s1,a5,800052d6 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    800050ea:	df043703          	ld	a4,-528(s0)
    800050ee:	8ff9                	and	a5,a5,a4
    800050f0:	1e079763          	bnez	a5,800052de <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800050f4:	e1c42503          	lw	a0,-484(s0)
    800050f8:	00000097          	auipc	ra,0x0
    800050fc:	e48080e7          	jalr	-440(ra) # 80004f40 <flags2perm>
    80005100:	86aa                	mv	a3,a0
    80005102:	8626                	mv	a2,s1
    80005104:	85ca                	mv	a1,s2
    80005106:	855a                	mv	a0,s6
    80005108:	ffffc097          	auipc	ra,0xffffc
    8000510c:	372080e7          	jalr	882(ra) # 8000147a <uvmalloc>
    80005110:	e0a43423          	sd	a0,-504(s0)
    80005114:	1c050963          	beqz	a0,800052e6 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005118:	e2843b83          	ld	s7,-472(s0)
    8000511c:	e2042c03          	lw	s8,-480(s0)
    80005120:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005124:	00098463          	beqz	s3,8000512c <exec+0x1d2>
    80005128:	4901                	li	s2,0
    8000512a:	b7a1                	j	80005072 <exec+0x118>
    sz = sz1;
    8000512c:	e0843903          	ld	s2,-504(s0)
    80005130:	b7b5                	j	8000509c <exec+0x142>
    80005132:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005134:	8552                	mv	a0,s4
    80005136:	fffff097          	auipc	ra,0xfffff
    8000513a:	b1c080e7          	jalr	-1252(ra) # 80003c52 <iunlockput>
  end_op();
    8000513e:	fffff097          	auipc	ra,0xfffff
    80005142:	2f6080e7          	jalr	758(ra) # 80004434 <end_op>
  p = myproc();
    80005146:	ffffd097          	auipc	ra,0xffffd
    8000514a:	91c080e7          	jalr	-1764(ra) # 80001a62 <myproc>
    8000514e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005150:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005154:	6985                	lui	s3,0x1
    80005156:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005158:	99ca                	add	s3,s3,s2
    8000515a:	77fd                	lui	a5,0xfffff
    8000515c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005160:	4691                	li	a3,4
    80005162:	6609                	lui	a2,0x2
    80005164:	964e                	add	a2,a2,s3
    80005166:	85ce                	mv	a1,s3
    80005168:	855a                	mv	a0,s6
    8000516a:	ffffc097          	auipc	ra,0xffffc
    8000516e:	310080e7          	jalr	784(ra) # 8000147a <uvmalloc>
    80005172:	892a                	mv	s2,a0
    80005174:	e0a43423          	sd	a0,-504(s0)
    80005178:	e519                	bnez	a0,80005186 <exec+0x22c>
  if(pagetable)
    8000517a:	e1343423          	sd	s3,-504(s0)
    8000517e:	4a01                	li	s4,0
    80005180:	aaa5                	j	800052f8 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005182:	4901                	li	s2,0
    80005184:	bf45                	j	80005134 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005186:	75f9                	lui	a1,0xffffe
    80005188:	95aa                	add	a1,a1,a0
    8000518a:	855a                	mv	a0,s6
    8000518c:	ffffc097          	auipc	ra,0xffffc
    80005190:	524080e7          	jalr	1316(ra) # 800016b0 <uvmclear>
  stackbase = sp - PGSIZE;
    80005194:	7bfd                	lui	s7,0xfffff
    80005196:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005198:	e0043783          	ld	a5,-512(s0)
    8000519c:	6388                	ld	a0,0(a5)
    8000519e:	c52d                	beqz	a0,80005208 <exec+0x2ae>
    800051a0:	e9040993          	add	s3,s0,-368
    800051a4:	f9040c13          	add	s8,s0,-112
    800051a8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800051aa:	ffffc097          	auipc	ra,0xffffc
    800051ae:	cfe080e7          	jalr	-770(ra) # 80000ea8 <strlen>
    800051b2:	0015079b          	addw	a5,a0,1
    800051b6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051ba:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    800051be:	13796863          	bltu	s2,s7,800052ee <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051c2:	e0043d03          	ld	s10,-512(s0)
    800051c6:	000d3a03          	ld	s4,0(s10)
    800051ca:	8552                	mv	a0,s4
    800051cc:	ffffc097          	auipc	ra,0xffffc
    800051d0:	cdc080e7          	jalr	-804(ra) # 80000ea8 <strlen>
    800051d4:	0015069b          	addw	a3,a0,1
    800051d8:	8652                	mv	a2,s4
    800051da:	85ca                	mv	a1,s2
    800051dc:	855a                	mv	a0,s6
    800051de:	ffffc097          	auipc	ra,0xffffc
    800051e2:	504080e7          	jalr	1284(ra) # 800016e2 <copyout>
    800051e6:	10054663          	bltz	a0,800052f2 <exec+0x398>
    ustack[argc] = sp;
    800051ea:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051ee:	0485                	add	s1,s1,1
    800051f0:	008d0793          	add	a5,s10,8
    800051f4:	e0f43023          	sd	a5,-512(s0)
    800051f8:	008d3503          	ld	a0,8(s10)
    800051fc:	c909                	beqz	a0,8000520e <exec+0x2b4>
    if(argc >= MAXARG)
    800051fe:	09a1                	add	s3,s3,8
    80005200:	fb8995e3          	bne	s3,s8,800051aa <exec+0x250>
  ip = 0;
    80005204:	4a01                	li	s4,0
    80005206:	a8cd                	j	800052f8 <exec+0x39e>
  sp = sz;
    80005208:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000520c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000520e:	00349793          	sll	a5,s1,0x3
    80005212:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd228>
    80005216:	97a2                	add	a5,a5,s0
    80005218:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000521c:	00148693          	add	a3,s1,1
    80005220:	068e                	sll	a3,a3,0x3
    80005222:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005226:	ff097913          	and	s2,s2,-16
  sz = sz1;
    8000522a:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000522e:	f57966e3          	bltu	s2,s7,8000517a <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005232:	e9040613          	add	a2,s0,-368
    80005236:	85ca                	mv	a1,s2
    80005238:	855a                	mv	a0,s6
    8000523a:	ffffc097          	auipc	ra,0xffffc
    8000523e:	4a8080e7          	jalr	1192(ra) # 800016e2 <copyout>
    80005242:	0e054863          	bltz	a0,80005332 <exec+0x3d8>
  p->trapframe->a1 = sp;
    80005246:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000524a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000524e:	df843783          	ld	a5,-520(s0)
    80005252:	0007c703          	lbu	a4,0(a5)
    80005256:	cf11                	beqz	a4,80005272 <exec+0x318>
    80005258:	0785                	add	a5,a5,1
    if(*s == '/')
    8000525a:	02f00693          	li	a3,47
    8000525e:	a039                	j	8000526c <exec+0x312>
      last = s+1;
    80005260:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005264:	0785                	add	a5,a5,1
    80005266:	fff7c703          	lbu	a4,-1(a5)
    8000526a:	c701                	beqz	a4,80005272 <exec+0x318>
    if(*s == '/')
    8000526c:	fed71ce3          	bne	a4,a3,80005264 <exec+0x30a>
    80005270:	bfc5                	j	80005260 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80005272:	4641                	li	a2,16
    80005274:	df843583          	ld	a1,-520(s0)
    80005278:	158a8513          	add	a0,s5,344
    8000527c:	ffffc097          	auipc	ra,0xffffc
    80005280:	bfa080e7          	jalr	-1030(ra) # 80000e76 <safestrcpy>
  oldpagetable = p->pagetable;
    80005284:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005288:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000528c:	e0843783          	ld	a5,-504(s0)
    80005290:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005294:	058ab783          	ld	a5,88(s5)
    80005298:	e6843703          	ld	a4,-408(s0)
    8000529c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000529e:	058ab783          	ld	a5,88(s5)
    800052a2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052a6:	85e6                	mv	a1,s9
    800052a8:	ffffd097          	auipc	ra,0xffffd
    800052ac:	960080e7          	jalr	-1696(ra) # 80001c08 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052b0:	0004851b          	sext.w	a0,s1
    800052b4:	79be                	ld	s3,488(sp)
    800052b6:	7a1e                	ld	s4,480(sp)
    800052b8:	6afe                	ld	s5,472(sp)
    800052ba:	6b5e                	ld	s6,464(sp)
    800052bc:	6bbe                	ld	s7,456(sp)
    800052be:	6c1e                	ld	s8,448(sp)
    800052c0:	7cfa                	ld	s9,440(sp)
    800052c2:	7d5a                	ld	s10,432(sp)
    800052c4:	b305                	j	80004fe4 <exec+0x8a>
    800052c6:	e1243423          	sd	s2,-504(s0)
    800052ca:	7dba                	ld	s11,424(sp)
    800052cc:	a035                	j	800052f8 <exec+0x39e>
    800052ce:	e1243423          	sd	s2,-504(s0)
    800052d2:	7dba                	ld	s11,424(sp)
    800052d4:	a015                	j	800052f8 <exec+0x39e>
    800052d6:	e1243423          	sd	s2,-504(s0)
    800052da:	7dba                	ld	s11,424(sp)
    800052dc:	a831                	j	800052f8 <exec+0x39e>
    800052de:	e1243423          	sd	s2,-504(s0)
    800052e2:	7dba                	ld	s11,424(sp)
    800052e4:	a811                	j	800052f8 <exec+0x39e>
    800052e6:	e1243423          	sd	s2,-504(s0)
    800052ea:	7dba                	ld	s11,424(sp)
    800052ec:	a031                	j	800052f8 <exec+0x39e>
  ip = 0;
    800052ee:	4a01                	li	s4,0
    800052f0:	a021                	j	800052f8 <exec+0x39e>
    800052f2:	4a01                	li	s4,0
  if(pagetable)
    800052f4:	a011                	j	800052f8 <exec+0x39e>
    800052f6:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800052f8:	e0843583          	ld	a1,-504(s0)
    800052fc:	855a                	mv	a0,s6
    800052fe:	ffffd097          	auipc	ra,0xffffd
    80005302:	90a080e7          	jalr	-1782(ra) # 80001c08 <proc_freepagetable>
  return -1;
    80005306:	557d                	li	a0,-1
  if(ip){
    80005308:	000a1b63          	bnez	s4,8000531e <exec+0x3c4>
    8000530c:	79be                	ld	s3,488(sp)
    8000530e:	7a1e                	ld	s4,480(sp)
    80005310:	6afe                	ld	s5,472(sp)
    80005312:	6b5e                	ld	s6,464(sp)
    80005314:	6bbe                	ld	s7,456(sp)
    80005316:	6c1e                	ld	s8,448(sp)
    80005318:	7cfa                	ld	s9,440(sp)
    8000531a:	7d5a                	ld	s10,432(sp)
    8000531c:	b1e1                	j	80004fe4 <exec+0x8a>
    8000531e:	79be                	ld	s3,488(sp)
    80005320:	6afe                	ld	s5,472(sp)
    80005322:	6b5e                	ld	s6,464(sp)
    80005324:	6bbe                	ld	s7,456(sp)
    80005326:	6c1e                	ld	s8,448(sp)
    80005328:	7cfa                	ld	s9,440(sp)
    8000532a:	7d5a                	ld	s10,432(sp)
    8000532c:	b14d                	j	80004fce <exec+0x74>
    8000532e:	6b5e                	ld	s6,464(sp)
    80005330:	b979                	j	80004fce <exec+0x74>
  sz = sz1;
    80005332:	e0843983          	ld	s3,-504(s0)
    80005336:	b591                	j	8000517a <exec+0x220>

0000000080005338 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005338:	7179                	add	sp,sp,-48
    8000533a:	f406                	sd	ra,40(sp)
    8000533c:	f022                	sd	s0,32(sp)
    8000533e:	ec26                	sd	s1,24(sp)
    80005340:	e84a                	sd	s2,16(sp)
    80005342:	1800                	add	s0,sp,48
    80005344:	892e                	mv	s2,a1
    80005346:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005348:	fdc40593          	add	a1,s0,-36
    8000534c:	ffffe097          	auipc	ra,0xffffe
    80005350:	ade080e7          	jalr	-1314(ra) # 80002e2a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005354:	fdc42703          	lw	a4,-36(s0)
    80005358:	47bd                	li	a5,15
    8000535a:	02e7eb63          	bltu	a5,a4,80005390 <argfd+0x58>
    8000535e:	ffffc097          	auipc	ra,0xffffc
    80005362:	704080e7          	jalr	1796(ra) # 80001a62 <myproc>
    80005366:	fdc42703          	lw	a4,-36(s0)
    8000536a:	01a70793          	add	a5,a4,26
    8000536e:	078e                	sll	a5,a5,0x3
    80005370:	953e                	add	a0,a0,a5
    80005372:	611c                	ld	a5,0(a0)
    80005374:	c385                	beqz	a5,80005394 <argfd+0x5c>
    return -1;
  if(pfd)
    80005376:	00090463          	beqz	s2,8000537e <argfd+0x46>
    *pfd = fd;
    8000537a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000537e:	4501                	li	a0,0
  if(pf)
    80005380:	c091                	beqz	s1,80005384 <argfd+0x4c>
    *pf = f;
    80005382:	e09c                	sd	a5,0(s1)
}
    80005384:	70a2                	ld	ra,40(sp)
    80005386:	7402                	ld	s0,32(sp)
    80005388:	64e2                	ld	s1,24(sp)
    8000538a:	6942                	ld	s2,16(sp)
    8000538c:	6145                	add	sp,sp,48
    8000538e:	8082                	ret
    return -1;
    80005390:	557d                	li	a0,-1
    80005392:	bfcd                	j	80005384 <argfd+0x4c>
    80005394:	557d                	li	a0,-1
    80005396:	b7fd                	j	80005384 <argfd+0x4c>

0000000080005398 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005398:	1101                	add	sp,sp,-32
    8000539a:	ec06                	sd	ra,24(sp)
    8000539c:	e822                	sd	s0,16(sp)
    8000539e:	e426                	sd	s1,8(sp)
    800053a0:	1000                	add	s0,sp,32
    800053a2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053a4:	ffffc097          	auipc	ra,0xffffc
    800053a8:	6be080e7          	jalr	1726(ra) # 80001a62 <myproc>
    800053ac:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053ae:	0d050793          	add	a5,a0,208
    800053b2:	4501                	li	a0,0
    800053b4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053b6:	6398                	ld	a4,0(a5)
    800053b8:	cb19                	beqz	a4,800053ce <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800053ba:	2505                	addw	a0,a0,1
    800053bc:	07a1                	add	a5,a5,8
    800053be:	fed51ce3          	bne	a0,a3,800053b6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053c2:	557d                	li	a0,-1
}
    800053c4:	60e2                	ld	ra,24(sp)
    800053c6:	6442                	ld	s0,16(sp)
    800053c8:	64a2                	ld	s1,8(sp)
    800053ca:	6105                	add	sp,sp,32
    800053cc:	8082                	ret
      p->ofile[fd] = f;
    800053ce:	01a50793          	add	a5,a0,26
    800053d2:	078e                	sll	a5,a5,0x3
    800053d4:	963e                	add	a2,a2,a5
    800053d6:	e204                	sd	s1,0(a2)
      return fd;
    800053d8:	b7f5                	j	800053c4 <fdalloc+0x2c>

00000000800053da <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800053da:	715d                	add	sp,sp,-80
    800053dc:	e486                	sd	ra,72(sp)
    800053de:	e0a2                	sd	s0,64(sp)
    800053e0:	fc26                	sd	s1,56(sp)
    800053e2:	f84a                	sd	s2,48(sp)
    800053e4:	f44e                	sd	s3,40(sp)
    800053e6:	ec56                	sd	s5,24(sp)
    800053e8:	e85a                	sd	s6,16(sp)
    800053ea:	0880                	add	s0,sp,80
    800053ec:	8b2e                	mv	s6,a1
    800053ee:	89b2                	mv	s3,a2
    800053f0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800053f2:	fb040593          	add	a1,s0,-80
    800053f6:	fffff097          	auipc	ra,0xfffff
    800053fa:	de2080e7          	jalr	-542(ra) # 800041d8 <nameiparent>
    800053fe:	84aa                	mv	s1,a0
    80005400:	14050e63          	beqz	a0,8000555c <create+0x182>
    return 0;

  ilock(dp);
    80005404:	ffffe097          	auipc	ra,0xffffe
    80005408:	5e8080e7          	jalr	1512(ra) # 800039ec <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000540c:	4601                	li	a2,0
    8000540e:	fb040593          	add	a1,s0,-80
    80005412:	8526                	mv	a0,s1
    80005414:	fffff097          	auipc	ra,0xfffff
    80005418:	ae4080e7          	jalr	-1308(ra) # 80003ef8 <dirlookup>
    8000541c:	8aaa                	mv	s5,a0
    8000541e:	c539                	beqz	a0,8000546c <create+0x92>
    iunlockput(dp);
    80005420:	8526                	mv	a0,s1
    80005422:	fffff097          	auipc	ra,0xfffff
    80005426:	830080e7          	jalr	-2000(ra) # 80003c52 <iunlockput>
    ilock(ip);
    8000542a:	8556                	mv	a0,s5
    8000542c:	ffffe097          	auipc	ra,0xffffe
    80005430:	5c0080e7          	jalr	1472(ra) # 800039ec <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005434:	4789                	li	a5,2
    80005436:	02fb1463          	bne	s6,a5,8000545e <create+0x84>
    8000543a:	044ad783          	lhu	a5,68(s5)
    8000543e:	37f9                	addw	a5,a5,-2
    80005440:	17c2                	sll	a5,a5,0x30
    80005442:	93c1                	srl	a5,a5,0x30
    80005444:	4705                	li	a4,1
    80005446:	00f76c63          	bltu	a4,a5,8000545e <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000544a:	8556                	mv	a0,s5
    8000544c:	60a6                	ld	ra,72(sp)
    8000544e:	6406                	ld	s0,64(sp)
    80005450:	74e2                	ld	s1,56(sp)
    80005452:	7942                	ld	s2,48(sp)
    80005454:	79a2                	ld	s3,40(sp)
    80005456:	6ae2                	ld	s5,24(sp)
    80005458:	6b42                	ld	s6,16(sp)
    8000545a:	6161                	add	sp,sp,80
    8000545c:	8082                	ret
    iunlockput(ip);
    8000545e:	8556                	mv	a0,s5
    80005460:	ffffe097          	auipc	ra,0xffffe
    80005464:	7f2080e7          	jalr	2034(ra) # 80003c52 <iunlockput>
    return 0;
    80005468:	4a81                	li	s5,0
    8000546a:	b7c5                	j	8000544a <create+0x70>
    8000546c:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    8000546e:	85da                	mv	a1,s6
    80005470:	4088                	lw	a0,0(s1)
    80005472:	ffffe097          	auipc	ra,0xffffe
    80005476:	3d6080e7          	jalr	982(ra) # 80003848 <ialloc>
    8000547a:	8a2a                	mv	s4,a0
    8000547c:	c531                	beqz	a0,800054c8 <create+0xee>
  ilock(ip);
    8000547e:	ffffe097          	auipc	ra,0xffffe
    80005482:	56e080e7          	jalr	1390(ra) # 800039ec <ilock>
  ip->major = major;
    80005486:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000548a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000548e:	4905                	li	s2,1
    80005490:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005494:	8552                	mv	a0,s4
    80005496:	ffffe097          	auipc	ra,0xffffe
    8000549a:	48a080e7          	jalr	1162(ra) # 80003920 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000549e:	032b0d63          	beq	s6,s2,800054d8 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800054a2:	004a2603          	lw	a2,4(s4)
    800054a6:	fb040593          	add	a1,s0,-80
    800054aa:	8526                	mv	a0,s1
    800054ac:	fffff097          	auipc	ra,0xfffff
    800054b0:	c5c080e7          	jalr	-932(ra) # 80004108 <dirlink>
    800054b4:	08054163          	bltz	a0,80005536 <create+0x15c>
  iunlockput(dp);
    800054b8:	8526                	mv	a0,s1
    800054ba:	ffffe097          	auipc	ra,0xffffe
    800054be:	798080e7          	jalr	1944(ra) # 80003c52 <iunlockput>
  return ip;
    800054c2:	8ad2                	mv	s5,s4
    800054c4:	7a02                	ld	s4,32(sp)
    800054c6:	b751                	j	8000544a <create+0x70>
    iunlockput(dp);
    800054c8:	8526                	mv	a0,s1
    800054ca:	ffffe097          	auipc	ra,0xffffe
    800054ce:	788080e7          	jalr	1928(ra) # 80003c52 <iunlockput>
    return 0;
    800054d2:	8ad2                	mv	s5,s4
    800054d4:	7a02                	ld	s4,32(sp)
    800054d6:	bf95                	j	8000544a <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800054d8:	004a2603          	lw	a2,4(s4)
    800054dc:	00003597          	auipc	a1,0x3
    800054e0:	10c58593          	add	a1,a1,268 # 800085e8 <etext+0x5e8>
    800054e4:	8552                	mv	a0,s4
    800054e6:	fffff097          	auipc	ra,0xfffff
    800054ea:	c22080e7          	jalr	-990(ra) # 80004108 <dirlink>
    800054ee:	04054463          	bltz	a0,80005536 <create+0x15c>
    800054f2:	40d0                	lw	a2,4(s1)
    800054f4:	00003597          	auipc	a1,0x3
    800054f8:	0fc58593          	add	a1,a1,252 # 800085f0 <etext+0x5f0>
    800054fc:	8552                	mv	a0,s4
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	c0a080e7          	jalr	-1014(ra) # 80004108 <dirlink>
    80005506:	02054863          	bltz	a0,80005536 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000550a:	004a2603          	lw	a2,4(s4)
    8000550e:	fb040593          	add	a1,s0,-80
    80005512:	8526                	mv	a0,s1
    80005514:	fffff097          	auipc	ra,0xfffff
    80005518:	bf4080e7          	jalr	-1036(ra) # 80004108 <dirlink>
    8000551c:	00054d63          	bltz	a0,80005536 <create+0x15c>
    dp->nlink++;  // for ".."
    80005520:	04a4d783          	lhu	a5,74(s1)
    80005524:	2785                	addw	a5,a5,1
    80005526:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000552a:	8526                	mv	a0,s1
    8000552c:	ffffe097          	auipc	ra,0xffffe
    80005530:	3f4080e7          	jalr	1012(ra) # 80003920 <iupdate>
    80005534:	b751                	j	800054b8 <create+0xde>
  ip->nlink = 0;
    80005536:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000553a:	8552                	mv	a0,s4
    8000553c:	ffffe097          	auipc	ra,0xffffe
    80005540:	3e4080e7          	jalr	996(ra) # 80003920 <iupdate>
  iunlockput(ip);
    80005544:	8552                	mv	a0,s4
    80005546:	ffffe097          	auipc	ra,0xffffe
    8000554a:	70c080e7          	jalr	1804(ra) # 80003c52 <iunlockput>
  iunlockput(dp);
    8000554e:	8526                	mv	a0,s1
    80005550:	ffffe097          	auipc	ra,0xffffe
    80005554:	702080e7          	jalr	1794(ra) # 80003c52 <iunlockput>
  return 0;
    80005558:	7a02                	ld	s4,32(sp)
    8000555a:	bdc5                	j	8000544a <create+0x70>
    return 0;
    8000555c:	8aaa                	mv	s5,a0
    8000555e:	b5f5                	j	8000544a <create+0x70>

0000000080005560 <sys_dup>:
{
    80005560:	7179                	add	sp,sp,-48
    80005562:	f406                	sd	ra,40(sp)
    80005564:	f022                	sd	s0,32(sp)
    80005566:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005568:	fd840613          	add	a2,s0,-40
    8000556c:	4581                	li	a1,0
    8000556e:	4501                	li	a0,0
    80005570:	00000097          	auipc	ra,0x0
    80005574:	dc8080e7          	jalr	-568(ra) # 80005338 <argfd>
    return -1;
    80005578:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000557a:	02054763          	bltz	a0,800055a8 <sys_dup+0x48>
    8000557e:	ec26                	sd	s1,24(sp)
    80005580:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005582:	fd843903          	ld	s2,-40(s0)
    80005586:	854a                	mv	a0,s2
    80005588:	00000097          	auipc	ra,0x0
    8000558c:	e10080e7          	jalr	-496(ra) # 80005398 <fdalloc>
    80005590:	84aa                	mv	s1,a0
    return -1;
    80005592:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005594:	00054f63          	bltz	a0,800055b2 <sys_dup+0x52>
  filedup(f);
    80005598:	854a                	mv	a0,s2
    8000559a:	fffff097          	auipc	ra,0xfffff
    8000559e:	298080e7          	jalr	664(ra) # 80004832 <filedup>
  return fd;
    800055a2:	87a6                	mv	a5,s1
    800055a4:	64e2                	ld	s1,24(sp)
    800055a6:	6942                	ld	s2,16(sp)
}
    800055a8:	853e                	mv	a0,a5
    800055aa:	70a2                	ld	ra,40(sp)
    800055ac:	7402                	ld	s0,32(sp)
    800055ae:	6145                	add	sp,sp,48
    800055b0:	8082                	ret
    800055b2:	64e2                	ld	s1,24(sp)
    800055b4:	6942                	ld	s2,16(sp)
    800055b6:	bfcd                	j	800055a8 <sys_dup+0x48>

00000000800055b8 <sys_read>:
{
    800055b8:	7179                	add	sp,sp,-48
    800055ba:	f406                	sd	ra,40(sp)
    800055bc:	f022                	sd	s0,32(sp)
    800055be:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800055c0:	fd840593          	add	a1,s0,-40
    800055c4:	4505                	li	a0,1
    800055c6:	ffffe097          	auipc	ra,0xffffe
    800055ca:	884080e7          	jalr	-1916(ra) # 80002e4a <argaddr>
  argint(2, &n);
    800055ce:	fe440593          	add	a1,s0,-28
    800055d2:	4509                	li	a0,2
    800055d4:	ffffe097          	auipc	ra,0xffffe
    800055d8:	856080e7          	jalr	-1962(ra) # 80002e2a <argint>
  if(argfd(0, 0, &f) < 0)
    800055dc:	fe840613          	add	a2,s0,-24
    800055e0:	4581                	li	a1,0
    800055e2:	4501                	li	a0,0
    800055e4:	00000097          	auipc	ra,0x0
    800055e8:	d54080e7          	jalr	-684(ra) # 80005338 <argfd>
    800055ec:	87aa                	mv	a5,a0
    return -1;
    800055ee:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055f0:	0007cc63          	bltz	a5,80005608 <sys_read+0x50>
  return fileread(f, p, n);
    800055f4:	fe442603          	lw	a2,-28(s0)
    800055f8:	fd843583          	ld	a1,-40(s0)
    800055fc:	fe843503          	ld	a0,-24(s0)
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	3d8080e7          	jalr	984(ra) # 800049d8 <fileread>
}
    80005608:	70a2                	ld	ra,40(sp)
    8000560a:	7402                	ld	s0,32(sp)
    8000560c:	6145                	add	sp,sp,48
    8000560e:	8082                	ret

0000000080005610 <sys_write>:
{
    80005610:	7179                	add	sp,sp,-48
    80005612:	f406                	sd	ra,40(sp)
    80005614:	f022                	sd	s0,32(sp)
    80005616:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005618:	fd840593          	add	a1,s0,-40
    8000561c:	4505                	li	a0,1
    8000561e:	ffffe097          	auipc	ra,0xffffe
    80005622:	82c080e7          	jalr	-2004(ra) # 80002e4a <argaddr>
  argint(2, &n);
    80005626:	fe440593          	add	a1,s0,-28
    8000562a:	4509                	li	a0,2
    8000562c:	ffffd097          	auipc	ra,0xffffd
    80005630:	7fe080e7          	jalr	2046(ra) # 80002e2a <argint>
  if(argfd(0, 0, &f) < 0)
    80005634:	fe840613          	add	a2,s0,-24
    80005638:	4581                	li	a1,0
    8000563a:	4501                	li	a0,0
    8000563c:	00000097          	auipc	ra,0x0
    80005640:	cfc080e7          	jalr	-772(ra) # 80005338 <argfd>
    80005644:	87aa                	mv	a5,a0
    return -1;
    80005646:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005648:	0007cc63          	bltz	a5,80005660 <sys_write+0x50>
  return filewrite(f, p, n);
    8000564c:	fe442603          	lw	a2,-28(s0)
    80005650:	fd843583          	ld	a1,-40(s0)
    80005654:	fe843503          	ld	a0,-24(s0)
    80005658:	fffff097          	auipc	ra,0xfffff
    8000565c:	452080e7          	jalr	1106(ra) # 80004aaa <filewrite>
}
    80005660:	70a2                	ld	ra,40(sp)
    80005662:	7402                	ld	s0,32(sp)
    80005664:	6145                	add	sp,sp,48
    80005666:	8082                	ret

0000000080005668 <sys_close>:
{
    80005668:	1101                	add	sp,sp,-32
    8000566a:	ec06                	sd	ra,24(sp)
    8000566c:	e822                	sd	s0,16(sp)
    8000566e:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005670:	fe040613          	add	a2,s0,-32
    80005674:	fec40593          	add	a1,s0,-20
    80005678:	4501                	li	a0,0
    8000567a:	00000097          	auipc	ra,0x0
    8000567e:	cbe080e7          	jalr	-834(ra) # 80005338 <argfd>
    return -1;
    80005682:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005684:	02054463          	bltz	a0,800056ac <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005688:	ffffc097          	auipc	ra,0xffffc
    8000568c:	3da080e7          	jalr	986(ra) # 80001a62 <myproc>
    80005690:	fec42783          	lw	a5,-20(s0)
    80005694:	07e9                	add	a5,a5,26
    80005696:	078e                	sll	a5,a5,0x3
    80005698:	953e                	add	a0,a0,a5
    8000569a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000569e:	fe043503          	ld	a0,-32(s0)
    800056a2:	fffff097          	auipc	ra,0xfffff
    800056a6:	1e2080e7          	jalr	482(ra) # 80004884 <fileclose>
  return 0;
    800056aa:	4781                	li	a5,0
}
    800056ac:	853e                	mv	a0,a5
    800056ae:	60e2                	ld	ra,24(sp)
    800056b0:	6442                	ld	s0,16(sp)
    800056b2:	6105                	add	sp,sp,32
    800056b4:	8082                	ret

00000000800056b6 <sys_fstat>:
{
    800056b6:	1101                	add	sp,sp,-32
    800056b8:	ec06                	sd	ra,24(sp)
    800056ba:	e822                	sd	s0,16(sp)
    800056bc:	1000                	add	s0,sp,32
  argaddr(1, &st);
    800056be:	fe040593          	add	a1,s0,-32
    800056c2:	4505                	li	a0,1
    800056c4:	ffffd097          	auipc	ra,0xffffd
    800056c8:	786080e7          	jalr	1926(ra) # 80002e4a <argaddr>
  if(argfd(0, 0, &f) < 0)
    800056cc:	fe840613          	add	a2,s0,-24
    800056d0:	4581                	li	a1,0
    800056d2:	4501                	li	a0,0
    800056d4:	00000097          	auipc	ra,0x0
    800056d8:	c64080e7          	jalr	-924(ra) # 80005338 <argfd>
    800056dc:	87aa                	mv	a5,a0
    return -1;
    800056de:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056e0:	0007ca63          	bltz	a5,800056f4 <sys_fstat+0x3e>
  return filestat(f, st);
    800056e4:	fe043583          	ld	a1,-32(s0)
    800056e8:	fe843503          	ld	a0,-24(s0)
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	27a080e7          	jalr	634(ra) # 80004966 <filestat>
}
    800056f4:	60e2                	ld	ra,24(sp)
    800056f6:	6442                	ld	s0,16(sp)
    800056f8:	6105                	add	sp,sp,32
    800056fa:	8082                	ret

00000000800056fc <sys_link>:
{
    800056fc:	7169                	add	sp,sp,-304
    800056fe:	f606                	sd	ra,296(sp)
    80005700:	f222                	sd	s0,288(sp)
    80005702:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005704:	08000613          	li	a2,128
    80005708:	ed040593          	add	a1,s0,-304
    8000570c:	4501                	li	a0,0
    8000570e:	ffffd097          	auipc	ra,0xffffd
    80005712:	75c080e7          	jalr	1884(ra) # 80002e6a <argstr>
    return -1;
    80005716:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005718:	12054663          	bltz	a0,80005844 <sys_link+0x148>
    8000571c:	08000613          	li	a2,128
    80005720:	f5040593          	add	a1,s0,-176
    80005724:	4505                	li	a0,1
    80005726:	ffffd097          	auipc	ra,0xffffd
    8000572a:	744080e7          	jalr	1860(ra) # 80002e6a <argstr>
    return -1;
    8000572e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005730:	10054a63          	bltz	a0,80005844 <sys_link+0x148>
    80005734:	ee26                	sd	s1,280(sp)
  begin_op();
    80005736:	fffff097          	auipc	ra,0xfffff
    8000573a:	c84080e7          	jalr	-892(ra) # 800043ba <begin_op>
  if((ip = namei(old)) == 0){
    8000573e:	ed040513          	add	a0,s0,-304
    80005742:	fffff097          	auipc	ra,0xfffff
    80005746:	a78080e7          	jalr	-1416(ra) # 800041ba <namei>
    8000574a:	84aa                	mv	s1,a0
    8000574c:	c949                	beqz	a0,800057de <sys_link+0xe2>
  ilock(ip);
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	29e080e7          	jalr	670(ra) # 800039ec <ilock>
  if(ip->type == T_DIR){
    80005756:	04449703          	lh	a4,68(s1)
    8000575a:	4785                	li	a5,1
    8000575c:	08f70863          	beq	a4,a5,800057ec <sys_link+0xf0>
    80005760:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005762:	04a4d783          	lhu	a5,74(s1)
    80005766:	2785                	addw	a5,a5,1
    80005768:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000576c:	8526                	mv	a0,s1
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	1b2080e7          	jalr	434(ra) # 80003920 <iupdate>
  iunlock(ip);
    80005776:	8526                	mv	a0,s1
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	33a080e7          	jalr	826(ra) # 80003ab2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005780:	fd040593          	add	a1,s0,-48
    80005784:	f5040513          	add	a0,s0,-176
    80005788:	fffff097          	auipc	ra,0xfffff
    8000578c:	a50080e7          	jalr	-1456(ra) # 800041d8 <nameiparent>
    80005790:	892a                	mv	s2,a0
    80005792:	cd35                	beqz	a0,8000580e <sys_link+0x112>
  ilock(dp);
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	258080e7          	jalr	600(ra) # 800039ec <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000579c:	00092703          	lw	a4,0(s2)
    800057a0:	409c                	lw	a5,0(s1)
    800057a2:	06f71163          	bne	a4,a5,80005804 <sys_link+0x108>
    800057a6:	40d0                	lw	a2,4(s1)
    800057a8:	fd040593          	add	a1,s0,-48
    800057ac:	854a                	mv	a0,s2
    800057ae:	fffff097          	auipc	ra,0xfffff
    800057b2:	95a080e7          	jalr	-1702(ra) # 80004108 <dirlink>
    800057b6:	04054763          	bltz	a0,80005804 <sys_link+0x108>
  iunlockput(dp);
    800057ba:	854a                	mv	a0,s2
    800057bc:	ffffe097          	auipc	ra,0xffffe
    800057c0:	496080e7          	jalr	1174(ra) # 80003c52 <iunlockput>
  iput(ip);
    800057c4:	8526                	mv	a0,s1
    800057c6:	ffffe097          	auipc	ra,0xffffe
    800057ca:	3e4080e7          	jalr	996(ra) # 80003baa <iput>
  end_op();
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	c66080e7          	jalr	-922(ra) # 80004434 <end_op>
  return 0;
    800057d6:	4781                	li	a5,0
    800057d8:	64f2                	ld	s1,280(sp)
    800057da:	6952                	ld	s2,272(sp)
    800057dc:	a0a5                	j	80005844 <sys_link+0x148>
    end_op();
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	c56080e7          	jalr	-938(ra) # 80004434 <end_op>
    return -1;
    800057e6:	57fd                	li	a5,-1
    800057e8:	64f2                	ld	s1,280(sp)
    800057ea:	a8a9                	j	80005844 <sys_link+0x148>
    iunlockput(ip);
    800057ec:	8526                	mv	a0,s1
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	464080e7          	jalr	1124(ra) # 80003c52 <iunlockput>
    end_op();
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	c3e080e7          	jalr	-962(ra) # 80004434 <end_op>
    return -1;
    800057fe:	57fd                	li	a5,-1
    80005800:	64f2                	ld	s1,280(sp)
    80005802:	a089                	j	80005844 <sys_link+0x148>
    iunlockput(dp);
    80005804:	854a                	mv	a0,s2
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	44c080e7          	jalr	1100(ra) # 80003c52 <iunlockput>
  ilock(ip);
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	1dc080e7          	jalr	476(ra) # 800039ec <ilock>
  ip->nlink--;
    80005818:	04a4d783          	lhu	a5,74(s1)
    8000581c:	37fd                	addw	a5,a5,-1
    8000581e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005822:	8526                	mv	a0,s1
    80005824:	ffffe097          	auipc	ra,0xffffe
    80005828:	0fc080e7          	jalr	252(ra) # 80003920 <iupdate>
  iunlockput(ip);
    8000582c:	8526                	mv	a0,s1
    8000582e:	ffffe097          	auipc	ra,0xffffe
    80005832:	424080e7          	jalr	1060(ra) # 80003c52 <iunlockput>
  end_op();
    80005836:	fffff097          	auipc	ra,0xfffff
    8000583a:	bfe080e7          	jalr	-1026(ra) # 80004434 <end_op>
  return -1;
    8000583e:	57fd                	li	a5,-1
    80005840:	64f2                	ld	s1,280(sp)
    80005842:	6952                	ld	s2,272(sp)
}
    80005844:	853e                	mv	a0,a5
    80005846:	70b2                	ld	ra,296(sp)
    80005848:	7412                	ld	s0,288(sp)
    8000584a:	6155                	add	sp,sp,304
    8000584c:	8082                	ret

000000008000584e <sys_unlink>:
{
    8000584e:	7151                	add	sp,sp,-240
    80005850:	f586                	sd	ra,232(sp)
    80005852:	f1a2                	sd	s0,224(sp)
    80005854:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005856:	08000613          	li	a2,128
    8000585a:	f3040593          	add	a1,s0,-208
    8000585e:	4501                	li	a0,0
    80005860:	ffffd097          	auipc	ra,0xffffd
    80005864:	60a080e7          	jalr	1546(ra) # 80002e6a <argstr>
    80005868:	1a054a63          	bltz	a0,80005a1c <sys_unlink+0x1ce>
    8000586c:	eda6                	sd	s1,216(sp)
  begin_op();
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	b4c080e7          	jalr	-1204(ra) # 800043ba <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005876:	fb040593          	add	a1,s0,-80
    8000587a:	f3040513          	add	a0,s0,-208
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	95a080e7          	jalr	-1702(ra) # 800041d8 <nameiparent>
    80005886:	84aa                	mv	s1,a0
    80005888:	cd71                	beqz	a0,80005964 <sys_unlink+0x116>
  ilock(dp);
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	162080e7          	jalr	354(ra) # 800039ec <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005892:	00003597          	auipc	a1,0x3
    80005896:	d5658593          	add	a1,a1,-682 # 800085e8 <etext+0x5e8>
    8000589a:	fb040513          	add	a0,s0,-80
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	640080e7          	jalr	1600(ra) # 80003ede <namecmp>
    800058a6:	14050c63          	beqz	a0,800059fe <sys_unlink+0x1b0>
    800058aa:	00003597          	auipc	a1,0x3
    800058ae:	d4658593          	add	a1,a1,-698 # 800085f0 <etext+0x5f0>
    800058b2:	fb040513          	add	a0,s0,-80
    800058b6:	ffffe097          	auipc	ra,0xffffe
    800058ba:	628080e7          	jalr	1576(ra) # 80003ede <namecmp>
    800058be:	14050063          	beqz	a0,800059fe <sys_unlink+0x1b0>
    800058c2:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058c4:	f2c40613          	add	a2,s0,-212
    800058c8:	fb040593          	add	a1,s0,-80
    800058cc:	8526                	mv	a0,s1
    800058ce:	ffffe097          	auipc	ra,0xffffe
    800058d2:	62a080e7          	jalr	1578(ra) # 80003ef8 <dirlookup>
    800058d6:	892a                	mv	s2,a0
    800058d8:	12050263          	beqz	a0,800059fc <sys_unlink+0x1ae>
  ilock(ip);
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	110080e7          	jalr	272(ra) # 800039ec <ilock>
  if(ip->nlink < 1)
    800058e4:	04a91783          	lh	a5,74(s2)
    800058e8:	08f05563          	blez	a5,80005972 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800058ec:	04491703          	lh	a4,68(s2)
    800058f0:	4785                	li	a5,1
    800058f2:	08f70963          	beq	a4,a5,80005984 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    800058f6:	4641                	li	a2,16
    800058f8:	4581                	li	a1,0
    800058fa:	fc040513          	add	a0,s0,-64
    800058fe:	ffffb097          	auipc	ra,0xffffb
    80005902:	436080e7          	jalr	1078(ra) # 80000d34 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005906:	4741                	li	a4,16
    80005908:	f2c42683          	lw	a3,-212(s0)
    8000590c:	fc040613          	add	a2,s0,-64
    80005910:	4581                	li	a1,0
    80005912:	8526                	mv	a0,s1
    80005914:	ffffe097          	auipc	ra,0xffffe
    80005918:	4a0080e7          	jalr	1184(ra) # 80003db4 <writei>
    8000591c:	47c1                	li	a5,16
    8000591e:	0af51b63          	bne	a0,a5,800059d4 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005922:	04491703          	lh	a4,68(s2)
    80005926:	4785                	li	a5,1
    80005928:	0af70f63          	beq	a4,a5,800059e6 <sys_unlink+0x198>
  iunlockput(dp);
    8000592c:	8526                	mv	a0,s1
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	324080e7          	jalr	804(ra) # 80003c52 <iunlockput>
  ip->nlink--;
    80005936:	04a95783          	lhu	a5,74(s2)
    8000593a:	37fd                	addw	a5,a5,-1
    8000593c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005940:	854a                	mv	a0,s2
    80005942:	ffffe097          	auipc	ra,0xffffe
    80005946:	fde080e7          	jalr	-34(ra) # 80003920 <iupdate>
  iunlockput(ip);
    8000594a:	854a                	mv	a0,s2
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	306080e7          	jalr	774(ra) # 80003c52 <iunlockput>
  end_op();
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	ae0080e7          	jalr	-1312(ra) # 80004434 <end_op>
  return 0;
    8000595c:	4501                	li	a0,0
    8000595e:	64ee                	ld	s1,216(sp)
    80005960:	694e                	ld	s2,208(sp)
    80005962:	a84d                	j	80005a14 <sys_unlink+0x1c6>
    end_op();
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	ad0080e7          	jalr	-1328(ra) # 80004434 <end_op>
    return -1;
    8000596c:	557d                	li	a0,-1
    8000596e:	64ee                	ld	s1,216(sp)
    80005970:	a055                	j	80005a14 <sys_unlink+0x1c6>
    80005972:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005974:	00003517          	auipc	a0,0x3
    80005978:	c8450513          	add	a0,a0,-892 # 800085f8 <etext+0x5f8>
    8000597c:	ffffb097          	auipc	ra,0xffffb
    80005980:	be4080e7          	jalr	-1052(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005984:	04c92703          	lw	a4,76(s2)
    80005988:	02000793          	li	a5,32
    8000598c:	f6e7f5e3          	bgeu	a5,a4,800058f6 <sys_unlink+0xa8>
    80005990:	e5ce                	sd	s3,200(sp)
    80005992:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005996:	4741                	li	a4,16
    80005998:	86ce                	mv	a3,s3
    8000599a:	f1840613          	add	a2,s0,-232
    8000599e:	4581                	li	a1,0
    800059a0:	854a                	mv	a0,s2
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	302080e7          	jalr	770(ra) # 80003ca4 <readi>
    800059aa:	47c1                	li	a5,16
    800059ac:	00f51c63          	bne	a0,a5,800059c4 <sys_unlink+0x176>
    if(de.inum != 0)
    800059b0:	f1845783          	lhu	a5,-232(s0)
    800059b4:	e7b5                	bnez	a5,80005a20 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059b6:	29c1                	addw	s3,s3,16
    800059b8:	04c92783          	lw	a5,76(s2)
    800059bc:	fcf9ede3          	bltu	s3,a5,80005996 <sys_unlink+0x148>
    800059c0:	69ae                	ld	s3,200(sp)
    800059c2:	bf15                	j	800058f6 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    800059c4:	00003517          	auipc	a0,0x3
    800059c8:	c4c50513          	add	a0,a0,-948 # 80008610 <etext+0x610>
    800059cc:	ffffb097          	auipc	ra,0xffffb
    800059d0:	b94080e7          	jalr	-1132(ra) # 80000560 <panic>
    800059d4:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800059d6:	00003517          	auipc	a0,0x3
    800059da:	c5250513          	add	a0,a0,-942 # 80008628 <etext+0x628>
    800059de:	ffffb097          	auipc	ra,0xffffb
    800059e2:	b82080e7          	jalr	-1150(ra) # 80000560 <panic>
    dp->nlink--;
    800059e6:	04a4d783          	lhu	a5,74(s1)
    800059ea:	37fd                	addw	a5,a5,-1
    800059ec:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059f0:	8526                	mv	a0,s1
    800059f2:	ffffe097          	auipc	ra,0xffffe
    800059f6:	f2e080e7          	jalr	-210(ra) # 80003920 <iupdate>
    800059fa:	bf0d                	j	8000592c <sys_unlink+0xde>
    800059fc:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800059fe:	8526                	mv	a0,s1
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	252080e7          	jalr	594(ra) # 80003c52 <iunlockput>
  end_op();
    80005a08:	fffff097          	auipc	ra,0xfffff
    80005a0c:	a2c080e7          	jalr	-1492(ra) # 80004434 <end_op>
  return -1;
    80005a10:	557d                	li	a0,-1
    80005a12:	64ee                	ld	s1,216(sp)
}
    80005a14:	70ae                	ld	ra,232(sp)
    80005a16:	740e                	ld	s0,224(sp)
    80005a18:	616d                	add	sp,sp,240
    80005a1a:	8082                	ret
    return -1;
    80005a1c:	557d                	li	a0,-1
    80005a1e:	bfdd                	j	80005a14 <sys_unlink+0x1c6>
    iunlockput(ip);
    80005a20:	854a                	mv	a0,s2
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	230080e7          	jalr	560(ra) # 80003c52 <iunlockput>
    goto bad;
    80005a2a:	694e                	ld	s2,208(sp)
    80005a2c:	69ae                	ld	s3,200(sp)
    80005a2e:	bfc1                	j	800059fe <sys_unlink+0x1b0>

0000000080005a30 <sys_open>:

uint64
sys_open(void)
{
    80005a30:	7131                	add	sp,sp,-192
    80005a32:	fd06                	sd	ra,184(sp)
    80005a34:	f922                	sd	s0,176(sp)
    80005a36:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005a38:	f4c40593          	add	a1,s0,-180
    80005a3c:	4505                	li	a0,1
    80005a3e:	ffffd097          	auipc	ra,0xffffd
    80005a42:	3ec080e7          	jalr	1004(ra) # 80002e2a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a46:	08000613          	li	a2,128
    80005a4a:	f5040593          	add	a1,s0,-176
    80005a4e:	4501                	li	a0,0
    80005a50:	ffffd097          	auipc	ra,0xffffd
    80005a54:	41a080e7          	jalr	1050(ra) # 80002e6a <argstr>
    80005a58:	87aa                	mv	a5,a0
    return -1;
    80005a5a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a5c:	0a07ce63          	bltz	a5,80005b18 <sys_open+0xe8>
    80005a60:	f526                	sd	s1,168(sp)

  begin_op();
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	958080e7          	jalr	-1704(ra) # 800043ba <begin_op>

  if(omode & O_CREATE){
    80005a6a:	f4c42783          	lw	a5,-180(s0)
    80005a6e:	2007f793          	and	a5,a5,512
    80005a72:	cfd5                	beqz	a5,80005b2e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a74:	4681                	li	a3,0
    80005a76:	4601                	li	a2,0
    80005a78:	4589                	li	a1,2
    80005a7a:	f5040513          	add	a0,s0,-176
    80005a7e:	00000097          	auipc	ra,0x0
    80005a82:	95c080e7          	jalr	-1700(ra) # 800053da <create>
    80005a86:	84aa                	mv	s1,a0
    if(ip == 0){
    80005a88:	cd41                	beqz	a0,80005b20 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a8a:	04449703          	lh	a4,68(s1)
    80005a8e:	478d                	li	a5,3
    80005a90:	00f71763          	bne	a4,a5,80005a9e <sys_open+0x6e>
    80005a94:	0464d703          	lhu	a4,70(s1)
    80005a98:	47a5                	li	a5,9
    80005a9a:	0ee7e163          	bltu	a5,a4,80005b7c <sys_open+0x14c>
    80005a9e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005aa0:	fffff097          	auipc	ra,0xfffff
    80005aa4:	d28080e7          	jalr	-728(ra) # 800047c8 <filealloc>
    80005aa8:	892a                	mv	s2,a0
    80005aaa:	c97d                	beqz	a0,80005ba0 <sys_open+0x170>
    80005aac:	ed4e                	sd	s3,152(sp)
    80005aae:	00000097          	auipc	ra,0x0
    80005ab2:	8ea080e7          	jalr	-1814(ra) # 80005398 <fdalloc>
    80005ab6:	89aa                	mv	s3,a0
    80005ab8:	0c054e63          	bltz	a0,80005b94 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005abc:	04449703          	lh	a4,68(s1)
    80005ac0:	478d                	li	a5,3
    80005ac2:	0ef70c63          	beq	a4,a5,80005bba <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ac6:	4789                	li	a5,2
    80005ac8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005acc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005ad0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005ad4:	f4c42783          	lw	a5,-180(s0)
    80005ad8:	0017c713          	xor	a4,a5,1
    80005adc:	8b05                	and	a4,a4,1
    80005ade:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ae2:	0037f713          	and	a4,a5,3
    80005ae6:	00e03733          	snez	a4,a4
    80005aea:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005aee:	4007f793          	and	a5,a5,1024
    80005af2:	c791                	beqz	a5,80005afe <sys_open+0xce>
    80005af4:	04449703          	lh	a4,68(s1)
    80005af8:	4789                	li	a5,2
    80005afa:	0cf70763          	beq	a4,a5,80005bc8 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005afe:	8526                	mv	a0,s1
    80005b00:	ffffe097          	auipc	ra,0xffffe
    80005b04:	fb2080e7          	jalr	-78(ra) # 80003ab2 <iunlock>
  end_op();
    80005b08:	fffff097          	auipc	ra,0xfffff
    80005b0c:	92c080e7          	jalr	-1748(ra) # 80004434 <end_op>

  return fd;
    80005b10:	854e                	mv	a0,s3
    80005b12:	74aa                	ld	s1,168(sp)
    80005b14:	790a                	ld	s2,160(sp)
    80005b16:	69ea                	ld	s3,152(sp)
}
    80005b18:	70ea                	ld	ra,184(sp)
    80005b1a:	744a                	ld	s0,176(sp)
    80005b1c:	6129                	add	sp,sp,192
    80005b1e:	8082                	ret
      end_op();
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	914080e7          	jalr	-1772(ra) # 80004434 <end_op>
      return -1;
    80005b28:	557d                	li	a0,-1
    80005b2a:	74aa                	ld	s1,168(sp)
    80005b2c:	b7f5                	j	80005b18 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005b2e:	f5040513          	add	a0,s0,-176
    80005b32:	ffffe097          	auipc	ra,0xffffe
    80005b36:	688080e7          	jalr	1672(ra) # 800041ba <namei>
    80005b3a:	84aa                	mv	s1,a0
    80005b3c:	c90d                	beqz	a0,80005b6e <sys_open+0x13e>
    ilock(ip);
    80005b3e:	ffffe097          	auipc	ra,0xffffe
    80005b42:	eae080e7          	jalr	-338(ra) # 800039ec <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b46:	04449703          	lh	a4,68(s1)
    80005b4a:	4785                	li	a5,1
    80005b4c:	f2f71fe3          	bne	a4,a5,80005a8a <sys_open+0x5a>
    80005b50:	f4c42783          	lw	a5,-180(s0)
    80005b54:	d7a9                	beqz	a5,80005a9e <sys_open+0x6e>
      iunlockput(ip);
    80005b56:	8526                	mv	a0,s1
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	0fa080e7          	jalr	250(ra) # 80003c52 <iunlockput>
      end_op();
    80005b60:	fffff097          	auipc	ra,0xfffff
    80005b64:	8d4080e7          	jalr	-1836(ra) # 80004434 <end_op>
      return -1;
    80005b68:	557d                	li	a0,-1
    80005b6a:	74aa                	ld	s1,168(sp)
    80005b6c:	b775                	j	80005b18 <sys_open+0xe8>
      end_op();
    80005b6e:	fffff097          	auipc	ra,0xfffff
    80005b72:	8c6080e7          	jalr	-1850(ra) # 80004434 <end_op>
      return -1;
    80005b76:	557d                	li	a0,-1
    80005b78:	74aa                	ld	s1,168(sp)
    80005b7a:	bf79                	j	80005b18 <sys_open+0xe8>
    iunlockput(ip);
    80005b7c:	8526                	mv	a0,s1
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	0d4080e7          	jalr	212(ra) # 80003c52 <iunlockput>
    end_op();
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	8ae080e7          	jalr	-1874(ra) # 80004434 <end_op>
    return -1;
    80005b8e:	557d                	li	a0,-1
    80005b90:	74aa                	ld	s1,168(sp)
    80005b92:	b759                	j	80005b18 <sys_open+0xe8>
      fileclose(f);
    80005b94:	854a                	mv	a0,s2
    80005b96:	fffff097          	auipc	ra,0xfffff
    80005b9a:	cee080e7          	jalr	-786(ra) # 80004884 <fileclose>
    80005b9e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005ba0:	8526                	mv	a0,s1
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	0b0080e7          	jalr	176(ra) # 80003c52 <iunlockput>
    end_op();
    80005baa:	fffff097          	auipc	ra,0xfffff
    80005bae:	88a080e7          	jalr	-1910(ra) # 80004434 <end_op>
    return -1;
    80005bb2:	557d                	li	a0,-1
    80005bb4:	74aa                	ld	s1,168(sp)
    80005bb6:	790a                	ld	s2,160(sp)
    80005bb8:	b785                	j	80005b18 <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005bba:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005bbe:	04649783          	lh	a5,70(s1)
    80005bc2:	02f91223          	sh	a5,36(s2)
    80005bc6:	b729                	j	80005ad0 <sys_open+0xa0>
    itrunc(ip);
    80005bc8:	8526                	mv	a0,s1
    80005bca:	ffffe097          	auipc	ra,0xffffe
    80005bce:	f34080e7          	jalr	-204(ra) # 80003afe <itrunc>
    80005bd2:	b735                	j	80005afe <sys_open+0xce>

0000000080005bd4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bd4:	7175                	add	sp,sp,-144
    80005bd6:	e506                	sd	ra,136(sp)
    80005bd8:	e122                	sd	s0,128(sp)
    80005bda:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005bdc:	ffffe097          	auipc	ra,0xffffe
    80005be0:	7de080e7          	jalr	2014(ra) # 800043ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005be4:	08000613          	li	a2,128
    80005be8:	f7040593          	add	a1,s0,-144
    80005bec:	4501                	li	a0,0
    80005bee:	ffffd097          	auipc	ra,0xffffd
    80005bf2:	27c080e7          	jalr	636(ra) # 80002e6a <argstr>
    80005bf6:	02054963          	bltz	a0,80005c28 <sys_mkdir+0x54>
    80005bfa:	4681                	li	a3,0
    80005bfc:	4601                	li	a2,0
    80005bfe:	4585                	li	a1,1
    80005c00:	f7040513          	add	a0,s0,-144
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	7d6080e7          	jalr	2006(ra) # 800053da <create>
    80005c0c:	cd11                	beqz	a0,80005c28 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c0e:	ffffe097          	auipc	ra,0xffffe
    80005c12:	044080e7          	jalr	68(ra) # 80003c52 <iunlockput>
  end_op();
    80005c16:	fffff097          	auipc	ra,0xfffff
    80005c1a:	81e080e7          	jalr	-2018(ra) # 80004434 <end_op>
  return 0;
    80005c1e:	4501                	li	a0,0
}
    80005c20:	60aa                	ld	ra,136(sp)
    80005c22:	640a                	ld	s0,128(sp)
    80005c24:	6149                	add	sp,sp,144
    80005c26:	8082                	ret
    end_op();
    80005c28:	fffff097          	auipc	ra,0xfffff
    80005c2c:	80c080e7          	jalr	-2036(ra) # 80004434 <end_op>
    return -1;
    80005c30:	557d                	li	a0,-1
    80005c32:	b7fd                	j	80005c20 <sys_mkdir+0x4c>

0000000080005c34 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c34:	7135                	add	sp,sp,-160
    80005c36:	ed06                	sd	ra,152(sp)
    80005c38:	e922                	sd	s0,144(sp)
    80005c3a:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	77e080e7          	jalr	1918(ra) # 800043ba <begin_op>
  argint(1, &major);
    80005c44:	f6c40593          	add	a1,s0,-148
    80005c48:	4505                	li	a0,1
    80005c4a:	ffffd097          	auipc	ra,0xffffd
    80005c4e:	1e0080e7          	jalr	480(ra) # 80002e2a <argint>
  argint(2, &minor);
    80005c52:	f6840593          	add	a1,s0,-152
    80005c56:	4509                	li	a0,2
    80005c58:	ffffd097          	auipc	ra,0xffffd
    80005c5c:	1d2080e7          	jalr	466(ra) # 80002e2a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c60:	08000613          	li	a2,128
    80005c64:	f7040593          	add	a1,s0,-144
    80005c68:	4501                	li	a0,0
    80005c6a:	ffffd097          	auipc	ra,0xffffd
    80005c6e:	200080e7          	jalr	512(ra) # 80002e6a <argstr>
    80005c72:	02054b63          	bltz	a0,80005ca8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c76:	f6841683          	lh	a3,-152(s0)
    80005c7a:	f6c41603          	lh	a2,-148(s0)
    80005c7e:	458d                	li	a1,3
    80005c80:	f7040513          	add	a0,s0,-144
    80005c84:	fffff097          	auipc	ra,0xfffff
    80005c88:	756080e7          	jalr	1878(ra) # 800053da <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c8c:	cd11                	beqz	a0,80005ca8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c8e:	ffffe097          	auipc	ra,0xffffe
    80005c92:	fc4080e7          	jalr	-60(ra) # 80003c52 <iunlockput>
  end_op();
    80005c96:	ffffe097          	auipc	ra,0xffffe
    80005c9a:	79e080e7          	jalr	1950(ra) # 80004434 <end_op>
  return 0;
    80005c9e:	4501                	li	a0,0
}
    80005ca0:	60ea                	ld	ra,152(sp)
    80005ca2:	644a                	ld	s0,144(sp)
    80005ca4:	610d                	add	sp,sp,160
    80005ca6:	8082                	ret
    end_op();
    80005ca8:	ffffe097          	auipc	ra,0xffffe
    80005cac:	78c080e7          	jalr	1932(ra) # 80004434 <end_op>
    return -1;
    80005cb0:	557d                	li	a0,-1
    80005cb2:	b7fd                	j	80005ca0 <sys_mknod+0x6c>

0000000080005cb4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005cb4:	7135                	add	sp,sp,-160
    80005cb6:	ed06                	sd	ra,152(sp)
    80005cb8:	e922                	sd	s0,144(sp)
    80005cba:	e14a                	sd	s2,128(sp)
    80005cbc:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cbe:	ffffc097          	auipc	ra,0xffffc
    80005cc2:	da4080e7          	jalr	-604(ra) # 80001a62 <myproc>
    80005cc6:	892a                	mv	s2,a0
  
  begin_op();
    80005cc8:	ffffe097          	auipc	ra,0xffffe
    80005ccc:	6f2080e7          	jalr	1778(ra) # 800043ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cd0:	08000613          	li	a2,128
    80005cd4:	f6040593          	add	a1,s0,-160
    80005cd8:	4501                	li	a0,0
    80005cda:	ffffd097          	auipc	ra,0xffffd
    80005cde:	190080e7          	jalr	400(ra) # 80002e6a <argstr>
    80005ce2:	04054d63          	bltz	a0,80005d3c <sys_chdir+0x88>
    80005ce6:	e526                	sd	s1,136(sp)
    80005ce8:	f6040513          	add	a0,s0,-160
    80005cec:	ffffe097          	auipc	ra,0xffffe
    80005cf0:	4ce080e7          	jalr	1230(ra) # 800041ba <namei>
    80005cf4:	84aa                	mv	s1,a0
    80005cf6:	c131                	beqz	a0,80005d3a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	cf4080e7          	jalr	-780(ra) # 800039ec <ilock>
  if(ip->type != T_DIR){
    80005d00:	04449703          	lh	a4,68(s1)
    80005d04:	4785                	li	a5,1
    80005d06:	04f71163          	bne	a4,a5,80005d48 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d0a:	8526                	mv	a0,s1
    80005d0c:	ffffe097          	auipc	ra,0xffffe
    80005d10:	da6080e7          	jalr	-602(ra) # 80003ab2 <iunlock>
  iput(p->cwd);
    80005d14:	15093503          	ld	a0,336(s2)
    80005d18:	ffffe097          	auipc	ra,0xffffe
    80005d1c:	e92080e7          	jalr	-366(ra) # 80003baa <iput>
  end_op();
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	714080e7          	jalr	1812(ra) # 80004434 <end_op>
  p->cwd = ip;
    80005d28:	14993823          	sd	s1,336(s2)
  return 0;
    80005d2c:	4501                	li	a0,0
    80005d2e:	64aa                	ld	s1,136(sp)
}
    80005d30:	60ea                	ld	ra,152(sp)
    80005d32:	644a                	ld	s0,144(sp)
    80005d34:	690a                	ld	s2,128(sp)
    80005d36:	610d                	add	sp,sp,160
    80005d38:	8082                	ret
    80005d3a:	64aa                	ld	s1,136(sp)
    end_op();
    80005d3c:	ffffe097          	auipc	ra,0xffffe
    80005d40:	6f8080e7          	jalr	1784(ra) # 80004434 <end_op>
    return -1;
    80005d44:	557d                	li	a0,-1
    80005d46:	b7ed                	j	80005d30 <sys_chdir+0x7c>
    iunlockput(ip);
    80005d48:	8526                	mv	a0,s1
    80005d4a:	ffffe097          	auipc	ra,0xffffe
    80005d4e:	f08080e7          	jalr	-248(ra) # 80003c52 <iunlockput>
    end_op();
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	6e2080e7          	jalr	1762(ra) # 80004434 <end_op>
    return -1;
    80005d5a:	557d                	li	a0,-1
    80005d5c:	64aa                	ld	s1,136(sp)
    80005d5e:	bfc9                	j	80005d30 <sys_chdir+0x7c>

0000000080005d60 <sys_exec>:

uint64
sys_exec(void)
{
    80005d60:	7121                	add	sp,sp,-448
    80005d62:	ff06                	sd	ra,440(sp)
    80005d64:	fb22                	sd	s0,432(sp)
    80005d66:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005d68:	e4840593          	add	a1,s0,-440
    80005d6c:	4505                	li	a0,1
    80005d6e:	ffffd097          	auipc	ra,0xffffd
    80005d72:	0dc080e7          	jalr	220(ra) # 80002e4a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005d76:	08000613          	li	a2,128
    80005d7a:	f5040593          	add	a1,s0,-176
    80005d7e:	4501                	li	a0,0
    80005d80:	ffffd097          	auipc	ra,0xffffd
    80005d84:	0ea080e7          	jalr	234(ra) # 80002e6a <argstr>
    80005d88:	87aa                	mv	a5,a0
    return -1;
    80005d8a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d8c:	0e07c263          	bltz	a5,80005e70 <sys_exec+0x110>
    80005d90:	f726                	sd	s1,424(sp)
    80005d92:	f34a                	sd	s2,416(sp)
    80005d94:	ef4e                	sd	s3,408(sp)
    80005d96:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005d98:	10000613          	li	a2,256
    80005d9c:	4581                	li	a1,0
    80005d9e:	e5040513          	add	a0,s0,-432
    80005da2:	ffffb097          	auipc	ra,0xffffb
    80005da6:	f92080e7          	jalr	-110(ra) # 80000d34 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005daa:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005dae:	89a6                	mv	s3,s1
    80005db0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005db2:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005db6:	00391513          	sll	a0,s2,0x3
    80005dba:	e4040593          	add	a1,s0,-448
    80005dbe:	e4843783          	ld	a5,-440(s0)
    80005dc2:	953e                	add	a0,a0,a5
    80005dc4:	ffffd097          	auipc	ra,0xffffd
    80005dc8:	fc8080e7          	jalr	-56(ra) # 80002d8c <fetchaddr>
    80005dcc:	02054a63          	bltz	a0,80005e00 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005dd0:	e4043783          	ld	a5,-448(s0)
    80005dd4:	c7b9                	beqz	a5,80005e22 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005dd6:	ffffb097          	auipc	ra,0xffffb
    80005dda:	d72080e7          	jalr	-654(ra) # 80000b48 <kalloc>
    80005dde:	85aa                	mv	a1,a0
    80005de0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005de4:	cd11                	beqz	a0,80005e00 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005de6:	6605                	lui	a2,0x1
    80005de8:	e4043503          	ld	a0,-448(s0)
    80005dec:	ffffd097          	auipc	ra,0xffffd
    80005df0:	ff2080e7          	jalr	-14(ra) # 80002dde <fetchstr>
    80005df4:	00054663          	bltz	a0,80005e00 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005df8:	0905                	add	s2,s2,1
    80005dfa:	09a1                	add	s3,s3,8
    80005dfc:	fb491de3          	bne	s2,s4,80005db6 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e00:	f5040913          	add	s2,s0,-176
    80005e04:	6088                	ld	a0,0(s1)
    80005e06:	c125                	beqz	a0,80005e66 <sys_exec+0x106>
    kfree(argv[i]);
    80005e08:	ffffb097          	auipc	ra,0xffffb
    80005e0c:	c42080e7          	jalr	-958(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e10:	04a1                	add	s1,s1,8
    80005e12:	ff2499e3          	bne	s1,s2,80005e04 <sys_exec+0xa4>
  return -1;
    80005e16:	557d                	li	a0,-1
    80005e18:	74ba                	ld	s1,424(sp)
    80005e1a:	791a                	ld	s2,416(sp)
    80005e1c:	69fa                	ld	s3,408(sp)
    80005e1e:	6a5a                	ld	s4,400(sp)
    80005e20:	a881                	j	80005e70 <sys_exec+0x110>
      argv[i] = 0;
    80005e22:	0009079b          	sext.w	a5,s2
    80005e26:	078e                	sll	a5,a5,0x3
    80005e28:	fd078793          	add	a5,a5,-48
    80005e2c:	97a2                	add	a5,a5,s0
    80005e2e:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005e32:	e5040593          	add	a1,s0,-432
    80005e36:	f5040513          	add	a0,s0,-176
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	120080e7          	jalr	288(ra) # 80004f5a <exec>
    80005e42:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e44:	f5040993          	add	s3,s0,-176
    80005e48:	6088                	ld	a0,0(s1)
    80005e4a:	c901                	beqz	a0,80005e5a <sys_exec+0xfa>
    kfree(argv[i]);
    80005e4c:	ffffb097          	auipc	ra,0xffffb
    80005e50:	bfe080e7          	jalr	-1026(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e54:	04a1                	add	s1,s1,8
    80005e56:	ff3499e3          	bne	s1,s3,80005e48 <sys_exec+0xe8>
  return ret;
    80005e5a:	854a                	mv	a0,s2
    80005e5c:	74ba                	ld	s1,424(sp)
    80005e5e:	791a                	ld	s2,416(sp)
    80005e60:	69fa                	ld	s3,408(sp)
    80005e62:	6a5a                	ld	s4,400(sp)
    80005e64:	a031                	j	80005e70 <sys_exec+0x110>
  return -1;
    80005e66:	557d                	li	a0,-1
    80005e68:	74ba                	ld	s1,424(sp)
    80005e6a:	791a                	ld	s2,416(sp)
    80005e6c:	69fa                	ld	s3,408(sp)
    80005e6e:	6a5a                	ld	s4,400(sp)
}
    80005e70:	70fa                	ld	ra,440(sp)
    80005e72:	745a                	ld	s0,432(sp)
    80005e74:	6139                	add	sp,sp,448
    80005e76:	8082                	ret

0000000080005e78 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e78:	7139                	add	sp,sp,-64
    80005e7a:	fc06                	sd	ra,56(sp)
    80005e7c:	f822                	sd	s0,48(sp)
    80005e7e:	f426                	sd	s1,40(sp)
    80005e80:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e82:	ffffc097          	auipc	ra,0xffffc
    80005e86:	be0080e7          	jalr	-1056(ra) # 80001a62 <myproc>
    80005e8a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005e8c:	fd840593          	add	a1,s0,-40
    80005e90:	4501                	li	a0,0
    80005e92:	ffffd097          	auipc	ra,0xffffd
    80005e96:	fb8080e7          	jalr	-72(ra) # 80002e4a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005e9a:	fc840593          	add	a1,s0,-56
    80005e9e:	fd040513          	add	a0,s0,-48
    80005ea2:	fffff097          	auipc	ra,0xfffff
    80005ea6:	d50080e7          	jalr	-688(ra) # 80004bf2 <pipealloc>
    return -1;
    80005eaa:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005eac:	0c054463          	bltz	a0,80005f74 <sys_pipe+0xfc>
  fd0 = -1;
    80005eb0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005eb4:	fd043503          	ld	a0,-48(s0)
    80005eb8:	fffff097          	auipc	ra,0xfffff
    80005ebc:	4e0080e7          	jalr	1248(ra) # 80005398 <fdalloc>
    80005ec0:	fca42223          	sw	a0,-60(s0)
    80005ec4:	08054b63          	bltz	a0,80005f5a <sys_pipe+0xe2>
    80005ec8:	fc843503          	ld	a0,-56(s0)
    80005ecc:	fffff097          	auipc	ra,0xfffff
    80005ed0:	4cc080e7          	jalr	1228(ra) # 80005398 <fdalloc>
    80005ed4:	fca42023          	sw	a0,-64(s0)
    80005ed8:	06054863          	bltz	a0,80005f48 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005edc:	4691                	li	a3,4
    80005ede:	fc440613          	add	a2,s0,-60
    80005ee2:	fd843583          	ld	a1,-40(s0)
    80005ee6:	68a8                	ld	a0,80(s1)
    80005ee8:	ffffb097          	auipc	ra,0xffffb
    80005eec:	7fa080e7          	jalr	2042(ra) # 800016e2 <copyout>
    80005ef0:	02054063          	bltz	a0,80005f10 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ef4:	4691                	li	a3,4
    80005ef6:	fc040613          	add	a2,s0,-64
    80005efa:	fd843583          	ld	a1,-40(s0)
    80005efe:	0591                	add	a1,a1,4
    80005f00:	68a8                	ld	a0,80(s1)
    80005f02:	ffffb097          	auipc	ra,0xffffb
    80005f06:	7e0080e7          	jalr	2016(ra) # 800016e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f0a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f0c:	06055463          	bgez	a0,80005f74 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005f10:	fc442783          	lw	a5,-60(s0)
    80005f14:	07e9                	add	a5,a5,26
    80005f16:	078e                	sll	a5,a5,0x3
    80005f18:	97a6                	add	a5,a5,s1
    80005f1a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f1e:	fc042783          	lw	a5,-64(s0)
    80005f22:	07e9                	add	a5,a5,26
    80005f24:	078e                	sll	a5,a5,0x3
    80005f26:	94be                	add	s1,s1,a5
    80005f28:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f2c:	fd043503          	ld	a0,-48(s0)
    80005f30:	fffff097          	auipc	ra,0xfffff
    80005f34:	954080e7          	jalr	-1708(ra) # 80004884 <fileclose>
    fileclose(wf);
    80005f38:	fc843503          	ld	a0,-56(s0)
    80005f3c:	fffff097          	auipc	ra,0xfffff
    80005f40:	948080e7          	jalr	-1720(ra) # 80004884 <fileclose>
    return -1;
    80005f44:	57fd                	li	a5,-1
    80005f46:	a03d                	j	80005f74 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005f48:	fc442783          	lw	a5,-60(s0)
    80005f4c:	0007c763          	bltz	a5,80005f5a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005f50:	07e9                	add	a5,a5,26
    80005f52:	078e                	sll	a5,a5,0x3
    80005f54:	97a6                	add	a5,a5,s1
    80005f56:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005f5a:	fd043503          	ld	a0,-48(s0)
    80005f5e:	fffff097          	auipc	ra,0xfffff
    80005f62:	926080e7          	jalr	-1754(ra) # 80004884 <fileclose>
    fileclose(wf);
    80005f66:	fc843503          	ld	a0,-56(s0)
    80005f6a:	fffff097          	auipc	ra,0xfffff
    80005f6e:	91a080e7          	jalr	-1766(ra) # 80004884 <fileclose>
    return -1;
    80005f72:	57fd                	li	a5,-1
}
    80005f74:	853e                	mv	a0,a5
    80005f76:	70e2                	ld	ra,56(sp)
    80005f78:	7442                	ld	s0,48(sp)
    80005f7a:	74a2                	ld	s1,40(sp)
    80005f7c:	6121                	add	sp,sp,64
    80005f7e:	8082                	ret

0000000080005f80 <kernelvec>:
    80005f80:	7111                	add	sp,sp,-256
    80005f82:	e006                	sd	ra,0(sp)
    80005f84:	e40a                	sd	sp,8(sp)
    80005f86:	e80e                	sd	gp,16(sp)
    80005f88:	ec12                	sd	tp,24(sp)
    80005f8a:	f016                	sd	t0,32(sp)
    80005f8c:	f41a                	sd	t1,40(sp)
    80005f8e:	f81e                	sd	t2,48(sp)
    80005f90:	fc22                	sd	s0,56(sp)
    80005f92:	e0a6                	sd	s1,64(sp)
    80005f94:	e4aa                	sd	a0,72(sp)
    80005f96:	e8ae                	sd	a1,80(sp)
    80005f98:	ecb2                	sd	a2,88(sp)
    80005f9a:	f0b6                	sd	a3,96(sp)
    80005f9c:	f4ba                	sd	a4,104(sp)
    80005f9e:	f8be                	sd	a5,112(sp)
    80005fa0:	fcc2                	sd	a6,120(sp)
    80005fa2:	e146                	sd	a7,128(sp)
    80005fa4:	e54a                	sd	s2,136(sp)
    80005fa6:	e94e                	sd	s3,144(sp)
    80005fa8:	ed52                	sd	s4,152(sp)
    80005faa:	f156                	sd	s5,160(sp)
    80005fac:	f55a                	sd	s6,168(sp)
    80005fae:	f95e                	sd	s7,176(sp)
    80005fb0:	fd62                	sd	s8,184(sp)
    80005fb2:	e1e6                	sd	s9,192(sp)
    80005fb4:	e5ea                	sd	s10,200(sp)
    80005fb6:	e9ee                	sd	s11,208(sp)
    80005fb8:	edf2                	sd	t3,216(sp)
    80005fba:	f1f6                	sd	t4,224(sp)
    80005fbc:	f5fa                	sd	t5,232(sp)
    80005fbe:	f9fe                	sd	t6,240(sp)
    80005fc0:	c99fc0ef          	jal	80002c58 <kerneltrap>
    80005fc4:	6082                	ld	ra,0(sp)
    80005fc6:	6122                	ld	sp,8(sp)
    80005fc8:	61c2                	ld	gp,16(sp)
    80005fca:	7282                	ld	t0,32(sp)
    80005fcc:	7322                	ld	t1,40(sp)
    80005fce:	73c2                	ld	t2,48(sp)
    80005fd0:	7462                	ld	s0,56(sp)
    80005fd2:	6486                	ld	s1,64(sp)
    80005fd4:	6526                	ld	a0,72(sp)
    80005fd6:	65c6                	ld	a1,80(sp)
    80005fd8:	6666                	ld	a2,88(sp)
    80005fda:	7686                	ld	a3,96(sp)
    80005fdc:	7726                	ld	a4,104(sp)
    80005fde:	77c6                	ld	a5,112(sp)
    80005fe0:	7866                	ld	a6,120(sp)
    80005fe2:	688a                	ld	a7,128(sp)
    80005fe4:	692a                	ld	s2,136(sp)
    80005fe6:	69ca                	ld	s3,144(sp)
    80005fe8:	6a6a                	ld	s4,152(sp)
    80005fea:	7a8a                	ld	s5,160(sp)
    80005fec:	7b2a                	ld	s6,168(sp)
    80005fee:	7bca                	ld	s7,176(sp)
    80005ff0:	7c6a                	ld	s8,184(sp)
    80005ff2:	6c8e                	ld	s9,192(sp)
    80005ff4:	6d2e                	ld	s10,200(sp)
    80005ff6:	6dce                	ld	s11,208(sp)
    80005ff8:	6e6e                	ld	t3,216(sp)
    80005ffa:	7e8e                	ld	t4,224(sp)
    80005ffc:	7f2e                	ld	t5,232(sp)
    80005ffe:	7fce                	ld	t6,240(sp)
    80006000:	6111                	add	sp,sp,256
    80006002:	10200073          	sret
    80006006:	00000013          	nop
    8000600a:	00000013          	nop
    8000600e:	0001                	nop

0000000080006010 <timervec>:
    80006010:	34051573          	csrrw	a0,mscratch,a0
    80006014:	e10c                	sd	a1,0(a0)
    80006016:	e510                	sd	a2,8(a0)
    80006018:	e914                	sd	a3,16(a0)
    8000601a:	6d0c                	ld	a1,24(a0)
    8000601c:	7110                	ld	a2,32(a0)
    8000601e:	6194                	ld	a3,0(a1)
    80006020:	96b2                	add	a3,a3,a2
    80006022:	e194                	sd	a3,0(a1)
    80006024:	4589                	li	a1,2
    80006026:	14459073          	csrw	sip,a1
    8000602a:	6914                	ld	a3,16(a0)
    8000602c:	6510                	ld	a2,8(a0)
    8000602e:	610c                	ld	a1,0(a0)
    80006030:	34051573          	csrrw	a0,mscratch,a0
    80006034:	30200073          	mret
	...

000000008000603a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000603a:	1141                	add	sp,sp,-16
    8000603c:	e422                	sd	s0,8(sp)
    8000603e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006040:	0c0007b7          	lui	a5,0xc000
    80006044:	4705                	li	a4,1
    80006046:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006048:	0c0007b7          	lui	a5,0xc000
    8000604c:	c3d8                	sw	a4,4(a5)
}
    8000604e:	6422                	ld	s0,8(sp)
    80006050:	0141                	add	sp,sp,16
    80006052:	8082                	ret

0000000080006054 <plicinithart>:

void
plicinithart(void)
{
    80006054:	1141                	add	sp,sp,-16
    80006056:	e406                	sd	ra,8(sp)
    80006058:	e022                	sd	s0,0(sp)
    8000605a:	0800                	add	s0,sp,16
  int hart = cpuid();
    8000605c:	ffffc097          	auipc	ra,0xffffc
    80006060:	9da080e7          	jalr	-1574(ra) # 80001a36 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006064:	0085171b          	sllw	a4,a0,0x8
    80006068:	0c0027b7          	lui	a5,0xc002
    8000606c:	97ba                	add	a5,a5,a4
    8000606e:	40200713          	li	a4,1026
    80006072:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006076:	00d5151b          	sllw	a0,a0,0xd
    8000607a:	0c2017b7          	lui	a5,0xc201
    8000607e:	97aa                	add	a5,a5,a0
    80006080:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006084:	60a2                	ld	ra,8(sp)
    80006086:	6402                	ld	s0,0(sp)
    80006088:	0141                	add	sp,sp,16
    8000608a:	8082                	ret

000000008000608c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000608c:	1141                	add	sp,sp,-16
    8000608e:	e406                	sd	ra,8(sp)
    80006090:	e022                	sd	s0,0(sp)
    80006092:	0800                	add	s0,sp,16
  int hart = cpuid();
    80006094:	ffffc097          	auipc	ra,0xffffc
    80006098:	9a2080e7          	jalr	-1630(ra) # 80001a36 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000609c:	00d5151b          	sllw	a0,a0,0xd
    800060a0:	0c2017b7          	lui	a5,0xc201
    800060a4:	97aa                	add	a5,a5,a0
  return irq;
}
    800060a6:	43c8                	lw	a0,4(a5)
    800060a8:	60a2                	ld	ra,8(sp)
    800060aa:	6402                	ld	s0,0(sp)
    800060ac:	0141                	add	sp,sp,16
    800060ae:	8082                	ret

00000000800060b0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060b0:	1101                	add	sp,sp,-32
    800060b2:	ec06                	sd	ra,24(sp)
    800060b4:	e822                	sd	s0,16(sp)
    800060b6:	e426                	sd	s1,8(sp)
    800060b8:	1000                	add	s0,sp,32
    800060ba:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060bc:	ffffc097          	auipc	ra,0xffffc
    800060c0:	97a080e7          	jalr	-1670(ra) # 80001a36 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060c4:	00d5151b          	sllw	a0,a0,0xd
    800060c8:	0c2017b7          	lui	a5,0xc201
    800060cc:	97aa                	add	a5,a5,a0
    800060ce:	c3c4                	sw	s1,4(a5)
}
    800060d0:	60e2                	ld	ra,24(sp)
    800060d2:	6442                	ld	s0,16(sp)
    800060d4:	64a2                	ld	s1,8(sp)
    800060d6:	6105                	add	sp,sp,32
    800060d8:	8082                	ret

00000000800060da <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060da:	1141                	add	sp,sp,-16
    800060dc:	e406                	sd	ra,8(sp)
    800060de:	e022                	sd	s0,0(sp)
    800060e0:	0800                	add	s0,sp,16
  if(i >= NUM)
    800060e2:	479d                	li	a5,7
    800060e4:	04a7cc63          	blt	a5,a0,8000613c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800060e8:	0001c797          	auipc	a5,0x1c
    800060ec:	b4078793          	add	a5,a5,-1216 # 80021c28 <disk>
    800060f0:	97aa                	add	a5,a5,a0
    800060f2:	0187c783          	lbu	a5,24(a5)
    800060f6:	ebb9                	bnez	a5,8000614c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060f8:	00451693          	sll	a3,a0,0x4
    800060fc:	0001c797          	auipc	a5,0x1c
    80006100:	b2c78793          	add	a5,a5,-1236 # 80021c28 <disk>
    80006104:	6398                	ld	a4,0(a5)
    80006106:	9736                	add	a4,a4,a3
    80006108:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000610c:	6398                	ld	a4,0(a5)
    8000610e:	9736                	add	a4,a4,a3
    80006110:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006114:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006118:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000611c:	97aa                	add	a5,a5,a0
    8000611e:	4705                	li	a4,1
    80006120:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006124:	0001c517          	auipc	a0,0x1c
    80006128:	b1c50513          	add	a0,a0,-1252 # 80021c40 <disk+0x18>
    8000612c:	ffffc097          	auipc	ra,0xffffc
    80006130:	2c2080e7          	jalr	706(ra) # 800023ee <wakeup>
}
    80006134:	60a2                	ld	ra,8(sp)
    80006136:	6402                	ld	s0,0(sp)
    80006138:	0141                	add	sp,sp,16
    8000613a:	8082                	ret
    panic("free_desc 1");
    8000613c:	00002517          	auipc	a0,0x2
    80006140:	4fc50513          	add	a0,a0,1276 # 80008638 <etext+0x638>
    80006144:	ffffa097          	auipc	ra,0xffffa
    80006148:	41c080e7          	jalr	1052(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000614c:	00002517          	auipc	a0,0x2
    80006150:	4fc50513          	add	a0,a0,1276 # 80008648 <etext+0x648>
    80006154:	ffffa097          	auipc	ra,0xffffa
    80006158:	40c080e7          	jalr	1036(ra) # 80000560 <panic>

000000008000615c <virtio_disk_init>:
{
    8000615c:	1101                	add	sp,sp,-32
    8000615e:	ec06                	sd	ra,24(sp)
    80006160:	e822                	sd	s0,16(sp)
    80006162:	e426                	sd	s1,8(sp)
    80006164:	e04a                	sd	s2,0(sp)
    80006166:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006168:	00002597          	auipc	a1,0x2
    8000616c:	4f058593          	add	a1,a1,1264 # 80008658 <etext+0x658>
    80006170:	0001c517          	auipc	a0,0x1c
    80006174:	be050513          	add	a0,a0,-1056 # 80021d50 <disk+0x128>
    80006178:	ffffb097          	auipc	ra,0xffffb
    8000617c:	a30080e7          	jalr	-1488(ra) # 80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006180:	100017b7          	lui	a5,0x10001
    80006184:	4398                	lw	a4,0(a5)
    80006186:	2701                	sext.w	a4,a4
    80006188:	747277b7          	lui	a5,0x74727
    8000618c:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006190:	18f71c63          	bne	a4,a5,80006328 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006194:	100017b7          	lui	a5,0x10001
    80006198:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    8000619a:	439c                	lw	a5,0(a5)
    8000619c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000619e:	4709                	li	a4,2
    800061a0:	18e79463          	bne	a5,a4,80006328 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061a4:	100017b7          	lui	a5,0x10001
    800061a8:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800061aa:	439c                	lw	a5,0(a5)
    800061ac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061ae:	16e79d63          	bne	a5,a4,80006328 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061b2:	100017b7          	lui	a5,0x10001
    800061b6:	47d8                	lw	a4,12(a5)
    800061b8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061ba:	554d47b7          	lui	a5,0x554d4
    800061be:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061c2:	16f71363          	bne	a4,a5,80006328 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061c6:	100017b7          	lui	a5,0x10001
    800061ca:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061ce:	4705                	li	a4,1
    800061d0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d2:	470d                	li	a4,3
    800061d4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061d6:	10001737          	lui	a4,0x10001
    800061da:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061dc:	c7ffe737          	lui	a4,0xc7ffe
    800061e0:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9f7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061e4:	8ef9                	and	a3,a3,a4
    800061e6:	10001737          	lui	a4,0x10001
    800061ea:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061ec:	472d                	li	a4,11
    800061ee:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061f0:	07078793          	add	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800061f4:	439c                	lw	a5,0(a5)
    800061f6:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800061fa:	8ba1                	and	a5,a5,8
    800061fc:	12078e63          	beqz	a5,80006338 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006200:	100017b7          	lui	a5,0x10001
    80006204:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006208:	100017b7          	lui	a5,0x10001
    8000620c:	04478793          	add	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006210:	439c                	lw	a5,0(a5)
    80006212:	2781                	sext.w	a5,a5
    80006214:	12079a63          	bnez	a5,80006348 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006218:	100017b7          	lui	a5,0x10001
    8000621c:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006220:	439c                	lw	a5,0(a5)
    80006222:	2781                	sext.w	a5,a5
  if(max == 0)
    80006224:	12078a63          	beqz	a5,80006358 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006228:	471d                	li	a4,7
    8000622a:	12f77f63          	bgeu	a4,a5,80006368 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000622e:	ffffb097          	auipc	ra,0xffffb
    80006232:	91a080e7          	jalr	-1766(ra) # 80000b48 <kalloc>
    80006236:	0001c497          	auipc	s1,0x1c
    8000623a:	9f248493          	add	s1,s1,-1550 # 80021c28 <disk>
    8000623e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006240:	ffffb097          	auipc	ra,0xffffb
    80006244:	908080e7          	jalr	-1784(ra) # 80000b48 <kalloc>
    80006248:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000624a:	ffffb097          	auipc	ra,0xffffb
    8000624e:	8fe080e7          	jalr	-1794(ra) # 80000b48 <kalloc>
    80006252:	87aa                	mv	a5,a0
    80006254:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006256:	6088                	ld	a0,0(s1)
    80006258:	12050063          	beqz	a0,80006378 <virtio_disk_init+0x21c>
    8000625c:	0001c717          	auipc	a4,0x1c
    80006260:	9d473703          	ld	a4,-1580(a4) # 80021c30 <disk+0x8>
    80006264:	10070a63          	beqz	a4,80006378 <virtio_disk_init+0x21c>
    80006268:	10078863          	beqz	a5,80006378 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000626c:	6605                	lui	a2,0x1
    8000626e:	4581                	li	a1,0
    80006270:	ffffb097          	auipc	ra,0xffffb
    80006274:	ac4080e7          	jalr	-1340(ra) # 80000d34 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006278:	0001c497          	auipc	s1,0x1c
    8000627c:	9b048493          	add	s1,s1,-1616 # 80021c28 <disk>
    80006280:	6605                	lui	a2,0x1
    80006282:	4581                	li	a1,0
    80006284:	6488                	ld	a0,8(s1)
    80006286:	ffffb097          	auipc	ra,0xffffb
    8000628a:	aae080e7          	jalr	-1362(ra) # 80000d34 <memset>
  memset(disk.used, 0, PGSIZE);
    8000628e:	6605                	lui	a2,0x1
    80006290:	4581                	li	a1,0
    80006292:	6888                	ld	a0,16(s1)
    80006294:	ffffb097          	auipc	ra,0xffffb
    80006298:	aa0080e7          	jalr	-1376(ra) # 80000d34 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000629c:	100017b7          	lui	a5,0x10001
    800062a0:	4721                	li	a4,8
    800062a2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800062a4:	4098                	lw	a4,0(s1)
    800062a6:	100017b7          	lui	a5,0x10001
    800062aa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800062ae:	40d8                	lw	a4,4(s1)
    800062b0:	100017b7          	lui	a5,0x10001
    800062b4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800062b8:	649c                	ld	a5,8(s1)
    800062ba:	0007869b          	sext.w	a3,a5
    800062be:	10001737          	lui	a4,0x10001
    800062c2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800062c6:	9781                	sra	a5,a5,0x20
    800062c8:	10001737          	lui	a4,0x10001
    800062cc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800062d0:	689c                	ld	a5,16(s1)
    800062d2:	0007869b          	sext.w	a3,a5
    800062d6:	10001737          	lui	a4,0x10001
    800062da:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800062de:	9781                	sra	a5,a5,0x20
    800062e0:	10001737          	lui	a4,0x10001
    800062e4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800062e8:	10001737          	lui	a4,0x10001
    800062ec:	4785                	li	a5,1
    800062ee:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800062f0:	00f48c23          	sb	a5,24(s1)
    800062f4:	00f48ca3          	sb	a5,25(s1)
    800062f8:	00f48d23          	sb	a5,26(s1)
    800062fc:	00f48da3          	sb	a5,27(s1)
    80006300:	00f48e23          	sb	a5,28(s1)
    80006304:	00f48ea3          	sb	a5,29(s1)
    80006308:	00f48f23          	sb	a5,30(s1)
    8000630c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006310:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006314:	100017b7          	lui	a5,0x10001
    80006318:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000631c:	60e2                	ld	ra,24(sp)
    8000631e:	6442                	ld	s0,16(sp)
    80006320:	64a2                	ld	s1,8(sp)
    80006322:	6902                	ld	s2,0(sp)
    80006324:	6105                	add	sp,sp,32
    80006326:	8082                	ret
    panic("could not find virtio disk");
    80006328:	00002517          	auipc	a0,0x2
    8000632c:	34050513          	add	a0,a0,832 # 80008668 <etext+0x668>
    80006330:	ffffa097          	auipc	ra,0xffffa
    80006334:	230080e7          	jalr	560(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006338:	00002517          	auipc	a0,0x2
    8000633c:	35050513          	add	a0,a0,848 # 80008688 <etext+0x688>
    80006340:	ffffa097          	auipc	ra,0xffffa
    80006344:	220080e7          	jalr	544(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006348:	00002517          	auipc	a0,0x2
    8000634c:	36050513          	add	a0,a0,864 # 800086a8 <etext+0x6a8>
    80006350:	ffffa097          	auipc	ra,0xffffa
    80006354:	210080e7          	jalr	528(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006358:	00002517          	auipc	a0,0x2
    8000635c:	37050513          	add	a0,a0,880 # 800086c8 <etext+0x6c8>
    80006360:	ffffa097          	auipc	ra,0xffffa
    80006364:	200080e7          	jalr	512(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006368:	00002517          	auipc	a0,0x2
    8000636c:	38050513          	add	a0,a0,896 # 800086e8 <etext+0x6e8>
    80006370:	ffffa097          	auipc	ra,0xffffa
    80006374:	1f0080e7          	jalr	496(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006378:	00002517          	auipc	a0,0x2
    8000637c:	39050513          	add	a0,a0,912 # 80008708 <etext+0x708>
    80006380:	ffffa097          	auipc	ra,0xffffa
    80006384:	1e0080e7          	jalr	480(ra) # 80000560 <panic>

0000000080006388 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006388:	7159                	add	sp,sp,-112
    8000638a:	f486                	sd	ra,104(sp)
    8000638c:	f0a2                	sd	s0,96(sp)
    8000638e:	eca6                	sd	s1,88(sp)
    80006390:	e8ca                	sd	s2,80(sp)
    80006392:	e4ce                	sd	s3,72(sp)
    80006394:	e0d2                	sd	s4,64(sp)
    80006396:	fc56                	sd	s5,56(sp)
    80006398:	f85a                	sd	s6,48(sp)
    8000639a:	f45e                	sd	s7,40(sp)
    8000639c:	f062                	sd	s8,32(sp)
    8000639e:	ec66                	sd	s9,24(sp)
    800063a0:	1880                	add	s0,sp,112
    800063a2:	8a2a                	mv	s4,a0
    800063a4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800063a6:	00c52c83          	lw	s9,12(a0)
    800063aa:	001c9c9b          	sllw	s9,s9,0x1
    800063ae:	1c82                	sll	s9,s9,0x20
    800063b0:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800063b4:	0001c517          	auipc	a0,0x1c
    800063b8:	99c50513          	add	a0,a0,-1636 # 80021d50 <disk+0x128>
    800063bc:	ffffb097          	auipc	ra,0xffffb
    800063c0:	87c080e7          	jalr	-1924(ra) # 80000c38 <acquire>
  for(int i = 0; i < 3; i++){
    800063c4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800063c6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800063c8:	0001cb17          	auipc	s6,0x1c
    800063cc:	860b0b13          	add	s6,s6,-1952 # 80021c28 <disk>
  for(int i = 0; i < 3; i++){
    800063d0:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063d2:	0001cc17          	auipc	s8,0x1c
    800063d6:	97ec0c13          	add	s8,s8,-1666 # 80021d50 <disk+0x128>
    800063da:	a0ad                	j	80006444 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800063dc:	00fb0733          	add	a4,s6,a5
    800063e0:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800063e4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800063e6:	0207c563          	bltz	a5,80006410 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800063ea:	2905                	addw	s2,s2,1
    800063ec:	0611                	add	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800063ee:	05590f63          	beq	s2,s5,8000644c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    800063f2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800063f4:	0001c717          	auipc	a4,0x1c
    800063f8:	83470713          	add	a4,a4,-1996 # 80021c28 <disk>
    800063fc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800063fe:	01874683          	lbu	a3,24(a4)
    80006402:	fee9                	bnez	a3,800063dc <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006404:	2785                	addw	a5,a5,1
    80006406:	0705                	add	a4,a4,1
    80006408:	fe979be3          	bne	a5,s1,800063fe <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000640c:	57fd                	li	a5,-1
    8000640e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006410:	03205163          	blez	s2,80006432 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006414:	f9042503          	lw	a0,-112(s0)
    80006418:	00000097          	auipc	ra,0x0
    8000641c:	cc2080e7          	jalr	-830(ra) # 800060da <free_desc>
      for(int j = 0; j < i; j++)
    80006420:	4785                	li	a5,1
    80006422:	0127d863          	bge	a5,s2,80006432 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006426:	f9442503          	lw	a0,-108(s0)
    8000642a:	00000097          	auipc	ra,0x0
    8000642e:	cb0080e7          	jalr	-848(ra) # 800060da <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006432:	85e2                	mv	a1,s8
    80006434:	0001c517          	auipc	a0,0x1c
    80006438:	80c50513          	add	a0,a0,-2036 # 80021c40 <disk+0x18>
    8000643c:	ffffc097          	auipc	ra,0xffffc
    80006440:	f4e080e7          	jalr	-178(ra) # 8000238a <sleep>
  for(int i = 0; i < 3; i++){
    80006444:	f9040613          	add	a2,s0,-112
    80006448:	894e                	mv	s2,s3
    8000644a:	b765                	j	800063f2 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000644c:	f9042503          	lw	a0,-112(s0)
    80006450:	00451693          	sll	a3,a0,0x4

  if(write)
    80006454:	0001b797          	auipc	a5,0x1b
    80006458:	7d478793          	add	a5,a5,2004 # 80021c28 <disk>
    8000645c:	00a50713          	add	a4,a0,10
    80006460:	0712                	sll	a4,a4,0x4
    80006462:	973e                	add	a4,a4,a5
    80006464:	01703633          	snez	a2,s7
    80006468:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000646a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000646e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006472:	6398                	ld	a4,0(a5)
    80006474:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006476:	0a868613          	add	a2,a3,168
    8000647a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000647c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000647e:	6390                	ld	a2,0(a5)
    80006480:	00d605b3          	add	a1,a2,a3
    80006484:	4741                	li	a4,16
    80006486:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006488:	4805                	li	a6,1
    8000648a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000648e:	f9442703          	lw	a4,-108(s0)
    80006492:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006496:	0712                	sll	a4,a4,0x4
    80006498:	963a                	add	a2,a2,a4
    8000649a:	058a0593          	add	a1,s4,88
    8000649e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800064a0:	0007b883          	ld	a7,0(a5)
    800064a4:	9746                	add	a4,a4,a7
    800064a6:	40000613          	li	a2,1024
    800064aa:	c710                	sw	a2,8(a4)
  if(write)
    800064ac:	001bb613          	seqz	a2,s7
    800064b0:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800064b4:	00166613          	or	a2,a2,1
    800064b8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800064bc:	f9842583          	lw	a1,-104(s0)
    800064c0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800064c4:	00250613          	add	a2,a0,2
    800064c8:	0612                	sll	a2,a2,0x4
    800064ca:	963e                	add	a2,a2,a5
    800064cc:	577d                	li	a4,-1
    800064ce:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800064d2:	0592                	sll	a1,a1,0x4
    800064d4:	98ae                	add	a7,a7,a1
    800064d6:	03068713          	add	a4,a3,48
    800064da:	973e                	add	a4,a4,a5
    800064dc:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800064e0:	6398                	ld	a4,0(a5)
    800064e2:	972e                	add	a4,a4,a1
    800064e4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800064e8:	4689                	li	a3,2
    800064ea:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800064ee:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800064f2:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800064f6:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800064fa:	6794                	ld	a3,8(a5)
    800064fc:	0026d703          	lhu	a4,2(a3)
    80006500:	8b1d                	and	a4,a4,7
    80006502:	0706                	sll	a4,a4,0x1
    80006504:	96ba                	add	a3,a3,a4
    80006506:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000650a:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000650e:	6798                	ld	a4,8(a5)
    80006510:	00275783          	lhu	a5,2(a4)
    80006514:	2785                	addw	a5,a5,1
    80006516:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000651a:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000651e:	100017b7          	lui	a5,0x10001
    80006522:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006526:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000652a:	0001c917          	auipc	s2,0x1c
    8000652e:	82690913          	add	s2,s2,-2010 # 80021d50 <disk+0x128>
  while(b->disk == 1) {
    80006532:	4485                	li	s1,1
    80006534:	01079c63          	bne	a5,a6,8000654c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006538:	85ca                	mv	a1,s2
    8000653a:	8552                	mv	a0,s4
    8000653c:	ffffc097          	auipc	ra,0xffffc
    80006540:	e4e080e7          	jalr	-434(ra) # 8000238a <sleep>
  while(b->disk == 1) {
    80006544:	004a2783          	lw	a5,4(s4)
    80006548:	fe9788e3          	beq	a5,s1,80006538 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000654c:	f9042903          	lw	s2,-112(s0)
    80006550:	00290713          	add	a4,s2,2
    80006554:	0712                	sll	a4,a4,0x4
    80006556:	0001b797          	auipc	a5,0x1b
    8000655a:	6d278793          	add	a5,a5,1746 # 80021c28 <disk>
    8000655e:	97ba                	add	a5,a5,a4
    80006560:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006564:	0001b997          	auipc	s3,0x1b
    80006568:	6c498993          	add	s3,s3,1732 # 80021c28 <disk>
    8000656c:	00491713          	sll	a4,s2,0x4
    80006570:	0009b783          	ld	a5,0(s3)
    80006574:	97ba                	add	a5,a5,a4
    80006576:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000657a:	854a                	mv	a0,s2
    8000657c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006580:	00000097          	auipc	ra,0x0
    80006584:	b5a080e7          	jalr	-1190(ra) # 800060da <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006588:	8885                	and	s1,s1,1
    8000658a:	f0ed                	bnez	s1,8000656c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000658c:	0001b517          	auipc	a0,0x1b
    80006590:	7c450513          	add	a0,a0,1988 # 80021d50 <disk+0x128>
    80006594:	ffffa097          	auipc	ra,0xffffa
    80006598:	758080e7          	jalr	1880(ra) # 80000cec <release>
}
    8000659c:	70a6                	ld	ra,104(sp)
    8000659e:	7406                	ld	s0,96(sp)
    800065a0:	64e6                	ld	s1,88(sp)
    800065a2:	6946                	ld	s2,80(sp)
    800065a4:	69a6                	ld	s3,72(sp)
    800065a6:	6a06                	ld	s4,64(sp)
    800065a8:	7ae2                	ld	s5,56(sp)
    800065aa:	7b42                	ld	s6,48(sp)
    800065ac:	7ba2                	ld	s7,40(sp)
    800065ae:	7c02                	ld	s8,32(sp)
    800065b0:	6ce2                	ld	s9,24(sp)
    800065b2:	6165                	add	sp,sp,112
    800065b4:	8082                	ret

00000000800065b6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800065b6:	1101                	add	sp,sp,-32
    800065b8:	ec06                	sd	ra,24(sp)
    800065ba:	e822                	sd	s0,16(sp)
    800065bc:	e426                	sd	s1,8(sp)
    800065be:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800065c0:	0001b497          	auipc	s1,0x1b
    800065c4:	66848493          	add	s1,s1,1640 # 80021c28 <disk>
    800065c8:	0001b517          	auipc	a0,0x1b
    800065cc:	78850513          	add	a0,a0,1928 # 80021d50 <disk+0x128>
    800065d0:	ffffa097          	auipc	ra,0xffffa
    800065d4:	668080e7          	jalr	1640(ra) # 80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800065d8:	100017b7          	lui	a5,0x10001
    800065dc:	53b8                	lw	a4,96(a5)
    800065de:	8b0d                	and	a4,a4,3
    800065e0:	100017b7          	lui	a5,0x10001
    800065e4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800065e6:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800065ea:	689c                	ld	a5,16(s1)
    800065ec:	0204d703          	lhu	a4,32(s1)
    800065f0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800065f4:	04f70863          	beq	a4,a5,80006644 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    800065f8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065fc:	6898                	ld	a4,16(s1)
    800065fe:	0204d783          	lhu	a5,32(s1)
    80006602:	8b9d                	and	a5,a5,7
    80006604:	078e                	sll	a5,a5,0x3
    80006606:	97ba                	add	a5,a5,a4
    80006608:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000660a:	00278713          	add	a4,a5,2
    8000660e:	0712                	sll	a4,a4,0x4
    80006610:	9726                	add	a4,a4,s1
    80006612:	01074703          	lbu	a4,16(a4)
    80006616:	e721                	bnez	a4,8000665e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006618:	0789                	add	a5,a5,2
    8000661a:	0792                	sll	a5,a5,0x4
    8000661c:	97a6                	add	a5,a5,s1
    8000661e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006620:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006624:	ffffc097          	auipc	ra,0xffffc
    80006628:	dca080e7          	jalr	-566(ra) # 800023ee <wakeup>

    disk.used_idx += 1;
    8000662c:	0204d783          	lhu	a5,32(s1)
    80006630:	2785                	addw	a5,a5,1
    80006632:	17c2                	sll	a5,a5,0x30
    80006634:	93c1                	srl	a5,a5,0x30
    80006636:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000663a:	6898                	ld	a4,16(s1)
    8000663c:	00275703          	lhu	a4,2(a4)
    80006640:	faf71ce3          	bne	a4,a5,800065f8 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006644:	0001b517          	auipc	a0,0x1b
    80006648:	70c50513          	add	a0,a0,1804 # 80021d50 <disk+0x128>
    8000664c:	ffffa097          	auipc	ra,0xffffa
    80006650:	6a0080e7          	jalr	1696(ra) # 80000cec <release>
}
    80006654:	60e2                	ld	ra,24(sp)
    80006656:	6442                	ld	s0,16(sp)
    80006658:	64a2                	ld	s1,8(sp)
    8000665a:	6105                	add	sp,sp,32
    8000665c:	8082                	ret
      panic("virtio_disk_intr status");
    8000665e:	00002517          	auipc	a0,0x2
    80006662:	0c250513          	add	a0,a0,194 # 80008720 <etext+0x720>
    80006666:	ffffa097          	auipc	ra,0xffffa
    8000666a:	efa080e7          	jalr	-262(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
