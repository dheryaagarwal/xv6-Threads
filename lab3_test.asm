
user/_lab3_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_fn>:
#include "user/thread.h"

struct lock_t lock;
int n_threads, n_passes, cur_turn, cur_pass;

void* thread_fn(void *arg) {
   0:	7139                	add	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	add	s0,sp,64
  int thread_id = (uint64)arg;
  12:	00050a1b          	sext.w	s4,a0
  int done = 0;
  while (!done) {
    lock_acquire(&lock);
  16:	00001497          	auipc	s1,0x1
  1a:	ffa48493          	add	s1,s1,-6 # 1010 <lock>
    if (cur_pass >= n_passes) done = 1;
  1e:	00001997          	auipc	s3,0x1
  22:	fe298993          	add	s3,s3,-30 # 1000 <cur_pass>
  26:	00001917          	auipc	s2,0x1
  2a:	fe290913          	add	s2,s2,-30 # 1008 <n_passes>
    else if (cur_turn == thread_id) {
  2e:	00001a97          	auipc	s5,0x1
  32:	fd6a8a93          	add	s5,s5,-42 # 1004 <cur_turn>
  36:	a819                	j	4c <thread_fn+0x4c>
      cur_turn = (cur_turn + 1) % n_threads;
      printf("Round %d: thread %d is passing the token to thread %d\n", ++cur_pass, thread_id, cur_turn);
    }
    lock_release(&lock);
  38:	8526                	mv	a0,s1
  3a:	00001097          	auipc	ra,0x1
  3e:	9a4080e7          	jalr	-1628(ra) # 9de <lock_release>
    sleep(0);
  42:	4501                	li	a0,0
  44:	00000097          	auipc	ra,0x0
  48:	496080e7          	jalr	1174(ra) # 4da <sleep>
    lock_acquire(&lock);
  4c:	8526                	mv	a0,s1
  4e:	00001097          	auipc	ra,0x1
  52:	974080e7          	jalr	-1676(ra) # 9c2 <lock_acquire>
    if (cur_pass >= n_passes) done = 1;
  56:	0009a583          	lw	a1,0(s3)
  5a:	00092783          	lw	a5,0(s2)
  5e:	04f5d363          	bge	a1,a5,a4 <thread_fn+0xa4>
    else if (cur_turn == thread_id) {
  62:	000aa783          	lw	a5,0(s5)
  66:	fd4799e3          	bne	a5,s4,38 <thread_fn+0x38>
      cur_turn = (cur_turn + 1) % n_threads;
  6a:	001a069b          	addw	a3,s4,1
  6e:	00001797          	auipc	a5,0x1
  72:	f9e7a783          	lw	a5,-98(a5) # 100c <n_threads>
  76:	02f6e6bb          	remw	a3,a3,a5
  7a:	00001797          	auipc	a5,0x1
  7e:	f8d7a523          	sw	a3,-118(a5) # 1004 <cur_turn>
      printf("Round %d: thread %d is passing the token to thread %d\n", ++cur_pass, thread_id, cur_turn);
  82:	2585                	addw	a1,a1,1
  84:	00001797          	auipc	a5,0x1
  88:	f6b7ae23          	sw	a1,-132(a5) # 1000 <cur_pass>
  8c:	2681                	sext.w	a3,a3
  8e:	8652                	mv	a2,s4
  90:	2581                	sext.w	a1,a1
  92:	00001517          	auipc	a0,0x1
  96:	96e50513          	add	a0,a0,-1682 # a00 <lock_release+0x22>
  9a:	00000097          	auipc	ra,0x0
  9e:	720080e7          	jalr	1824(ra) # 7ba <printf>
  a2:	bf59                	j	38 <thread_fn+0x38>
    lock_release(&lock);
  a4:	00001517          	auipc	a0,0x1
  a8:	f6c50513          	add	a0,a0,-148 # 1010 <lock>
  ac:	00001097          	auipc	ra,0x1
  b0:	932080e7          	jalr	-1742(ra) # 9de <lock_release>
    sleep(0);
  b4:	4501                	li	a0,0
  b6:	00000097          	auipc	ra,0x0
  ba:	424080e7          	jalr	1060(ra) # 4da <sleep>
  }
  return 0;
}
  be:	4501                	li	a0,0
  c0:	70e2                	ld	ra,56(sp)
  c2:	7442                	ld	s0,48(sp)
  c4:	74a2                	ld	s1,40(sp)
  c6:	7902                	ld	s2,32(sp)
  c8:	69e2                	ld	s3,24(sp)
  ca:	6a42                	ld	s4,16(sp)
  cc:	6aa2                	ld	s5,8(sp)
  ce:	6121                	add	sp,sp,64
  d0:	8082                	ret

00000000000000d2 <main>:

int main(int argc, char *argv[]) {
  d2:	7179                	add	sp,sp,-48
  d4:	f406                	sd	ra,40(sp)
  d6:	f022                	sd	s0,32(sp)
  d8:	ec26                	sd	s1,24(sp)
  da:	1800                	add	s0,sp,48
  dc:	84ae                	mv	s1,a1
  if (argc < 3) {
  de:	4789                	li	a5,2
  e0:	02a7c263          	blt	a5,a0,104 <main+0x32>
  e4:	e84a                	sd	s2,16(sp)
  e6:	e44e                	sd	s3,8(sp)
    printf("Usage: %s [N_PASSES] [N_THREADS]\n", argv[0]);
  e8:	618c                	ld	a1,0(a1)
  ea:	00001517          	auipc	a0,0x1
  ee:	95650513          	add	a0,a0,-1706 # a40 <lock_release+0x62>
  f2:	00000097          	auipc	ra,0x0
  f6:	6c8080e7          	jalr	1736(ra) # 7ba <printf>
    exit(-1);
  fa:	557d                	li	a0,-1
  fc:	00000097          	auipc	ra,0x0
 100:	34e080e7          	jalr	846(ra) # 44a <exit>
 104:	e84a                	sd	s2,16(sp)
 106:	e44e                	sd	s3,8(sp)
  }
  n_passes = atoi(argv[1]);
 108:	6588                	ld	a0,8(a1)
 10a:	00000097          	auipc	ra,0x0
 10e:	246080e7          	jalr	582(ra) # 350 <atoi>
 112:	00001797          	auipc	a5,0x1
 116:	eea7ab23          	sw	a0,-266(a5) # 1008 <n_passes>
  n_threads = atoi(argv[2]);
 11a:	6888                	ld	a0,16(s1)
 11c:	00000097          	auipc	ra,0x0
 120:	234080e7          	jalr	564(ra) # 350 <atoi>
 124:	00001497          	auipc	s1,0x1
 128:	ee848493          	add	s1,s1,-280 # 100c <n_threads>
 12c:	c088                	sw	a0,0(s1)
  cur_turn = 0;
 12e:	00001797          	auipc	a5,0x1
 132:	ec07ab23          	sw	zero,-298(a5) # 1004 <cur_turn>
  cur_pass = 0;
 136:	00001797          	auipc	a5,0x1
 13a:	ec07a523          	sw	zero,-310(a5) # 1000 <cur_pass>
  lock_init(&lock);
 13e:	00001517          	auipc	a0,0x1
 142:	ed250513          	add	a0,a0,-302 # 1010 <lock>
 146:	00001097          	auipc	ra,0x1
 14a:	86c080e7          	jalr	-1940(ra) # 9b2 <lock_init>

  for (int i = 0; i < n_threads; i++) {
 14e:	409c                	lw	a5,0(s1)
 150:	04f05963          	blez	a5,1a2 <main+0xd0>
 154:	4481                	li	s1,0
    thread_create(thread_fn, (void*)(uint64)i);
 156:	00000997          	auipc	s3,0x0
 15a:	eaa98993          	add	s3,s3,-342 # 0 <thread_fn>
  for (int i = 0; i < n_threads; i++) {
 15e:	00001917          	auipc	s2,0x1
 162:	eae90913          	add	s2,s2,-338 # 100c <n_threads>
    thread_create(thread_fn, (void*)(uint64)i);
 166:	85a6                	mv	a1,s1
 168:	854e                	mv	a0,s3
 16a:	00001097          	auipc	ra,0x1
 16e:	808080e7          	jalr	-2040(ra) # 972 <thread_create>
  for (int i = 0; i < n_threads; i++) {
 172:	00092783          	lw	a5,0(s2)
 176:	0485                	add	s1,s1,1
 178:	0004871b          	sext.w	a4,s1
 17c:	fef745e3          	blt	a4,a5,166 <main+0x94>
  }
  for (int i = 0; i < n_threads; i++) {
 180:	02f05163          	blez	a5,1a2 <main+0xd0>
 184:	4481                	li	s1,0
 186:	00001917          	auipc	s2,0x1
 18a:	e8690913          	add	s2,s2,-378 # 100c <n_threads>
    wait(0);
 18e:	4501                	li	a0,0
 190:	00000097          	auipc	ra,0x0
 194:	2c2080e7          	jalr	706(ra) # 452 <wait>
  for (int i = 0; i < n_threads; i++) {
 198:	2485                	addw	s1,s1,1
 19a:	00092783          	lw	a5,0(s2)
 19e:	fef4c8e3          	blt	s1,a5,18e <main+0xbc>
  }
  printf("Frisbee simulation has finished, %d rounds played in total\n", n_passes);
 1a2:	00001597          	auipc	a1,0x1
 1a6:	e665a583          	lw	a1,-410(a1) # 1008 <n_passes>
 1aa:	00001517          	auipc	a0,0x1
 1ae:	8be50513          	add	a0,a0,-1858 # a68 <lock_release+0x8a>
 1b2:	00000097          	auipc	ra,0x0
 1b6:	608080e7          	jalr	1544(ra) # 7ba <printf>

  exit(0);
 1ba:	4501                	li	a0,0
 1bc:	00000097          	auipc	ra,0x0
 1c0:	28e080e7          	jalr	654(ra) # 44a <exit>

00000000000001c4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1c4:	1141                	add	sp,sp,-16
 1c6:	e406                	sd	ra,8(sp)
 1c8:	e022                	sd	s0,0(sp)
 1ca:	0800                	add	s0,sp,16
  extern int main();
  main();
 1cc:	00000097          	auipc	ra,0x0
 1d0:	f06080e7          	jalr	-250(ra) # d2 <main>
  exit(0);
 1d4:	4501                	li	a0,0
 1d6:	00000097          	auipc	ra,0x0
 1da:	274080e7          	jalr	628(ra) # 44a <exit>

00000000000001de <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1de:	1141                	add	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1e4:	87aa                	mv	a5,a0
 1e6:	0585                	add	a1,a1,1
 1e8:	0785                	add	a5,a5,1
 1ea:	fff5c703          	lbu	a4,-1(a1)
 1ee:	fee78fa3          	sb	a4,-1(a5)
 1f2:	fb75                	bnez	a4,1e6 <strcpy+0x8>
    ;
  return os;
}
 1f4:	6422                	ld	s0,8(sp)
 1f6:	0141                	add	sp,sp,16
 1f8:	8082                	ret

00000000000001fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1fa:	1141                	add	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 200:	00054783          	lbu	a5,0(a0)
 204:	cb91                	beqz	a5,218 <strcmp+0x1e>
 206:	0005c703          	lbu	a4,0(a1)
 20a:	00f71763          	bne	a4,a5,218 <strcmp+0x1e>
    p++, q++;
 20e:	0505                	add	a0,a0,1
 210:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 212:	00054783          	lbu	a5,0(a0)
 216:	fbe5                	bnez	a5,206 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 218:	0005c503          	lbu	a0,0(a1)
}
 21c:	40a7853b          	subw	a0,a5,a0
 220:	6422                	ld	s0,8(sp)
 222:	0141                	add	sp,sp,16
 224:	8082                	ret

0000000000000226 <strlen>:

uint
strlen(const char *s)
{
 226:	1141                	add	sp,sp,-16
 228:	e422                	sd	s0,8(sp)
 22a:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 22c:	00054783          	lbu	a5,0(a0)
 230:	cf91                	beqz	a5,24c <strlen+0x26>
 232:	0505                	add	a0,a0,1
 234:	87aa                	mv	a5,a0
 236:	86be                	mv	a3,a5
 238:	0785                	add	a5,a5,1
 23a:	fff7c703          	lbu	a4,-1(a5)
 23e:	ff65                	bnez	a4,236 <strlen+0x10>
 240:	40a6853b          	subw	a0,a3,a0
 244:	2505                	addw	a0,a0,1
    ;
  return n;
}
 246:	6422                	ld	s0,8(sp)
 248:	0141                	add	sp,sp,16
 24a:	8082                	ret
  for(n = 0; s[n]; n++)
 24c:	4501                	li	a0,0
 24e:	bfe5                	j	246 <strlen+0x20>

0000000000000250 <memset>:

void*
memset(void *dst, int c, uint n)
{
 250:	1141                	add	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 256:	ca19                	beqz	a2,26c <memset+0x1c>
 258:	87aa                	mv	a5,a0
 25a:	1602                	sll	a2,a2,0x20
 25c:	9201                	srl	a2,a2,0x20
 25e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 262:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 266:	0785                	add	a5,a5,1
 268:	fee79de3          	bne	a5,a4,262 <memset+0x12>
  }
  return dst;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	add	sp,sp,16
 270:	8082                	ret

0000000000000272 <strchr>:

char*
strchr(const char *s, char c)
{
 272:	1141                	add	sp,sp,-16
 274:	e422                	sd	s0,8(sp)
 276:	0800                	add	s0,sp,16
  for(; *s; s++)
 278:	00054783          	lbu	a5,0(a0)
 27c:	cb99                	beqz	a5,292 <strchr+0x20>
    if(*s == c)
 27e:	00f58763          	beq	a1,a5,28c <strchr+0x1a>
  for(; *s; s++)
 282:	0505                	add	a0,a0,1
 284:	00054783          	lbu	a5,0(a0)
 288:	fbfd                	bnez	a5,27e <strchr+0xc>
      return (char*)s;
  return 0;
 28a:	4501                	li	a0,0
}
 28c:	6422                	ld	s0,8(sp)
 28e:	0141                	add	sp,sp,16
 290:	8082                	ret
  return 0;
 292:	4501                	li	a0,0
 294:	bfe5                	j	28c <strchr+0x1a>

0000000000000296 <gets>:

char*
gets(char *buf, int max)
{
 296:	711d                	add	sp,sp,-96
 298:	ec86                	sd	ra,88(sp)
 29a:	e8a2                	sd	s0,80(sp)
 29c:	e4a6                	sd	s1,72(sp)
 29e:	e0ca                	sd	s2,64(sp)
 2a0:	fc4e                	sd	s3,56(sp)
 2a2:	f852                	sd	s4,48(sp)
 2a4:	f456                	sd	s5,40(sp)
 2a6:	f05a                	sd	s6,32(sp)
 2a8:	ec5e                	sd	s7,24(sp)
 2aa:	1080                	add	s0,sp,96
 2ac:	8baa                	mv	s7,a0
 2ae:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b0:	892a                	mv	s2,a0
 2b2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2b4:	4aa9                	li	s5,10
 2b6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2b8:	89a6                	mv	s3,s1
 2ba:	2485                	addw	s1,s1,1
 2bc:	0344d863          	bge	s1,s4,2ec <gets+0x56>
    cc = read(0, &c, 1);
 2c0:	4605                	li	a2,1
 2c2:	faf40593          	add	a1,s0,-81
 2c6:	4501                	li	a0,0
 2c8:	00000097          	auipc	ra,0x0
 2cc:	19a080e7          	jalr	410(ra) # 462 <read>
    if(cc < 1)
 2d0:	00a05e63          	blez	a0,2ec <gets+0x56>
    buf[i++] = c;
 2d4:	faf44783          	lbu	a5,-81(s0)
 2d8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2dc:	01578763          	beq	a5,s5,2ea <gets+0x54>
 2e0:	0905                	add	s2,s2,1
 2e2:	fd679be3          	bne	a5,s6,2b8 <gets+0x22>
    buf[i++] = c;
 2e6:	89a6                	mv	s3,s1
 2e8:	a011                	j	2ec <gets+0x56>
 2ea:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2ec:	99de                	add	s3,s3,s7
 2ee:	00098023          	sb	zero,0(s3)
  return buf;
}
 2f2:	855e                	mv	a0,s7
 2f4:	60e6                	ld	ra,88(sp)
 2f6:	6446                	ld	s0,80(sp)
 2f8:	64a6                	ld	s1,72(sp)
 2fa:	6906                	ld	s2,64(sp)
 2fc:	79e2                	ld	s3,56(sp)
 2fe:	7a42                	ld	s4,48(sp)
 300:	7aa2                	ld	s5,40(sp)
 302:	7b02                	ld	s6,32(sp)
 304:	6be2                	ld	s7,24(sp)
 306:	6125                	add	sp,sp,96
 308:	8082                	ret

000000000000030a <stat>:

int
stat(const char *n, struct stat *st)
{
 30a:	1101                	add	sp,sp,-32
 30c:	ec06                	sd	ra,24(sp)
 30e:	e822                	sd	s0,16(sp)
 310:	e04a                	sd	s2,0(sp)
 312:	1000                	add	s0,sp,32
 314:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 316:	4581                	li	a1,0
 318:	00000097          	auipc	ra,0x0
 31c:	172080e7          	jalr	370(ra) # 48a <open>
  if(fd < 0)
 320:	02054663          	bltz	a0,34c <stat+0x42>
 324:	e426                	sd	s1,8(sp)
 326:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 328:	85ca                	mv	a1,s2
 32a:	00000097          	auipc	ra,0x0
 32e:	178080e7          	jalr	376(ra) # 4a2 <fstat>
 332:	892a                	mv	s2,a0
  close(fd);
 334:	8526                	mv	a0,s1
 336:	00000097          	auipc	ra,0x0
 33a:	13c080e7          	jalr	316(ra) # 472 <close>
  return r;
 33e:	64a2                	ld	s1,8(sp)
}
 340:	854a                	mv	a0,s2
 342:	60e2                	ld	ra,24(sp)
 344:	6442                	ld	s0,16(sp)
 346:	6902                	ld	s2,0(sp)
 348:	6105                	add	sp,sp,32
 34a:	8082                	ret
    return -1;
 34c:	597d                	li	s2,-1
 34e:	bfcd                	j	340 <stat+0x36>

0000000000000350 <atoi>:

int
atoi(const char *s)
{
 350:	1141                	add	sp,sp,-16
 352:	e422                	sd	s0,8(sp)
 354:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 356:	00054683          	lbu	a3,0(a0)
 35a:	fd06879b          	addw	a5,a3,-48
 35e:	0ff7f793          	zext.b	a5,a5
 362:	4625                	li	a2,9
 364:	02f66863          	bltu	a2,a5,394 <atoi+0x44>
 368:	872a                	mv	a4,a0
  n = 0;
 36a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 36c:	0705                	add	a4,a4,1
 36e:	0025179b          	sllw	a5,a0,0x2
 372:	9fa9                	addw	a5,a5,a0
 374:	0017979b          	sllw	a5,a5,0x1
 378:	9fb5                	addw	a5,a5,a3
 37a:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 37e:	00074683          	lbu	a3,0(a4)
 382:	fd06879b          	addw	a5,a3,-48
 386:	0ff7f793          	zext.b	a5,a5
 38a:	fef671e3          	bgeu	a2,a5,36c <atoi+0x1c>
  return n;
}
 38e:	6422                	ld	s0,8(sp)
 390:	0141                	add	sp,sp,16
 392:	8082                	ret
  n = 0;
 394:	4501                	li	a0,0
 396:	bfe5                	j	38e <atoi+0x3e>

0000000000000398 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 398:	1141                	add	sp,sp,-16
 39a:	e422                	sd	s0,8(sp)
 39c:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 39e:	02b57463          	bgeu	a0,a1,3c6 <memmove+0x2e>
    while(n-- > 0)
 3a2:	00c05f63          	blez	a2,3c0 <memmove+0x28>
 3a6:	1602                	sll	a2,a2,0x20
 3a8:	9201                	srl	a2,a2,0x20
 3aa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ae:	872a                	mv	a4,a0
      *dst++ = *src++;
 3b0:	0585                	add	a1,a1,1
 3b2:	0705                	add	a4,a4,1
 3b4:	fff5c683          	lbu	a3,-1(a1)
 3b8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3bc:	fef71ae3          	bne	a4,a5,3b0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3c0:	6422                	ld	s0,8(sp)
 3c2:	0141                	add	sp,sp,16
 3c4:	8082                	ret
    dst += n;
 3c6:	00c50733          	add	a4,a0,a2
    src += n;
 3ca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3cc:	fec05ae3          	blez	a2,3c0 <memmove+0x28>
 3d0:	fff6079b          	addw	a5,a2,-1
 3d4:	1782                	sll	a5,a5,0x20
 3d6:	9381                	srl	a5,a5,0x20
 3d8:	fff7c793          	not	a5,a5
 3dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3de:	15fd                	add	a1,a1,-1
 3e0:	177d                	add	a4,a4,-1
 3e2:	0005c683          	lbu	a3,0(a1)
 3e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ea:	fee79ae3          	bne	a5,a4,3de <memmove+0x46>
 3ee:	bfc9                	j	3c0 <memmove+0x28>

00000000000003f0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3f0:	1141                	add	sp,sp,-16
 3f2:	e422                	sd	s0,8(sp)
 3f4:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f6:	ca05                	beqz	a2,426 <memcmp+0x36>
 3f8:	fff6069b          	addw	a3,a2,-1
 3fc:	1682                	sll	a3,a3,0x20
 3fe:	9281                	srl	a3,a3,0x20
 400:	0685                	add	a3,a3,1
 402:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 404:	00054783          	lbu	a5,0(a0)
 408:	0005c703          	lbu	a4,0(a1)
 40c:	00e79863          	bne	a5,a4,41c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 410:	0505                	add	a0,a0,1
    p2++;
 412:	0585                	add	a1,a1,1
  while (n-- > 0) {
 414:	fed518e3          	bne	a0,a3,404 <memcmp+0x14>
  }
  return 0;
 418:	4501                	li	a0,0
 41a:	a019                	j	420 <memcmp+0x30>
      return *p1 - *p2;
 41c:	40e7853b          	subw	a0,a5,a4
}
 420:	6422                	ld	s0,8(sp)
 422:	0141                	add	sp,sp,16
 424:	8082                	ret
  return 0;
 426:	4501                	li	a0,0
 428:	bfe5                	j	420 <memcmp+0x30>

000000000000042a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 42a:	1141                	add	sp,sp,-16
 42c:	e406                	sd	ra,8(sp)
 42e:	e022                	sd	s0,0(sp)
 430:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 432:	00000097          	auipc	ra,0x0
 436:	f66080e7          	jalr	-154(ra) # 398 <memmove>
}
 43a:	60a2                	ld	ra,8(sp)
 43c:	6402                	ld	s0,0(sp)
 43e:	0141                	add	sp,sp,16
 440:	8082                	ret

0000000000000442 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 442:	4885                	li	a7,1
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <exit>:
.global exit
exit:
 li a7, SYS_exit
 44a:	4889                	li	a7,2
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <wait>:
.global wait
wait:
 li a7, SYS_wait
 452:	488d                	li	a7,3
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 45a:	4891                	li	a7,4
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <read>:
.global read
read:
 li a7, SYS_read
 462:	4895                	li	a7,5
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <write>:
.global write
write:
 li a7, SYS_write
 46a:	48c1                	li	a7,16
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <close>:
.global close
close:
 li a7, SYS_close
 472:	48d5                	li	a7,21
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <kill>:
.global kill
kill:
 li a7, SYS_kill
 47a:	4899                	li	a7,6
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <exec>:
.global exec
exec:
 li a7, SYS_exec
 482:	489d                	li	a7,7
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <open>:
.global open
open:
 li a7, SYS_open
 48a:	48bd                	li	a7,15
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 492:	48c5                	li	a7,17
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 49a:	48c9                	li	a7,18
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4a2:	48a1                	li	a7,8
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <link>:
.global link
link:
 li a7, SYS_link
 4aa:	48cd                	li	a7,19
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b2:	48d1                	li	a7,20
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ba:	48a5                	li	a7,9
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c2:	48a9                	li	a7,10
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ca:	48ad                	li	a7,11
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4d2:	48b1                	li	a7,12
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4da:	48b5                	li	a7,13
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e2:	48b9                	li	a7,14
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <clone>:
.global clone
clone:
 li a7, SYS_clone
 4ea:	48d9                	li	a7,22
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4f2:	1101                	add	sp,sp,-32
 4f4:	ec06                	sd	ra,24(sp)
 4f6:	e822                	sd	s0,16(sp)
 4f8:	1000                	add	s0,sp,32
 4fa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4fe:	4605                	li	a2,1
 500:	fef40593          	add	a1,s0,-17
 504:	00000097          	auipc	ra,0x0
 508:	f66080e7          	jalr	-154(ra) # 46a <write>
}
 50c:	60e2                	ld	ra,24(sp)
 50e:	6442                	ld	s0,16(sp)
 510:	6105                	add	sp,sp,32
 512:	8082                	ret

0000000000000514 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 514:	7139                	add	sp,sp,-64
 516:	fc06                	sd	ra,56(sp)
 518:	f822                	sd	s0,48(sp)
 51a:	f426                	sd	s1,40(sp)
 51c:	0080                	add	s0,sp,64
 51e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 520:	c299                	beqz	a3,526 <printint+0x12>
 522:	0805cb63          	bltz	a1,5b8 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 526:	2581                	sext.w	a1,a1
  neg = 0;
 528:	4881                	li	a7,0
 52a:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 52e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 530:	2601                	sext.w	a2,a2
 532:	00000517          	auipc	a0,0x0
 536:	5d650513          	add	a0,a0,1494 # b08 <digits>
 53a:	883a                	mv	a6,a4
 53c:	2705                	addw	a4,a4,1
 53e:	02c5f7bb          	remuw	a5,a1,a2
 542:	1782                	sll	a5,a5,0x20
 544:	9381                	srl	a5,a5,0x20
 546:	97aa                	add	a5,a5,a0
 548:	0007c783          	lbu	a5,0(a5)
 54c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 550:	0005879b          	sext.w	a5,a1
 554:	02c5d5bb          	divuw	a1,a1,a2
 558:	0685                	add	a3,a3,1
 55a:	fec7f0e3          	bgeu	a5,a2,53a <printint+0x26>
  if(neg)
 55e:	00088c63          	beqz	a7,576 <printint+0x62>
    buf[i++] = '-';
 562:	fd070793          	add	a5,a4,-48
 566:	00878733          	add	a4,a5,s0
 56a:	02d00793          	li	a5,45
 56e:	fef70823          	sb	a5,-16(a4)
 572:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 576:	02e05c63          	blez	a4,5ae <printint+0x9a>
 57a:	f04a                	sd	s2,32(sp)
 57c:	ec4e                	sd	s3,24(sp)
 57e:	fc040793          	add	a5,s0,-64
 582:	00e78933          	add	s2,a5,a4
 586:	fff78993          	add	s3,a5,-1
 58a:	99ba                	add	s3,s3,a4
 58c:	377d                	addw	a4,a4,-1
 58e:	1702                	sll	a4,a4,0x20
 590:	9301                	srl	a4,a4,0x20
 592:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 596:	fff94583          	lbu	a1,-1(s2)
 59a:	8526                	mv	a0,s1
 59c:	00000097          	auipc	ra,0x0
 5a0:	f56080e7          	jalr	-170(ra) # 4f2 <putc>
  while(--i >= 0)
 5a4:	197d                	add	s2,s2,-1
 5a6:	ff3918e3          	bne	s2,s3,596 <printint+0x82>
 5aa:	7902                	ld	s2,32(sp)
 5ac:	69e2                	ld	s3,24(sp)
}
 5ae:	70e2                	ld	ra,56(sp)
 5b0:	7442                	ld	s0,48(sp)
 5b2:	74a2                	ld	s1,40(sp)
 5b4:	6121                	add	sp,sp,64
 5b6:	8082                	ret
    x = -xx;
 5b8:	40b005bb          	negw	a1,a1
    neg = 1;
 5bc:	4885                	li	a7,1
    x = -xx;
 5be:	b7b5                	j	52a <printint+0x16>

00000000000005c0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c0:	715d                	add	sp,sp,-80
 5c2:	e486                	sd	ra,72(sp)
 5c4:	e0a2                	sd	s0,64(sp)
 5c6:	f84a                	sd	s2,48(sp)
 5c8:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ca:	0005c903          	lbu	s2,0(a1)
 5ce:	1a090a63          	beqz	s2,782 <vprintf+0x1c2>
 5d2:	fc26                	sd	s1,56(sp)
 5d4:	f44e                	sd	s3,40(sp)
 5d6:	f052                	sd	s4,32(sp)
 5d8:	ec56                	sd	s5,24(sp)
 5da:	e85a                	sd	s6,16(sp)
 5dc:	e45e                	sd	s7,8(sp)
 5de:	8aaa                	mv	s5,a0
 5e0:	8bb2                	mv	s7,a2
 5e2:	00158493          	add	s1,a1,1
  state = 0;
 5e6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5e8:	02500a13          	li	s4,37
 5ec:	4b55                	li	s6,21
 5ee:	a839                	j	60c <vprintf+0x4c>
        putc(fd, c);
 5f0:	85ca                	mv	a1,s2
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	efe080e7          	jalr	-258(ra) # 4f2 <putc>
 5fc:	a019                	j	602 <vprintf+0x42>
    } else if(state == '%'){
 5fe:	01498d63          	beq	s3,s4,618 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 602:	0485                	add	s1,s1,1
 604:	fff4c903          	lbu	s2,-1(s1)
 608:	16090763          	beqz	s2,776 <vprintf+0x1b6>
    if(state == 0){
 60c:	fe0999e3          	bnez	s3,5fe <vprintf+0x3e>
      if(c == '%'){
 610:	ff4910e3          	bne	s2,s4,5f0 <vprintf+0x30>
        state = '%';
 614:	89d2                	mv	s3,s4
 616:	b7f5                	j	602 <vprintf+0x42>
      if(c == 'd'){
 618:	13490463          	beq	s2,s4,740 <vprintf+0x180>
 61c:	f9d9079b          	addw	a5,s2,-99
 620:	0ff7f793          	zext.b	a5,a5
 624:	12fb6763          	bltu	s6,a5,752 <vprintf+0x192>
 628:	f9d9079b          	addw	a5,s2,-99
 62c:	0ff7f713          	zext.b	a4,a5
 630:	12eb6163          	bltu	s6,a4,752 <vprintf+0x192>
 634:	00271793          	sll	a5,a4,0x2
 638:	00000717          	auipc	a4,0x0
 63c:	47870713          	add	a4,a4,1144 # ab0 <lock_release+0xd2>
 640:	97ba                	add	a5,a5,a4
 642:	439c                	lw	a5,0(a5)
 644:	97ba                	add	a5,a5,a4
 646:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 648:	008b8913          	add	s2,s7,8
 64c:	4685                	li	a3,1
 64e:	4629                	li	a2,10
 650:	000ba583          	lw	a1,0(s7)
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	ebe080e7          	jalr	-322(ra) # 514 <printint>
 65e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 660:	4981                	li	s3,0
 662:	b745                	j	602 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 664:	008b8913          	add	s2,s7,8
 668:	4681                	li	a3,0
 66a:	4629                	li	a2,10
 66c:	000ba583          	lw	a1,0(s7)
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	ea2080e7          	jalr	-350(ra) # 514 <printint>
 67a:	8bca                	mv	s7,s2
      state = 0;
 67c:	4981                	li	s3,0
 67e:	b751                	j	602 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 680:	008b8913          	add	s2,s7,8
 684:	4681                	li	a3,0
 686:	4641                	li	a2,16
 688:	000ba583          	lw	a1,0(s7)
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	e86080e7          	jalr	-378(ra) # 514 <printint>
 696:	8bca                	mv	s7,s2
      state = 0;
 698:	4981                	li	s3,0
 69a:	b7a5                	j	602 <vprintf+0x42>
 69c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 69e:	008b8c13          	add	s8,s7,8
 6a2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6a6:	03000593          	li	a1,48
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	e46080e7          	jalr	-442(ra) # 4f2 <putc>
  putc(fd, 'x');
 6b4:	07800593          	li	a1,120
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	e38080e7          	jalr	-456(ra) # 4f2 <putc>
 6c2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c4:	00000b97          	auipc	s7,0x0
 6c8:	444b8b93          	add	s7,s7,1092 # b08 <digits>
 6cc:	03c9d793          	srl	a5,s3,0x3c
 6d0:	97de                	add	a5,a5,s7
 6d2:	0007c583          	lbu	a1,0(a5)
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e1a080e7          	jalr	-486(ra) # 4f2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e0:	0992                	sll	s3,s3,0x4
 6e2:	397d                	addw	s2,s2,-1
 6e4:	fe0914e3          	bnez	s2,6cc <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6e8:	8be2                	mv	s7,s8
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	6c02                	ld	s8,0(sp)
 6ee:	bf11                	j	602 <vprintf+0x42>
        s = va_arg(ap, char*);
 6f0:	008b8993          	add	s3,s7,8
 6f4:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6f8:	02090163          	beqz	s2,71a <vprintf+0x15a>
        while(*s != 0){
 6fc:	00094583          	lbu	a1,0(s2)
 700:	c9a5                	beqz	a1,770 <vprintf+0x1b0>
          putc(fd, *s);
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	dee080e7          	jalr	-530(ra) # 4f2 <putc>
          s++;
 70c:	0905                	add	s2,s2,1
        while(*s != 0){
 70e:	00094583          	lbu	a1,0(s2)
 712:	f9e5                	bnez	a1,702 <vprintf+0x142>
        s = va_arg(ap, char*);
 714:	8bce                	mv	s7,s3
      state = 0;
 716:	4981                	li	s3,0
 718:	b5ed                	j	602 <vprintf+0x42>
          s = "(null)";
 71a:	00000917          	auipc	s2,0x0
 71e:	38e90913          	add	s2,s2,910 # aa8 <lock_release+0xca>
        while(*s != 0){
 722:	02800593          	li	a1,40
 726:	bff1                	j	702 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 728:	008b8913          	add	s2,s7,8
 72c:	000bc583          	lbu	a1,0(s7)
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	dc0080e7          	jalr	-576(ra) # 4f2 <putc>
 73a:	8bca                	mv	s7,s2
      state = 0;
 73c:	4981                	li	s3,0
 73e:	b5d1                	j	602 <vprintf+0x42>
        putc(fd, c);
 740:	02500593          	li	a1,37
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	dac080e7          	jalr	-596(ra) # 4f2 <putc>
      state = 0;
 74e:	4981                	li	s3,0
 750:	bd4d                	j	602 <vprintf+0x42>
        putc(fd, '%');
 752:	02500593          	li	a1,37
 756:	8556                	mv	a0,s5
 758:	00000097          	auipc	ra,0x0
 75c:	d9a080e7          	jalr	-614(ra) # 4f2 <putc>
        putc(fd, c);
 760:	85ca                	mv	a1,s2
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	d8e080e7          	jalr	-626(ra) # 4f2 <putc>
      state = 0;
 76c:	4981                	li	s3,0
 76e:	bd51                	j	602 <vprintf+0x42>
        s = va_arg(ap, char*);
 770:	8bce                	mv	s7,s3
      state = 0;
 772:	4981                	li	s3,0
 774:	b579                	j	602 <vprintf+0x42>
 776:	74e2                	ld	s1,56(sp)
 778:	79a2                	ld	s3,40(sp)
 77a:	7a02                	ld	s4,32(sp)
 77c:	6ae2                	ld	s5,24(sp)
 77e:	6b42                	ld	s6,16(sp)
 780:	6ba2                	ld	s7,8(sp)
    }
  }
}
 782:	60a6                	ld	ra,72(sp)
 784:	6406                	ld	s0,64(sp)
 786:	7942                	ld	s2,48(sp)
 788:	6161                	add	sp,sp,80
 78a:	8082                	ret

000000000000078c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 78c:	715d                	add	sp,sp,-80
 78e:	ec06                	sd	ra,24(sp)
 790:	e822                	sd	s0,16(sp)
 792:	1000                	add	s0,sp,32
 794:	e010                	sd	a2,0(s0)
 796:	e414                	sd	a3,8(s0)
 798:	e818                	sd	a4,16(s0)
 79a:	ec1c                	sd	a5,24(s0)
 79c:	03043023          	sd	a6,32(s0)
 7a0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a8:	8622                	mv	a2,s0
 7aa:	00000097          	auipc	ra,0x0
 7ae:	e16080e7          	jalr	-490(ra) # 5c0 <vprintf>
}
 7b2:	60e2                	ld	ra,24(sp)
 7b4:	6442                	ld	s0,16(sp)
 7b6:	6161                	add	sp,sp,80
 7b8:	8082                	ret

00000000000007ba <printf>:

void
printf(const char *fmt, ...)
{
 7ba:	711d                	add	sp,sp,-96
 7bc:	ec06                	sd	ra,24(sp)
 7be:	e822                	sd	s0,16(sp)
 7c0:	1000                	add	s0,sp,32
 7c2:	e40c                	sd	a1,8(s0)
 7c4:	e810                	sd	a2,16(s0)
 7c6:	ec14                	sd	a3,24(s0)
 7c8:	f018                	sd	a4,32(s0)
 7ca:	f41c                	sd	a5,40(s0)
 7cc:	03043823          	sd	a6,48(s0)
 7d0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d4:	00840613          	add	a2,s0,8
 7d8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7dc:	85aa                	mv	a1,a0
 7de:	4505                	li	a0,1
 7e0:	00000097          	auipc	ra,0x0
 7e4:	de0080e7          	jalr	-544(ra) # 5c0 <vprintf>
}
 7e8:	60e2                	ld	ra,24(sp)
 7ea:	6442                	ld	s0,16(sp)
 7ec:	6125                	add	sp,sp,96
 7ee:	8082                	ret

00000000000007f0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f0:	1141                	add	sp,sp,-16
 7f2:	e422                	sd	s0,8(sp)
 7f4:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f6:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fa:	00001797          	auipc	a5,0x1
 7fe:	81e7b783          	ld	a5,-2018(a5) # 1018 <freep>
 802:	a02d                	j	82c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 804:	4618                	lw	a4,8(a2)
 806:	9f2d                	addw	a4,a4,a1
 808:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 80c:	6398                	ld	a4,0(a5)
 80e:	6310                	ld	a2,0(a4)
 810:	a83d                	j	84e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 812:	ff852703          	lw	a4,-8(a0)
 816:	9f31                	addw	a4,a4,a2
 818:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 81a:	ff053683          	ld	a3,-16(a0)
 81e:	a091                	j	862 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 820:	6398                	ld	a4,0(a5)
 822:	00e7e463          	bltu	a5,a4,82a <free+0x3a>
 826:	00e6ea63          	bltu	a3,a4,83a <free+0x4a>
{
 82a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82c:	fed7fae3          	bgeu	a5,a3,820 <free+0x30>
 830:	6398                	ld	a4,0(a5)
 832:	00e6e463          	bltu	a3,a4,83a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 836:	fee7eae3          	bltu	a5,a4,82a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 83a:	ff852583          	lw	a1,-8(a0)
 83e:	6390                	ld	a2,0(a5)
 840:	02059813          	sll	a6,a1,0x20
 844:	01c85713          	srl	a4,a6,0x1c
 848:	9736                	add	a4,a4,a3
 84a:	fae60de3          	beq	a2,a4,804 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 84e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 852:	4790                	lw	a2,8(a5)
 854:	02061593          	sll	a1,a2,0x20
 858:	01c5d713          	srl	a4,a1,0x1c
 85c:	973e                	add	a4,a4,a5
 85e:	fae68ae3          	beq	a3,a4,812 <free+0x22>
    p->s.ptr = bp->s.ptr;
 862:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 864:	00000717          	auipc	a4,0x0
 868:	7af73a23          	sd	a5,1972(a4) # 1018 <freep>
}
 86c:	6422                	ld	s0,8(sp)
 86e:	0141                	add	sp,sp,16
 870:	8082                	ret

0000000000000872 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 872:	7139                	add	sp,sp,-64
 874:	fc06                	sd	ra,56(sp)
 876:	f822                	sd	s0,48(sp)
 878:	f426                	sd	s1,40(sp)
 87a:	ec4e                	sd	s3,24(sp)
 87c:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 87e:	02051493          	sll	s1,a0,0x20
 882:	9081                	srl	s1,s1,0x20
 884:	04bd                	add	s1,s1,15
 886:	8091                	srl	s1,s1,0x4
 888:	0014899b          	addw	s3,s1,1
 88c:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 88e:	00000517          	auipc	a0,0x0
 892:	78a53503          	ld	a0,1930(a0) # 1018 <freep>
 896:	c915                	beqz	a0,8ca <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 898:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89a:	4798                	lw	a4,8(a5)
 89c:	08977e63          	bgeu	a4,s1,938 <malloc+0xc6>
 8a0:	f04a                	sd	s2,32(sp)
 8a2:	e852                	sd	s4,16(sp)
 8a4:	e456                	sd	s5,8(sp)
 8a6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8a8:	8a4e                	mv	s4,s3
 8aa:	0009871b          	sext.w	a4,s3
 8ae:	6685                	lui	a3,0x1
 8b0:	00d77363          	bgeu	a4,a3,8b6 <malloc+0x44>
 8b4:	6a05                	lui	s4,0x1
 8b6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ba:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8be:	00000917          	auipc	s2,0x0
 8c2:	75a90913          	add	s2,s2,1882 # 1018 <freep>
  if(p == (char*)-1)
 8c6:	5afd                	li	s5,-1
 8c8:	a091                	j	90c <malloc+0x9a>
 8ca:	f04a                	sd	s2,32(sp)
 8cc:	e852                	sd	s4,16(sp)
 8ce:	e456                	sd	s5,8(sp)
 8d0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8d2:	00000797          	auipc	a5,0x0
 8d6:	74e78793          	add	a5,a5,1870 # 1020 <base>
 8da:	00000717          	auipc	a4,0x0
 8de:	72f73f23          	sd	a5,1854(a4) # 1018 <freep>
 8e2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e8:	b7c1                	j	8a8 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8ea:	6398                	ld	a4,0(a5)
 8ec:	e118                	sd	a4,0(a0)
 8ee:	a08d                	j	950 <malloc+0xde>
  hp->s.size = nu;
 8f0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f4:	0541                	add	a0,a0,16
 8f6:	00000097          	auipc	ra,0x0
 8fa:	efa080e7          	jalr	-262(ra) # 7f0 <free>
  return freep;
 8fe:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 902:	c13d                	beqz	a0,968 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 904:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 906:	4798                	lw	a4,8(a5)
 908:	02977463          	bgeu	a4,s1,930 <malloc+0xbe>
    if(p == freep)
 90c:	00093703          	ld	a4,0(s2)
 910:	853e                	mv	a0,a5
 912:	fef719e3          	bne	a4,a5,904 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 916:	8552                	mv	a0,s4
 918:	00000097          	auipc	ra,0x0
 91c:	bba080e7          	jalr	-1094(ra) # 4d2 <sbrk>
  if(p == (char*)-1)
 920:	fd5518e3          	bne	a0,s5,8f0 <malloc+0x7e>
        return 0;
 924:	4501                	li	a0,0
 926:	7902                	ld	s2,32(sp)
 928:	6a42                	ld	s4,16(sp)
 92a:	6aa2                	ld	s5,8(sp)
 92c:	6b02                	ld	s6,0(sp)
 92e:	a03d                	j	95c <malloc+0xea>
 930:	7902                	ld	s2,32(sp)
 932:	6a42                	ld	s4,16(sp)
 934:	6aa2                	ld	s5,8(sp)
 936:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 938:	fae489e3          	beq	s1,a4,8ea <malloc+0x78>
        p->s.size -= nunits;
 93c:	4137073b          	subw	a4,a4,s3
 940:	c798                	sw	a4,8(a5)
        p += p->s.size;
 942:	02071693          	sll	a3,a4,0x20
 946:	01c6d713          	srl	a4,a3,0x1c
 94a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 94c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 950:	00000717          	auipc	a4,0x0
 954:	6ca73423          	sd	a0,1736(a4) # 1018 <freep>
      return (void*)(p + 1);
 958:	01078513          	add	a0,a5,16
  }
}
 95c:	70e2                	ld	ra,56(sp)
 95e:	7442                	ld	s0,48(sp)
 960:	74a2                	ld	s1,40(sp)
 962:	69e2                	ld	s3,24(sp)
 964:	6121                	add	sp,sp,64
 966:	8082                	ret
 968:	7902                	ld	s2,32(sp)
 96a:	6a42                	ld	s4,16(sp)
 96c:	6aa2                	ld	s5,8(sp)
 96e:	6b02                	ld	s6,0(sp)
 970:	b7f5                	j	95c <malloc+0xea>

0000000000000972 <thread_create>:
#include "user/thread.h" 
#include "user/user.h" 
#define PGSIZE 4096

// Create a new thread using the given start_routine and argument.
int thread_create(void *(start_routine)(void*), void *arg) {
 972:	1101                	add	sp,sp,-32
 974:	ec06                	sd	ra,24(sp)
 976:	e822                	sd	s0,16(sp)
 978:	e426                	sd	s1,8(sp)
 97a:	e04a                	sd	s2,0(sp)
 97c:	1000                	add	s0,sp,32
 97e:	84aa                	mv	s1,a0
 980:	892e                	mv	s2,a1
    // Allocate a stack pointer of PGSIZE bytes (4096).
    int ptr_size = PGSIZE * sizeof(void);
    void* st_ptr = (void*)malloc(ptr_size);
 982:	6505                	lui	a0,0x1
 984:	00000097          	auipc	ra,0x0
 988:	eee080e7          	jalr	-274(ra) # 872 <malloc>
    int tid = clone(st_ptr);
 98c:	00000097          	auipc	ra,0x0
 990:	b5e080e7          	jalr	-1186(ra) # 4ea <clone>

    // For the child process, call the start_routine function with the argument.
    if (tid == 0) {
 994:	c901                	beqz	a0,9a4 <thread_create+0x32>
        exit(0);
    }

    // Return 0 for the parent process.
    return 0;
}
 996:	4501                	li	a0,0
 998:	60e2                	ld	ra,24(sp)
 99a:	6442                	ld	s0,16(sp)
 99c:	64a2                	ld	s1,8(sp)
 99e:	6902                	ld	s2,0(sp)
 9a0:	6105                	add	sp,sp,32
 9a2:	8082                	ret
        (*start_routine)(arg);
 9a4:	854a                	mv	a0,s2
 9a6:	9482                	jalr	s1
        exit(0);
 9a8:	4501                	li	a0,0
 9aa:	00000097          	auipc	ra,0x0
 9ae:	aa0080e7          	jalr	-1376(ra) # 44a <exit>

00000000000009b2 <lock_init>:

// Initialize a lock.
void lock_init(struct lock_t* lock) {
 9b2:	1141                	add	sp,sp,-16
 9b4:	e422                	sd	s0,8(sp)
 9b6:	0800                	add	s0,sp,16
    lock->locked = 0;
 9b8:	00052023          	sw	zero,0(a0) # 1000 <cur_pass>
}
 9bc:	6422                	ld	s0,8(sp)
 9be:	0141                	add	sp,sp,16
 9c0:	8082                	ret

00000000000009c2 <lock_acquire>:

// Acquire the lock.
void lock_acquire(struct lock_t* lock) {
 9c2:	1141                	add	sp,sp,-16
 9c4:	e422                	sd	s0,8(sp)
 9c6:	0800                	add	s0,sp,16
    // Spin until the lock is acquired.
    while (__sync_lock_test_and_set(&lock->locked, 1) != 0);
 9c8:	4705                	li	a4,1
 9ca:	87ba                	mv	a5,a4
 9cc:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
 9d0:	2781                	sext.w	a5,a5
 9d2:	ffe5                	bnez	a5,9ca <lock_acquire+0x8>
    // Ensure memory operations strictly follow the lock acquisition.
    __sync_synchronize();
 9d4:	0ff0000f          	fence
}
 9d8:	6422                	ld	s0,8(sp)
 9da:	0141                	add	sp,sp,16
 9dc:	8082                	ret

00000000000009de <lock_release>:

// Release the lock.
void lock_release(struct lock_t* lock) {
 9de:	1141                	add	sp,sp,-16
 9e0:	e422                	sd	s0,8(sp)
 9e2:	0800                	add	s0,sp,16
    // Ensure all memory operations in the critical section are visible to other CPUs.
    __sync_synchronize();
 9e4:	0ff0000f          	fence
    // Release the lock by setting it to 0.
    __sync_lock_release(&lock->locked, 0);
 9e8:	0f50000f          	fence	iorw,ow
 9ec:	0805202f          	amoswap.w	zero,zero,(a0)
}
 9f0:	6422                	ld	s0,8(sp)
 9f2:	0141                	add	sp,sp,16
 9f4:	8082                	ret
