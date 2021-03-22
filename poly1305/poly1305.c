/*
20080912
D. J. Bernstein
Public domain.
*/

#include "poly1305.h"

void translate17_6(unsigned int in[17], unsigned int out[6])
{
  squeeze(in);
  // TODO: look at shifts
  out[0] = in[0] | (in[1] << 8) | (in[2] << 16) | ((in[3] << 24) & 3);
  out[1] = ((in[3] & 63) >> 2) | (in[4] << 6) | (in[5] << 14) | ((in[6] << 22) & 15);
  out[2] = ((in[6] & 240) >> 4) | (in[7] << 4) | (in[8] << 12) | ((in[9] << 20) & 63);
  out[3] = ((in[9] & 3) >> 6) | (in[10] << 2) | (in[11] << 10) | (in[12] << 18);
  out[4] = in[13] | (in[14] << 8) | ((in[15] & 15) << 16) | ((in[16] << 24) & 3);
  out[5] = (in[16] >> 2) & 252;
}

void translate6_17(unsigned int out[17], unsigned int in[6]) 
{ 
  // squeeze 6
    unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0; j < 5; ++j) {
    u += h[j];
    h[j] = u & 67108863;
    u >>= 26;
  }
  u += h[5];
  h[5] = 0;
  u *= 5;
  for (j = 0;j < 5;++j) {
    u += h[j];
    h[j] = u & 67108863;
    u >>= 26;
  }
  u += h[5];
  h[5] = u;
  
  out[0]  = in[0] & 255;
  out[1]  = (in[0] >> 8) & 255;
  out[2]  = (in[0] >> 16) & 255;
  out[3]  = ((in[0] >> 24) & 3) | ((in[1] << 2) & 0b11111100);
  out[4]  = (in[1] >> 6) & 255;
  out[5]  = (in[1] >> 14) & 255;
  out[6]  = ((in[1] >> 22) & 15) | ((in[2] << 4) & 0b11110000);
  out[7]  = (in[2] >> 4) & 255;
  out[8]  = (in[2] >> 12) & 255;
  out[9]  = ((in[2] >> 20) & 15) | ((in[3] << 6) & 0b11000000);
  out[10] = (in[3] >> 2) & 255;
  out[11] = (in[3] >> 10) & 255;
  out[12] = (in[3] >> 18) & 255;
  out[13] = in[4] & 255;
  out[14] = (in[4] >> 8) & 255;
  out[15] = (in[4] >> 16) & 255;
  out[16] = (in[4] >> 24) & 3;
  
  // squeeze again :), now 17
  unsigned int j;
  unsigned int u;
  u = 5 * in[5];
  for (j = 0;j < 16;++j) {
    u += h[j];
    h[j] = u & 255;
    u >>= 8;
  }
  u += h[16];
  h[16] = u;
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

  // https://crypto.stackexchange.com/questions/68222/how-does-the-squeeze-function-in-the-nacl-poly1305-implementation-work
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
  
  translate17_6(r, temp);
  translate6_17(temp, r);

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
