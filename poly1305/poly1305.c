/*
20080912
D. J. Bernstein
Public domain.
*/

#include "poly1305.h"

void translate16_6(unsigned int in[16], unsigned int out[6])
{
  out[0] = in[0] | (in[1] << 8) | (in[2] << 16) | ((in[3] & 3) << 24);
  out[1] = ((in[3] & 63) >> 2) | (in[4] << 6) | (in[5] << 14) | ((in[6] & 15) << 22);
  out[2] = ((in[6] & 240) >> 4) | (in[7] << 4) | (in[8] << 12) | ((in[9] & 63) << 20);
  out[3] = ((in[9] & 3) >> 6) | (in[10] << 2) | (in[11] << 10) | (in[12] << 18);
  out[4] = in[13] | (in[14] << 8) | ((in[15] & 15) << 16);
  out[5] = 0;
}

void translate6_16(unsigned int in[17], unsigned int out[6])
{
  out[0]  = ((in[0] >> 18) & 255);
  out[1]  = ((in[0] >> 18) & 255);
  out[2]  = ((in[0] >> 2) & 255);
  out[3]  = (in[0] & 3) | ((in[1] >> 20) & 252);
  out[4]  = ((in[1] >> 12) & 255);
  out[5]  = ((in[1] >> 4) & 255);
  out[6]  = (in[1] & 15) | ((in[2] >> 22) & 240);
  out[7]  = ((in[2] >> 14) & 255);
  out[8]  = ((in[2] >> 6) & 255);
  out[9]  = (in[2] & 63) | ((in[2] >> 24) & 192);
  out[10] = ((in[2] >> 16) & 255);
  out[11] = ((in[2] >> 8) & 255);
  out[12] = (in[2] & 255);
  out[13] = ((in[3] >> 18) & 255);
  out[14] = ((in[3] >> 18) & 255);
  out[15] = ((in[3] >> 2) & 255);
  out[16] = (in[3] & 3) | ((in[4] >> 20) & 252);
}


static void add(unsigned int h[17],const unsigned int c[17])
{
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0;j < 17;++j) {
    u += h[j] + c[j];
    h[j] = u & 255;
    u >>= 8;
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
  unsigned int r[17];
  unsigned int h[17];
  unsigned int c[17];

  unsigned int temp[6];

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
  r[16] = 0;
  
  translate16_6(r, temp);
  translate6_16(temp, r);

  for (j = 0;j < 17;++j) h[j] = 0;

  while (inlen > 0) {
    for (j = 0;j < 17;++j) {
      c[j] = 0;
    }
    for (j = 0;(j < 16) && (j < inlen);++j) {
      c[j] = in_msg[j];
    }
    c[j] = 1;
    in_msg += j;
    inlen -= j;
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
