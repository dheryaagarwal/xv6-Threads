
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dd010113          	add	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	add	s0,sp,560
  int fd, i;
  char path[] = "stressfs0";
  16:	00001797          	auipc	a5,0x1
  1a:	95a78793          	add	a5,a5,-1702 # 970 <lock_release+0x4a>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	91450513          	add	a0,a0,-1772 # 940 <lock_release+0x1a>
  34:	00000097          	auipc	ra,0x0
  38:	6ce080e7          	jalr	1742(ra) # 702 <printf>
  memset(data, 'a', sizeof(data));
  3c:	20000613          	li	a2,512
  40:	06100593          	li	a1,97
  44:	dd040513          	add	a0,s0,-560
  48:	00000097          	auipc	ra,0x0
  4c:	150080e7          	jalr	336(ra) # 198 <memset>

  for(i = 0; i < 4; i++)
  50:	4481                	li	s1,0
  52:	4911                	li	s2,4
    if(fork() > 0)
  54:	00000097          	auipc	ra,0x0
  58:	336080e7          	jalr	822(ra) # 38a <fork>
  5c:	00a04563          	bgtz	a0,66 <main+0x66>
  for(i = 0; i < 4; i++)
  60:	2485                	addw	s1,s1,1
  62:	ff2499e3          	bne	s1,s2,54 <main+0x54>
      break;

  printf("write %d\n", i);
  66:	85a6                	mv	a1,s1
  68:	00001517          	auipc	a0,0x1
  6c:	8f050513          	add	a0,a0,-1808 # 958 <lock_release+0x32>
  70:	00000097          	auipc	ra,0x0
  74:	692080e7          	jalr	1682(ra) # 702 <printf>

  path[8] += i;
  78:	fd844783          	lbu	a5,-40(s0)
  7c:	9fa5                	addw	a5,a5,s1
  7e:	fcf40c23          	sb	a5,-40(s0)
  fd = open(path, O_CREATE | O_RDWR);
  82:	20200593          	li	a1,514
  86:	fd040513          	add	a0,s0,-48
  8a:	00000097          	auipc	ra,0x0
  8e:	348080e7          	jalr	840(ra) # 3d2 <open>
  92:	892a                	mv	s2,a0
  94:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  96:	20000613          	li	a2,512
  9a:	dd040593          	add	a1,s0,-560
  9e:	854a                	mv	a0,s2
  a0:	00000097          	auipc	ra,0x0
  a4:	312080e7          	jalr	786(ra) # 3b2 <write>
  for(i = 0; i < 20; i++)
  a8:	34fd                	addw	s1,s1,-1
  aa:	f4f5                	bnez	s1,96 <main+0x96>
  close(fd);
  ac:	854a                	mv	a0,s2
  ae:	00000097          	auipc	ra,0x0
  b2:	30c080e7          	jalr	780(ra) # 3ba <close>

  printf("read\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	8b250513          	add	a0,a0,-1870 # 968 <lock_release+0x42>
  be:	00000097          	auipc	ra,0x0
  c2:	644080e7          	jalr	1604(ra) # 702 <printf>

  fd = open(path, O_RDONLY);
  c6:	4581                	li	a1,0
  c8:	fd040513          	add	a0,s0,-48
  cc:	00000097          	auipc	ra,0x0
  d0:	306080e7          	jalr	774(ra) # 3d2 <open>
  d4:	892a                	mv	s2,a0
  d6:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  d8:	20000613          	li	a2,512
  dc:	dd040593          	add	a1,s0,-560
  e0:	854a                	mv	a0,s2
  e2:	00000097          	auipc	ra,0x0
  e6:	2c8080e7          	jalr	712(ra) # 3aa <read>
  for (i = 0; i < 20; i++)
  ea:	34fd                	addw	s1,s1,-1
  ec:	f4f5                	bnez	s1,d8 <main+0xd8>
  close(fd);
  ee:	854a                	mv	a0,s2
  f0:	00000097          	auipc	ra,0x0
  f4:	2ca080e7          	jalr	714(ra) # 3ba <close>

  wait(0);
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	2a0080e7          	jalr	672(ra) # 39a <wait>

  exit(0);
 102:	4501                	li	a0,0
 104:	00000097          	auipc	ra,0x0
 108:	28e080e7          	jalr	654(ra) # 392 <exit>

000000000000010c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 10c:	1141                	add	sp,sp,-16
 10e:	e406                	sd	ra,8(sp)
 110:	e022                	sd	s0,0(sp)
 112:	0800                	add	s0,sp,16
  extern int main();
  main();
 114:	00000097          	auipc	ra,0x0
 118:	eec080e7          	jalr	-276(ra) # 0 <main>
  exit(0);
 11c:	4501                	li	a0,0
 11e:	00000097          	auipc	ra,0x0
 122:	274080e7          	jalr	628(ra) # 392 <exit>

0000000000000126 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 126:	1141                	add	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12c:	87aa                	mv	a5,a0
 12e:	0585                	add	a1,a1,1
 130:	0785                	add	a5,a5,1
 132:	fff5c703          	lbu	a4,-1(a1)
 136:	fee78fa3          	sb	a4,-1(a5)
 13a:	fb75                	bnez	a4,12e <strcpy+0x8>
    ;
  return os;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	add	sp,sp,16
 140:	8082                	ret

0000000000000142 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 142:	1141                	add	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 148:	00054783          	lbu	a5,0(a0)
 14c:	cb91                	beqz	a5,160 <strcmp+0x1e>
 14e:	0005c703          	lbu	a4,0(a1)
 152:	00f71763          	bne	a4,a5,160 <strcmp+0x1e>
    p++, q++;
 156:	0505                	add	a0,a0,1
 158:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbe5                	bnez	a5,14e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 160:	0005c503          	lbu	a0,0(a1)
}
 164:	40a7853b          	subw	a0,a5,a0
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	add	sp,sp,16
 16c:	8082                	ret

000000000000016e <strlen>:

uint
strlen(const char *s)
{
 16e:	1141                	add	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 174:	00054783          	lbu	a5,0(a0)
 178:	cf91                	beqz	a5,194 <strlen+0x26>
 17a:	0505                	add	a0,a0,1
 17c:	87aa                	mv	a5,a0
 17e:	86be                	mv	a3,a5
 180:	0785                	add	a5,a5,1
 182:	fff7c703          	lbu	a4,-1(a5)
 186:	ff65                	bnez	a4,17e <strlen+0x10>
 188:	40a6853b          	subw	a0,a3,a0
 18c:	2505                	addw	a0,a0,1
    ;
  return n;
}
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	add	sp,sp,16
 192:	8082                	ret
  for(n = 0; s[n]; n++)
 194:	4501                	li	a0,0
 196:	bfe5                	j	18e <strlen+0x20>

0000000000000198 <memset>:

void*
memset(void *dst, int c, uint n)
{
 198:	1141                	add	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 19e:	ca19                	beqz	a2,1b4 <memset+0x1c>
 1a0:	87aa                	mv	a5,a0
 1a2:	1602                	sll	a2,a2,0x20
 1a4:	9201                	srl	a2,a2,0x20
 1a6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1aa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ae:	0785                	add	a5,a5,1
 1b0:	fee79de3          	bne	a5,a4,1aa <memset+0x12>
  }
  return dst;
}
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	add	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strchr>:

char*
strchr(const char *s, char c)
{
 1ba:	1141                	add	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	add	s0,sp,16
  for(; *s; s++)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cb99                	beqz	a5,1da <strchr+0x20>
    if(*s == c)
 1c6:	00f58763          	beq	a1,a5,1d4 <strchr+0x1a>
  for(; *s; s++)
 1ca:	0505                	add	a0,a0,1
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	fbfd                	bnez	a5,1c6 <strchr+0xc>
      return (char*)s;
  return 0;
 1d2:	4501                	li	a0,0
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	add	sp,sp,16
 1d8:	8082                	ret
  return 0;
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strchr+0x1a>

00000000000001de <gets>:

char*
gets(char *buf, int max)
{
 1de:	711d                	add	sp,sp,-96
 1e0:	ec86                	sd	ra,88(sp)
 1e2:	e8a2                	sd	s0,80(sp)
 1e4:	e4a6                	sd	s1,72(sp)
 1e6:	e0ca                	sd	s2,64(sp)
 1e8:	fc4e                	sd	s3,56(sp)
 1ea:	f852                	sd	s4,48(sp)
 1ec:	f456                	sd	s5,40(sp)
 1ee:	f05a                	sd	s6,32(sp)
 1f0:	ec5e                	sd	s7,24(sp)
 1f2:	1080                	add	s0,sp,96
 1f4:	8baa                	mv	s7,a0
 1f6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f8:	892a                	mv	s2,a0
 1fa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1fc:	4aa9                	li	s5,10
 1fe:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 200:	89a6                	mv	s3,s1
 202:	2485                	addw	s1,s1,1
 204:	0344d863          	bge	s1,s4,234 <gets+0x56>
    cc = read(0, &c, 1);
 208:	4605                	li	a2,1
 20a:	faf40593          	add	a1,s0,-81
 20e:	4501                	li	a0,0
 210:	00000097          	auipc	ra,0x0
 214:	19a080e7          	jalr	410(ra) # 3aa <read>
    if(cc < 1)
 218:	00a05e63          	blez	a0,234 <gets+0x56>
    buf[i++] = c;
 21c:	faf44783          	lbu	a5,-81(s0)
 220:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 224:	01578763          	beq	a5,s5,232 <gets+0x54>
 228:	0905                	add	s2,s2,1
 22a:	fd679be3          	bne	a5,s6,200 <gets+0x22>
    buf[i++] = c;
 22e:	89a6                	mv	s3,s1
 230:	a011                	j	234 <gets+0x56>
 232:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 234:	99de                	add	s3,s3,s7
 236:	00098023          	sb	zero,0(s3)
  return buf;
}
 23a:	855e                	mv	a0,s7
 23c:	60e6                	ld	ra,88(sp)
 23e:	6446                	ld	s0,80(sp)
 240:	64a6                	ld	s1,72(sp)
 242:	6906                	ld	s2,64(sp)
 244:	79e2                	ld	s3,56(sp)
 246:	7a42                	ld	s4,48(sp)
 248:	7aa2                	ld	s5,40(sp)
 24a:	7b02                	ld	s6,32(sp)
 24c:	6be2                	ld	s7,24(sp)
 24e:	6125                	add	sp,sp,96
 250:	8082                	ret

0000000000000252 <stat>:

int
stat(const char *n, struct stat *st)
{
 252:	1101                	add	sp,sp,-32
 254:	ec06                	sd	ra,24(sp)
 256:	e822                	sd	s0,16(sp)
 258:	e04a                	sd	s2,0(sp)
 25a:	1000                	add	s0,sp,32
 25c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25e:	4581                	li	a1,0
 260:	00000097          	auipc	ra,0x0
 264:	172080e7          	jalr	370(ra) # 3d2 <open>
  if(fd < 0)
 268:	02054663          	bltz	a0,294 <stat+0x42>
 26c:	e426                	sd	s1,8(sp)
 26e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 270:	85ca                	mv	a1,s2
 272:	00000097          	auipc	ra,0x0
 276:	178080e7          	jalr	376(ra) # 3ea <fstat>
 27a:	892a                	mv	s2,a0
  close(fd);
 27c:	8526                	mv	a0,s1
 27e:	00000097          	auipc	ra,0x0
 282:	13c080e7          	jalr	316(ra) # 3ba <close>
  return r;
 286:	64a2                	ld	s1,8(sp)
}
 288:	854a                	mv	a0,s2
 28a:	60e2                	ld	ra,24(sp)
 28c:	6442                	ld	s0,16(sp)
 28e:	6902                	ld	s2,0(sp)
 290:	6105                	add	sp,sp,32
 292:	8082                	ret
    return -1;
 294:	597d                	li	s2,-1
 296:	bfcd                	j	288 <stat+0x36>

0000000000000298 <atoi>:

int
atoi(const char *s)
{
 298:	1141                	add	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29e:	00054683          	lbu	a3,0(a0)
 2a2:	fd06879b          	addw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	4625                	li	a2,9
 2ac:	02f66863          	bltu	a2,a5,2dc <atoi+0x44>
 2b0:	872a                	mv	a4,a0
  n = 0;
 2b2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2b4:	0705                	add	a4,a4,1
 2b6:	0025179b          	sllw	a5,a0,0x2
 2ba:	9fa9                	addw	a5,a5,a0
 2bc:	0017979b          	sllw	a5,a5,0x1
 2c0:	9fb5                	addw	a5,a5,a3
 2c2:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c6:	00074683          	lbu	a3,0(a4)
 2ca:	fd06879b          	addw	a5,a3,-48
 2ce:	0ff7f793          	zext.b	a5,a5
 2d2:	fef671e3          	bgeu	a2,a5,2b4 <atoi+0x1c>
  return n;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	add	sp,sp,16
 2da:	8082                	ret
  n = 0;
 2dc:	4501                	li	a0,0
 2de:	bfe5                	j	2d6 <atoi+0x3e>

00000000000002e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e0:	1141                	add	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e6:	02b57463          	bgeu	a0,a1,30e <memmove+0x2e>
    while(n-- > 0)
 2ea:	00c05f63          	blez	a2,308 <memmove+0x28>
 2ee:	1602                	sll	a2,a2,0x20
 2f0:	9201                	srl	a2,a2,0x20
 2f2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f8:	0585                	add	a1,a1,1
 2fa:	0705                	add	a4,a4,1
 2fc:	fff5c683          	lbu	a3,-1(a1)
 300:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 304:	fef71ae3          	bne	a4,a5,2f8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	add	sp,sp,16
 30c:	8082                	ret
    dst += n;
 30e:	00c50733          	add	a4,a0,a2
    src += n;
 312:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 314:	fec05ae3          	blez	a2,308 <memmove+0x28>
 318:	fff6079b          	addw	a5,a2,-1
 31c:	1782                	sll	a5,a5,0x20
 31e:	9381                	srl	a5,a5,0x20
 320:	fff7c793          	not	a5,a5
 324:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 326:	15fd                	add	a1,a1,-1
 328:	177d                	add	a4,a4,-1
 32a:	0005c683          	lbu	a3,0(a1)
 32e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 332:	fee79ae3          	bne	a5,a4,326 <memmove+0x46>
 336:	bfc9                	j	308 <memmove+0x28>

0000000000000338 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 338:	1141                	add	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33e:	ca05                	beqz	a2,36e <memcmp+0x36>
 340:	fff6069b          	addw	a3,a2,-1
 344:	1682                	sll	a3,a3,0x20
 346:	9281                	srl	a3,a3,0x20
 348:	0685                	add	a3,a3,1
 34a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 34c:	00054783          	lbu	a5,0(a0)
 350:	0005c703          	lbu	a4,0(a1)
 354:	00e79863          	bne	a5,a4,364 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 358:	0505                	add	a0,a0,1
    p2++;
 35a:	0585                	add	a1,a1,1
  while (n-- > 0) {
 35c:	fed518e3          	bne	a0,a3,34c <memcmp+0x14>
  }
  return 0;
 360:	4501                	li	a0,0
 362:	a019                	j	368 <memcmp+0x30>
      return *p1 - *p2;
 364:	40e7853b          	subw	a0,a5,a4
}
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	add	sp,sp,16
 36c:	8082                	ret
  return 0;
 36e:	4501                	li	a0,0
 370:	bfe5                	j	368 <memcmp+0x30>

0000000000000372 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 372:	1141                	add	sp,sp,-16
 374:	e406                	sd	ra,8(sp)
 376:	e022                	sd	s0,0(sp)
 378:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 37a:	00000097          	auipc	ra,0x0
 37e:	f66080e7          	jalr	-154(ra) # 2e0 <memmove>
}
 382:	60a2                	ld	ra,8(sp)
 384:	6402                	ld	s0,0(sp)
 386:	0141                	add	sp,sp,16
 388:	8082                	ret

000000000000038a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 38a:	4885                	li	a7,1
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exit>:
.global exit
exit:
 li a7, SYS_exit
 392:	4889                	li	a7,2
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <wait>:
.global wait
wait:
 li a7, SYS_wait
 39a:	488d                	li	a7,3
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a2:	4891                	li	a7,4
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <read>:
.global read
read:
 li a7, SYS_read
 3aa:	4895                	li	a7,5
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <write>:
.global write
write:
 li a7, SYS_write
 3b2:	48c1                	li	a7,16
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <close>:
.global close
close:
 li a7, SYS_close
 3ba:	48d5                	li	a7,21
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c2:	4899                	li	a7,6
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ca:	489d                	li	a7,7
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <open>:
.global open
open:
 li a7, SYS_open
 3d2:	48bd                	li	a7,15
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3da:	48c5                	li	a7,17
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e2:	48c9                	li	a7,18
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ea:	48a1                	li	a7,8
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <link>:
.global link
link:
 li a7, SYS_link
 3f2:	48cd                	li	a7,19
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3fa:	48d1                	li	a7,20
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 402:	48a5                	li	a7,9
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <dup>:
.global dup
dup:
 li a7, SYS_dup
 40a:	48a9                	li	a7,10
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 412:	48ad                	li	a7,11
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 41a:	48b1                	li	a7,12
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 422:	48b5                	li	a7,13
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 42a:	48b9                	li	a7,14
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <clone>:
.global clone
clone:
 li a7, SYS_clone
 432:	48d9                	li	a7,22
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 43a:	1101                	add	sp,sp,-32
 43c:	ec06                	sd	ra,24(sp)
 43e:	e822                	sd	s0,16(sp)
 440:	1000                	add	s0,sp,32
 442:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 446:	4605                	li	a2,1
 448:	fef40593          	add	a1,s0,-17
 44c:	00000097          	auipc	ra,0x0
 450:	f66080e7          	jalr	-154(ra) # 3b2 <write>
}
 454:	60e2                	ld	ra,24(sp)
 456:	6442                	ld	s0,16(sp)
 458:	6105                	add	sp,sp,32
 45a:	8082                	ret

000000000000045c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45c:	7139                	add	sp,sp,-64
 45e:	fc06                	sd	ra,56(sp)
 460:	f822                	sd	s0,48(sp)
 462:	f426                	sd	s1,40(sp)
 464:	0080                	add	s0,sp,64
 466:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 468:	c299                	beqz	a3,46e <printint+0x12>
 46a:	0805cb63          	bltz	a1,500 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 46e:	2581                	sext.w	a1,a1
  neg = 0;
 470:	4881                	li	a7,0
 472:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 476:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 478:	2601                	sext.w	a2,a2
 47a:	00000517          	auipc	a0,0x0
 47e:	56650513          	add	a0,a0,1382 # 9e0 <digits>
 482:	883a                	mv	a6,a4
 484:	2705                	addw	a4,a4,1
 486:	02c5f7bb          	remuw	a5,a1,a2
 48a:	1782                	sll	a5,a5,0x20
 48c:	9381                	srl	a5,a5,0x20
 48e:	97aa                	add	a5,a5,a0
 490:	0007c783          	lbu	a5,0(a5)
 494:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 498:	0005879b          	sext.w	a5,a1
 49c:	02c5d5bb          	divuw	a1,a1,a2
 4a0:	0685                	add	a3,a3,1
 4a2:	fec7f0e3          	bgeu	a5,a2,482 <printint+0x26>
  if(neg)
 4a6:	00088c63          	beqz	a7,4be <printint+0x62>
    buf[i++] = '-';
 4aa:	fd070793          	add	a5,a4,-48
 4ae:	00878733          	add	a4,a5,s0
 4b2:	02d00793          	li	a5,45
 4b6:	fef70823          	sb	a5,-16(a4)
 4ba:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 4be:	02e05c63          	blez	a4,4f6 <printint+0x9a>
 4c2:	f04a                	sd	s2,32(sp)
 4c4:	ec4e                	sd	s3,24(sp)
 4c6:	fc040793          	add	a5,s0,-64
 4ca:	00e78933          	add	s2,a5,a4
 4ce:	fff78993          	add	s3,a5,-1
 4d2:	99ba                	add	s3,s3,a4
 4d4:	377d                	addw	a4,a4,-1
 4d6:	1702                	sll	a4,a4,0x20
 4d8:	9301                	srl	a4,a4,0x20
 4da:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4de:	fff94583          	lbu	a1,-1(s2)
 4e2:	8526                	mv	a0,s1
 4e4:	00000097          	auipc	ra,0x0
 4e8:	f56080e7          	jalr	-170(ra) # 43a <putc>
  while(--i >= 0)
 4ec:	197d                	add	s2,s2,-1
 4ee:	ff3918e3          	bne	s2,s3,4de <printint+0x82>
 4f2:	7902                	ld	s2,32(sp)
 4f4:	69e2                	ld	s3,24(sp)
}
 4f6:	70e2                	ld	ra,56(sp)
 4f8:	7442                	ld	s0,48(sp)
 4fa:	74a2                	ld	s1,40(sp)
 4fc:	6121                	add	sp,sp,64
 4fe:	8082                	ret
    x = -xx;
 500:	40b005bb          	negw	a1,a1
    neg = 1;
 504:	4885                	li	a7,1
    x = -xx;
 506:	b7b5                	j	472 <printint+0x16>

0000000000000508 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 508:	715d                	add	sp,sp,-80
 50a:	e486                	sd	ra,72(sp)
 50c:	e0a2                	sd	s0,64(sp)
 50e:	f84a                	sd	s2,48(sp)
 510:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 512:	0005c903          	lbu	s2,0(a1)
 516:	1a090a63          	beqz	s2,6ca <vprintf+0x1c2>
 51a:	fc26                	sd	s1,56(sp)
 51c:	f44e                	sd	s3,40(sp)
 51e:	f052                	sd	s4,32(sp)
 520:	ec56                	sd	s5,24(sp)
 522:	e85a                	sd	s6,16(sp)
 524:	e45e                	sd	s7,8(sp)
 526:	8aaa                	mv	s5,a0
 528:	8bb2                	mv	s7,a2
 52a:	00158493          	add	s1,a1,1
  state = 0;
 52e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 530:	02500a13          	li	s4,37
 534:	4b55                	li	s6,21
 536:	a839                	j	554 <vprintf+0x4c>
        putc(fd, c);
 538:	85ca                	mv	a1,s2
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	efe080e7          	jalr	-258(ra) # 43a <putc>
 544:	a019                	j	54a <vprintf+0x42>
    } else if(state == '%'){
 546:	01498d63          	beq	s3,s4,560 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 54a:	0485                	add	s1,s1,1
 54c:	fff4c903          	lbu	s2,-1(s1)
 550:	16090763          	beqz	s2,6be <vprintf+0x1b6>
    if(state == 0){
 554:	fe0999e3          	bnez	s3,546 <vprintf+0x3e>
      if(c == '%'){
 558:	ff4910e3          	bne	s2,s4,538 <vprintf+0x30>
        state = '%';
 55c:	89d2                	mv	s3,s4
 55e:	b7f5                	j	54a <vprintf+0x42>
      if(c == 'd'){
 560:	13490463          	beq	s2,s4,688 <vprintf+0x180>
 564:	f9d9079b          	addw	a5,s2,-99
 568:	0ff7f793          	zext.b	a5,a5
 56c:	12fb6763          	bltu	s6,a5,69a <vprintf+0x192>
 570:	f9d9079b          	addw	a5,s2,-99
 574:	0ff7f713          	zext.b	a4,a5
 578:	12eb6163          	bltu	s6,a4,69a <vprintf+0x192>
 57c:	00271793          	sll	a5,a4,0x2
 580:	00000717          	auipc	a4,0x0
 584:	40870713          	add	a4,a4,1032 # 988 <lock_release+0x62>
 588:	97ba                	add	a5,a5,a4
 58a:	439c                	lw	a5,0(a5)
 58c:	97ba                	add	a5,a5,a4
 58e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 590:	008b8913          	add	s2,s7,8
 594:	4685                	li	a3,1
 596:	4629                	li	a2,10
 598:	000ba583          	lw	a1,0(s7)
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	ebe080e7          	jalr	-322(ra) # 45c <printint>
 5a6:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	b745                	j	54a <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ac:	008b8913          	add	s2,s7,8
 5b0:	4681                	li	a3,0
 5b2:	4629                	li	a2,10
 5b4:	000ba583          	lw	a1,0(s7)
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	ea2080e7          	jalr	-350(ra) # 45c <printint>
 5c2:	8bca                	mv	s7,s2
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b751                	j	54a <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5c8:	008b8913          	add	s2,s7,8
 5cc:	4681                	li	a3,0
 5ce:	4641                	li	a2,16
 5d0:	000ba583          	lw	a1,0(s7)
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	e86080e7          	jalr	-378(ra) # 45c <printint>
 5de:	8bca                	mv	s7,s2
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	b7a5                	j	54a <vprintf+0x42>
 5e4:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5e6:	008b8c13          	add	s8,s7,8
 5ea:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5ee:	03000593          	li	a1,48
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e46080e7          	jalr	-442(ra) # 43a <putc>
  putc(fd, 'x');
 5fc:	07800593          	li	a1,120
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	e38080e7          	jalr	-456(ra) # 43a <putc>
 60a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60c:	00000b97          	auipc	s7,0x0
 610:	3d4b8b93          	add	s7,s7,980 # 9e0 <digits>
 614:	03c9d793          	srl	a5,s3,0x3c
 618:	97de                	add	a5,a5,s7
 61a:	0007c583          	lbu	a1,0(a5)
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	e1a080e7          	jalr	-486(ra) # 43a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 628:	0992                	sll	s3,s3,0x4
 62a:	397d                	addw	s2,s2,-1
 62c:	fe0914e3          	bnez	s2,614 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 630:	8be2                	mv	s7,s8
      state = 0;
 632:	4981                	li	s3,0
 634:	6c02                	ld	s8,0(sp)
 636:	bf11                	j	54a <vprintf+0x42>
        s = va_arg(ap, char*);
 638:	008b8993          	add	s3,s7,8
 63c:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 640:	02090163          	beqz	s2,662 <vprintf+0x15a>
        while(*s != 0){
 644:	00094583          	lbu	a1,0(s2)
 648:	c9a5                	beqz	a1,6b8 <vprintf+0x1b0>
          putc(fd, *s);
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	dee080e7          	jalr	-530(ra) # 43a <putc>
          s++;
 654:	0905                	add	s2,s2,1
        while(*s != 0){
 656:	00094583          	lbu	a1,0(s2)
 65a:	f9e5                	bnez	a1,64a <vprintf+0x142>
        s = va_arg(ap, char*);
 65c:	8bce                	mv	s7,s3
      state = 0;
 65e:	4981                	li	s3,0
 660:	b5ed                	j	54a <vprintf+0x42>
          s = "(null)";
 662:	00000917          	auipc	s2,0x0
 666:	31e90913          	add	s2,s2,798 # 980 <lock_release+0x5a>
        while(*s != 0){
 66a:	02800593          	li	a1,40
 66e:	bff1                	j	64a <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 670:	008b8913          	add	s2,s7,8
 674:	000bc583          	lbu	a1,0(s7)
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	dc0080e7          	jalr	-576(ra) # 43a <putc>
 682:	8bca                	mv	s7,s2
      state = 0;
 684:	4981                	li	s3,0
 686:	b5d1                	j	54a <vprintf+0x42>
        putc(fd, c);
 688:	02500593          	li	a1,37
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	dac080e7          	jalr	-596(ra) # 43a <putc>
      state = 0;
 696:	4981                	li	s3,0
 698:	bd4d                	j	54a <vprintf+0x42>
        putc(fd, '%');
 69a:	02500593          	li	a1,37
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	d9a080e7          	jalr	-614(ra) # 43a <putc>
        putc(fd, c);
 6a8:	85ca                	mv	a1,s2
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	d8e080e7          	jalr	-626(ra) # 43a <putc>
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	bd51                	j	54a <vprintf+0x42>
        s = va_arg(ap, char*);
 6b8:	8bce                	mv	s7,s3
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b579                	j	54a <vprintf+0x42>
 6be:	74e2                	ld	s1,56(sp)
 6c0:	79a2                	ld	s3,40(sp)
 6c2:	7a02                	ld	s4,32(sp)
 6c4:	6ae2                	ld	s5,24(sp)
 6c6:	6b42                	ld	s6,16(sp)
 6c8:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6ca:	60a6                	ld	ra,72(sp)
 6cc:	6406                	ld	s0,64(sp)
 6ce:	7942                	ld	s2,48(sp)
 6d0:	6161                	add	sp,sp,80
 6d2:	8082                	ret

00000000000006d4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d4:	715d                	add	sp,sp,-80
 6d6:	ec06                	sd	ra,24(sp)
 6d8:	e822                	sd	s0,16(sp)
 6da:	1000                	add	s0,sp,32
 6dc:	e010                	sd	a2,0(s0)
 6de:	e414                	sd	a3,8(s0)
 6e0:	e818                	sd	a4,16(s0)
 6e2:	ec1c                	sd	a5,24(s0)
 6e4:	03043023          	sd	a6,32(s0)
 6e8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f0:	8622                	mv	a2,s0
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e16080e7          	jalr	-490(ra) # 508 <vprintf>
}
 6fa:	60e2                	ld	ra,24(sp)
 6fc:	6442                	ld	s0,16(sp)
 6fe:	6161                	add	sp,sp,80
 700:	8082                	ret

0000000000000702 <printf>:

void
printf(const char *fmt, ...)
{
 702:	711d                	add	sp,sp,-96
 704:	ec06                	sd	ra,24(sp)
 706:	e822                	sd	s0,16(sp)
 708:	1000                	add	s0,sp,32
 70a:	e40c                	sd	a1,8(s0)
 70c:	e810                	sd	a2,16(s0)
 70e:	ec14                	sd	a3,24(s0)
 710:	f018                	sd	a4,32(s0)
 712:	f41c                	sd	a5,40(s0)
 714:	03043823          	sd	a6,48(s0)
 718:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	00840613          	add	a2,s0,8
 720:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 724:	85aa                	mv	a1,a0
 726:	4505                	li	a0,1
 728:	00000097          	auipc	ra,0x0
 72c:	de0080e7          	jalr	-544(ra) # 508 <vprintf>
}
 730:	60e2                	ld	ra,24(sp)
 732:	6442                	ld	s0,16(sp)
 734:	6125                	add	sp,sp,96
 736:	8082                	ret

0000000000000738 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 738:	1141                	add	sp,sp,-16
 73a:	e422                	sd	s0,8(sp)
 73c:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 73e:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 742:	00001797          	auipc	a5,0x1
 746:	8be7b783          	ld	a5,-1858(a5) # 1000 <freep>
 74a:	a02d                	j	774 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 74c:	4618                	lw	a4,8(a2)
 74e:	9f2d                	addw	a4,a4,a1
 750:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 754:	6398                	ld	a4,0(a5)
 756:	6310                	ld	a2,0(a4)
 758:	a83d                	j	796 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 75a:	ff852703          	lw	a4,-8(a0)
 75e:	9f31                	addw	a4,a4,a2
 760:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 762:	ff053683          	ld	a3,-16(a0)
 766:	a091                	j	7aa <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 768:	6398                	ld	a4,0(a5)
 76a:	00e7e463          	bltu	a5,a4,772 <free+0x3a>
 76e:	00e6ea63          	bltu	a3,a4,782 <free+0x4a>
{
 772:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 774:	fed7fae3          	bgeu	a5,a3,768 <free+0x30>
 778:	6398                	ld	a4,0(a5)
 77a:	00e6e463          	bltu	a3,a4,782 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77e:	fee7eae3          	bltu	a5,a4,772 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 782:	ff852583          	lw	a1,-8(a0)
 786:	6390                	ld	a2,0(a5)
 788:	02059813          	sll	a6,a1,0x20
 78c:	01c85713          	srl	a4,a6,0x1c
 790:	9736                	add	a4,a4,a3
 792:	fae60de3          	beq	a2,a4,74c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 796:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 79a:	4790                	lw	a2,8(a5)
 79c:	02061593          	sll	a1,a2,0x20
 7a0:	01c5d713          	srl	a4,a1,0x1c
 7a4:	973e                	add	a4,a4,a5
 7a6:	fae68ae3          	beq	a3,a4,75a <free+0x22>
    p->s.ptr = bp->s.ptr;
 7aa:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7ac:	00001717          	auipc	a4,0x1
 7b0:	84f73a23          	sd	a5,-1964(a4) # 1000 <freep>
}
 7b4:	6422                	ld	s0,8(sp)
 7b6:	0141                	add	sp,sp,16
 7b8:	8082                	ret

00000000000007ba <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ba:	7139                	add	sp,sp,-64
 7bc:	fc06                	sd	ra,56(sp)
 7be:	f822                	sd	s0,48(sp)
 7c0:	f426                	sd	s1,40(sp)
 7c2:	ec4e                	sd	s3,24(sp)
 7c4:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c6:	02051493          	sll	s1,a0,0x20
 7ca:	9081                	srl	s1,s1,0x20
 7cc:	04bd                	add	s1,s1,15
 7ce:	8091                	srl	s1,s1,0x4
 7d0:	0014899b          	addw	s3,s1,1
 7d4:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7d6:	00001517          	auipc	a0,0x1
 7da:	82a53503          	ld	a0,-2006(a0) # 1000 <freep>
 7de:	c915                	beqz	a0,812 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e2:	4798                	lw	a4,8(a5)
 7e4:	08977e63          	bgeu	a4,s1,880 <malloc+0xc6>
 7e8:	f04a                	sd	s2,32(sp)
 7ea:	e852                	sd	s4,16(sp)
 7ec:	e456                	sd	s5,8(sp)
 7ee:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7f0:	8a4e                	mv	s4,s3
 7f2:	0009871b          	sext.w	a4,s3
 7f6:	6685                	lui	a3,0x1
 7f8:	00d77363          	bgeu	a4,a3,7fe <malloc+0x44>
 7fc:	6a05                	lui	s4,0x1
 7fe:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 802:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 806:	00000917          	auipc	s2,0x0
 80a:	7fa90913          	add	s2,s2,2042 # 1000 <freep>
  if(p == (char*)-1)
 80e:	5afd                	li	s5,-1
 810:	a091                	j	854 <malloc+0x9a>
 812:	f04a                	sd	s2,32(sp)
 814:	e852                	sd	s4,16(sp)
 816:	e456                	sd	s5,8(sp)
 818:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 81a:	00000797          	auipc	a5,0x0
 81e:	7f678793          	add	a5,a5,2038 # 1010 <base>
 822:	00000717          	auipc	a4,0x0
 826:	7cf73f23          	sd	a5,2014(a4) # 1000 <freep>
 82a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 82c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 830:	b7c1                	j	7f0 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 832:	6398                	ld	a4,0(a5)
 834:	e118                	sd	a4,0(a0)
 836:	a08d                	j	898 <malloc+0xde>
  hp->s.size = nu;
 838:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 83c:	0541                	add	a0,a0,16
 83e:	00000097          	auipc	ra,0x0
 842:	efa080e7          	jalr	-262(ra) # 738 <free>
  return freep;
 846:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 84a:	c13d                	beqz	a0,8b0 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84e:	4798                	lw	a4,8(a5)
 850:	02977463          	bgeu	a4,s1,878 <malloc+0xbe>
    if(p == freep)
 854:	00093703          	ld	a4,0(s2)
 858:	853e                	mv	a0,a5
 85a:	fef719e3          	bne	a4,a5,84c <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 85e:	8552                	mv	a0,s4
 860:	00000097          	auipc	ra,0x0
 864:	bba080e7          	jalr	-1094(ra) # 41a <sbrk>
  if(p == (char*)-1)
 868:	fd5518e3          	bne	a0,s5,838 <malloc+0x7e>
        return 0;
 86c:	4501                	li	a0,0
 86e:	7902                	ld	s2,32(sp)
 870:	6a42                	ld	s4,16(sp)
 872:	6aa2                	ld	s5,8(sp)
 874:	6b02                	ld	s6,0(sp)
 876:	a03d                	j	8a4 <malloc+0xea>
 878:	7902                	ld	s2,32(sp)
 87a:	6a42                	ld	s4,16(sp)
 87c:	6aa2                	ld	s5,8(sp)
 87e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 880:	fae489e3          	beq	s1,a4,832 <malloc+0x78>
        p->s.size -= nunits;
 884:	4137073b          	subw	a4,a4,s3
 888:	c798                	sw	a4,8(a5)
        p += p->s.size;
 88a:	02071693          	sll	a3,a4,0x20
 88e:	01c6d713          	srl	a4,a3,0x1c
 892:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 894:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 898:	00000717          	auipc	a4,0x0
 89c:	76a73423          	sd	a0,1896(a4) # 1000 <freep>
      return (void*)(p + 1);
 8a0:	01078513          	add	a0,a5,16
  }
}
 8a4:	70e2                	ld	ra,56(sp)
 8a6:	7442                	ld	s0,48(sp)
 8a8:	74a2                	ld	s1,40(sp)
 8aa:	69e2                	ld	s3,24(sp)
 8ac:	6121                	add	sp,sp,64
 8ae:	8082                	ret
 8b0:	7902                	ld	s2,32(sp)
 8b2:	6a42                	ld	s4,16(sp)
 8b4:	6aa2                	ld	s5,8(sp)
 8b6:	6b02                	ld	s6,0(sp)
 8b8:	b7f5                	j	8a4 <malloc+0xea>

00000000000008ba <thread_create>:
#include "user/thread.h" 
#include "user/user.h" 
#define PGSIZE 4096

// Create a new thread using the given start_routine and argument.
int thread_create(void *(start_routine)(void*), void *arg) {
 8ba:	1101                	add	sp,sp,-32
 8bc:	ec06                	sd	ra,24(sp)
 8be:	e822                	sd	s0,16(sp)
 8c0:	e426                	sd	s1,8(sp)
 8c2:	e04a                	sd	s2,0(sp)
 8c4:	1000                	add	s0,sp,32
 8c6:	84aa                	mv	s1,a0
 8c8:	892e                	mv	s2,a1
    // Allocate a stack pointer of PGSIZE bytes (4096).
    int ptr_size = PGSIZE * sizeof(void);
    void* st_ptr = (void*)malloc(ptr_size);
 8ca:	6505                	lui	a0,0x1
 8cc:	00000097          	auipc	ra,0x0
 8d0:	eee080e7          	jalr	-274(ra) # 7ba <malloc>
    int tid = clone(st_ptr);
 8d4:	00000097          	auipc	ra,0x0
 8d8:	b5e080e7          	jalr	-1186(ra) # 432 <clone>

    // For the child process, call the start_routine function with the argument.
    if (tid == 0) {
 8dc:	c901                	beqz	a0,8ec <thread_create+0x32>
        exit(0);
    }

    // Return 0 for the parent process.
    return 0;
}
 8de:	4501                	li	a0,0
 8e0:	60e2                	ld	ra,24(sp)
 8e2:	6442                	ld	s0,16(sp)
 8e4:	64a2                	ld	s1,8(sp)
 8e6:	6902                	ld	s2,0(sp)
 8e8:	6105                	add	sp,sp,32
 8ea:	8082                	ret
        (*start_routine)(arg);
 8ec:	854a                	mv	a0,s2
 8ee:	9482                	jalr	s1
        exit(0);
 8f0:	4501                	li	a0,0
 8f2:	00000097          	auipc	ra,0x0
 8f6:	aa0080e7          	jalr	-1376(ra) # 392 <exit>

00000000000008fa <lock_init>:

// Initialize a lock.
void lock_init(struct lock_t* lock) {
 8fa:	1141                	add	sp,sp,-16
 8fc:	e422                	sd	s0,8(sp)
 8fe:	0800                	add	s0,sp,16
    lock->locked = 0;
 900:	00052023          	sw	zero,0(a0) # 1000 <freep>
}
 904:	6422                	ld	s0,8(sp)
 906:	0141                	add	sp,sp,16
 908:	8082                	ret

000000000000090a <lock_acquire>:

// Acquire the lock.
void lock_acquire(struct lock_t* lock) {
 90a:	1141                	add	sp,sp,-16
 90c:	e422                	sd	s0,8(sp)
 90e:	0800                	add	s0,sp,16
    // Spin until the lock is acquired.
    while (__sync_lock_test_and_set(&lock->locked, 1) != 0);
 910:	4705                	li	a4,1
 912:	87ba                	mv	a5,a4
 914:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
 918:	2781                	sext.w	a5,a5
 91a:	ffe5                	bnez	a5,912 <lock_acquire+0x8>
    // Ensure memory operations strictly follow the lock acquisition.
    __sync_synchronize();
 91c:	0ff0000f          	fence
}
 920:	6422                	ld	s0,8(sp)
 922:	0141                	add	sp,sp,16
 924:	8082                	ret

0000000000000926 <lock_release>:

// Release the lock.
void lock_release(struct lock_t* lock) {
 926:	1141                	add	sp,sp,-16
 928:	e422                	sd	s0,8(sp)
 92a:	0800                	add	s0,sp,16
    // Ensure all memory operations in the critical section are visible to other CPUs.
    __sync_synchronize();
 92c:	0ff0000f          	fence
    // Release the lock by setting it to 0.
    __sync_lock_release(&lock->locked, 0);
 930:	0f50000f          	fence	iorw,ow
 934:	0805202f          	amoswap.w	zero,zero,(a0)
}
 938:	6422                	ld	s0,8(sp)
 93a:	0141                	add	sp,sp,16
 93c:	8082                	ret
