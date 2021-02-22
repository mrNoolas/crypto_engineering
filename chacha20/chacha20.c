/* Based on the public domain implemntation in
 * crypto_stream/chacha20/e/ref from http://bench.cr.yp.to/supercop.html
 * by Daniel J. Bernstein */

#include <stdint.h>
#include "chacha20.h"
#include "../common/stm32wrapper.h"

#define ROUNDS 20

typedef uint32_t uint32;

extern uint32 cryptocore(
        unsigned char *out,
  const unsigned char *in,
  const unsigned char *key,
  const unsigned char *c
  //	uint32 *x
);

static uint32 load_littleendian(const unsigned char *x)
{
  return
      (uint32) (x[0]) \
  | (((uint32) (x[1])) << 8) \
  | (((uint32) (x[2])) << 16) \
  | (((uint32) (x[3])) << 24);
}

static void store_littleendian(unsigned char *x,uint32 u)
{
  x[0] = u; u >>= 8;
  x[1] = u; u >>= 8;
  x[2] = u; u >>= 8;
  x[3] = u;
}

static int crypto_core_chacha20(
        unsigned char *out,
  const unsigned char *in,
  const unsigned char *key,
  const unsigned char *c
)
{

  uint32 j0, j1, j2, j3, j4, j5, j6, j7, j8, j9, j10, j11, j12, j13, j14, j15;

  j0  = load_littleendian(c +  0);
  j1  = load_littleendian(c +  4);
  j2  = load_littleendian(c +  8);
  j3  = load_littleendian(c + 12);
  j4  = load_littleendian(key +  0);
  j5  = load_littleendian(key +  4);
  j6  = load_littleendian(key +  8);
  j7  = load_littleendian(key + 12);
  j8  = load_littleendian(key + 16);
  j9  = load_littleendian(key + 20);
  j10 = load_littleendian(key + 24);
  j11 = load_littleendian(key + 28);
  j12 = load_littleendian(in +  8);
  j13 = load_littleendian(in + 12);
  j14 = load_littleendian(in +  0);
  j15 = load_littleendian(in +  4);

  // uint32 x[16];
  uint32 *x = cryptocore(out, in, key, c); //, x);

  x[0] += j0;
  x[1] += j1;
  x[2] += j2;
  x[3] += j3;
  x[4] += j4;
  x[5] += j5;
  x[6] += j6;
  x[7] += j7;
  x[8] += j8;
  x[9] += j9;
  x[10] += j10;
  x[11] += j11;
  x[12] += j12;
  x[13] += j13;
  x[14] += j14;
  x[15] += j15;

  store_littleendian(out + 0,x[0]);
  store_littleendian(out + 4,x[1]);
  store_littleendian(out + 8,x[2]);
  store_littleendian(out + 12,x[3]);
  store_littleendian(out + 16,x[4]);
  store_littleendian(out + 20,x[5]);
  store_littleendian(out + 24,x[6]);
  store_littleendian(out + 28,x[7]);
  store_littleendian(out + 32,x[8]);
  store_littleendian(out + 36,x[9]);
  store_littleendian(out + 40,x[10]);
  store_littleendian(out + 44,x[11]);
  store_littleendian(out + 48,x[12]);
  store_littleendian(out + 52,x[13]);
  store_littleendian(out + 56,x[14]);
  store_littleendian(out + 60,x[15]);
  

  return 0;
}

static const unsigned char sigma[16] = "expand 32-byte k";

int crypto_stream_chacha20(unsigned char *out, unsigned long long outLen, const unsigned char *nonce, const unsigned char *key)
{
/* testing code
  uint32 p[4];
  p[0] = 1;
  p[1] = 2;
  p[2] = 3;
  p[3] = 4;
  unsigned char blob[5] = {p[0] + '0', p[1] + '0',  p[2] + '0', p[3] + '0', '\0'};
  send_USART_str(blob);

  quarterround(&p);

  unsigned char blob1[5] = {p[0] + '0', p[1] + '0',  p[2] + '0', p[3] + '0', '\0'};
  send_USART_str(blob1);
 //*/ 

  unsigned char in[16];
  unsigned char block[64];
  unsigned char keyCopy[32];
  unsigned long long i;
  unsigned int u;

  if (!outLen) return 0;

  for (i = 0; i < 32; ++i) keyCopy[i] = key[i];
  for (i = 0; i < 8; ++i) in[i] = nonce[i];
  for (i = 8; i < 16; ++i) in[i] = 0;

    /*
    unsigned char r = cryptocore(out, in, keyCopy, sigma);
    unsigned char b[2] = {r, '\0'};
    send_USART_str(b); //*/

  while (outLen >= 64) {
    //*
    unsigned char r = crypto_core_chacha20(out, in, keyCopy, sigma);
    unsigned char b[2] = {r, '\0'};
    send_USART_str(b); //*/
    //cryptocore(out, in, keyCopy, sigma);

    u = 1;
    for (i = 8; i < 16; ++i) {
      u += (unsigned int) in[i];
      in[i] = u;
      u >>= 8;
    }

    outLen -= 64;
    out += 64;
  }

  if (outLen) {
    crypto_core_chacha20(block, in, keyCopy, sigma);
    for (i = 0; i < outLen; ++i) out[i] = block[i];
  }
  return 0;
}
