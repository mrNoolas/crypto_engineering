/*
20080912
D. J. Bernstein
Public domain.
*/

#include "poly1305.h"

static void add(unsigned int h[17],const unsigned int c[17])
{
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0;j < 17;++j) {
    u += h[j] + c[j];
    h[j] = u & 67108863;
    u >>= 26;
  }
}

static void squeeze(unsigned int h[17])
{
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0;j < 16;++j) {
    u += h[j];
    h[j] = u & 255;
    u >>= 8;
  }
  u += h[16];
  h[16] = u & 3;
  u = 5 * (u >> 2);
  for (j = 0;j < 16;++j) {
    u += h[j];
    h[j] = u & 255;
    u >>= 8;
  }
  u += h[16];
  h[16] = u;
}

static const unsigned int minusp[17] = {
  5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 252
} ;

static void freeze(unsigned int h[17])
{
  unsigned int horig[17];
  unsigned int j;
  unsigned int negative;
  for (j = 0;j < 17;++j) {
    horig[j] = h[j];
  }
  add(h,minusp);
  negative = -(h[16] >> 7);
  for (j = 0;j < 17;++j) {
    h[j] ^= negative & (horig[j] ^ h[j]);
  }
}

static void mulmod(unsigned int h[17],const unsigned int r[17])
{
  unsigned int hr[17];
  unsigned int i;
  unsigned int j;
  unsigned int u;

  for (i = 0;i < 17;++i) {
    u = 0;
    for (j = 0;j <= i;++j) {
      u += h[j] * r[i - j];
    }
    for (j = i + 1;j < 17;++j) {
      u += 320 * h[j] * r[i + 17 - j];
    }
    hr[i] = u;
  }
  for (i = 0;i < 17;++i) {
    h[i] = hr[i];
  }
  squeeze(h);
}

int crypto_onetimeauth_poly1305(unsigned char *out_mac,const unsigned char *in_msg,unsigned long long inlen,const unsigned char *key)
{
  unsigned int j;
  unsigned int r[5];
  unsigned int h[5]; 
  unsigned int c[5]; // current operating block
  
  r[0] = key[0] | (key[1] << 8) | (key[2] << 16) | ((key[3] & 3) << 24)
  // key[3] & 15; key[4] & 252;
  r[1] = ((key[3] & 12) >> 2) | ((key[4] & 252) << 6) | (key[5] << 14) | ((key[6] & 15) << 22)
  r[2] = ((key[6] & 240) >> 4) | ((key[7] & 15) << 4) | ((key[8] & 252) << 12) | ((key[9] & 63) << 20)
  r[3] = ((key[9] & 3) >> 6) | (key[10] << 2) | ((key[11] & 15) << 10) | ((key[12] & 252) << 18)
  r[4] = key[13] | (key[14] << 8) | ((key[15] & 15) << 16)
  r[5] = 0
  
/*
  r[0] = key[0];
  r[1] = key[1];
  r[2] = key[2];
  r[3] = key[3] & 15;
  r[4] = key[4] & 252;
  r[5] = key[5];
  r[6] = key[6];
  r[7] = key[7] & 15;
  r[8] = key[8] & 252;
  r[9] = key[9];
  r[10] = key[10];
  r[11] = key[11] & 15;
  r[12] = key[12] & 252;
  r[13] = key[13];
  r[14] = key[14];
  r[15] = key[15] & 15;
  r[16] = 0;*/

  for (j = 0;j < 5;++j) h[j] = 0;

  while (inlen > 0) {
    // reset c
    for (j = 0;j < 5;++j) {
      c[j] = 0;
    }
    
    // copy input block
    c[0] = key[0] | (key[1] << 8) | (key[2] << 16) | ((key[3] & 3) << 24)
    c[1] = ((key[3] & 252) >> 2) | (key[4] << 6) | (key[5] << 14) | ((key[6] & 15) << 22)
    c[2] = ((key[6] & 240) >> 4) | (key[7] << 4) | (key[8] << 12) | ((key[9] & 63) << 20)
    c[3] = ((key[9] & 3) >> 6) | (key[10] << 2) | (key[11] << 10) | (key[12] << 18)
    c[4] = key[13] | (key[14] << 8) | (key[15] << 16)
    /*
    for (j = 0;(j < 16) && (j < inlen);++j) {
      c[j] = in_msg[j];
    }*/
    
    c[j] = 1;
    in_msg += j;
    inlen -= j;
    
    // Calculate next round
    add(h,c);
    mulmod(h,r);
  }

  freeze(h);

  for (j = 0;j < 16;++j) {
    c[j] = key[j + 16];
  }
  c[16] = 0;
  add(h,c);
  for (j = 0;j < 16;++j) {
    out_mac[j] = h[j];
  }
  return 0;
}
