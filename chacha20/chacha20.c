/* Based on the public domain implemntation in
 * crypto_stream/chacha20/e/ref from http://bench.cr.yp.to/supercop.html
 * by Daniel J. Bernstein */

#include <stdint.h>
#include "chacha20.h"
//#include "../common/stm32wrapper.h"

//#define ROUNDS 20

typedef uint32_t uint32;

extern uint32 cryptocore(
        unsigned char *out,
  const unsigned char *in,
  const unsigned char *key,
  const unsigned char *c
);

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
    /*
    unsigned char r = cryptocore(out, in, keyCopy, sigma);
    unsigned char b[2] = {r, '\0'};
    send_USART_str(b); //*/
    cryptocore(out, in, keyCopy, sigma);

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
    cryptocore(block, in, keyCopy, sigma);
    for (i = 0; i < outLen; ++i) out[i] = block[i];
  }
  return 0;
}
