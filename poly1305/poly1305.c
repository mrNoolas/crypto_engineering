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
    h[j] = u & 255;
    u >>= 8;
  }
}

static void add_6(unsigned int h[6], const unsigned int c[6]) {
  unsigned int u;
  u = 0;
  for (unsigned int j = 0; j < 6; j++) { // TODO: is ++j faster?
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

static void squeeze_6(unsigned int h[6]) {
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

void translate17_6(unsigned int in[17], unsigned int out[6])
{
  squeeze(in);
  out[0] = ((in[0]  & 0b11111111) >> 0) | (in[1] << 8)  | (in[2] << 16)  | ((in[3]  & 0b00000011) << 24);
  out[1] = ((in[3]  & 0b11111100) >> 2) | (in[4] << 6)  | (in[5] << 14)  | ((in[6]  & 0b00001111) << 22);
  out[2] = ((in[6]  & 0b11110000) >> 4) | (in[7] << 4)  | (in[8] << 12)  | ((in[9]  & 0b00111111) << 20);
  out[3] = ((in[9]  & 0b11000000) >> 6) | (in[10] << 2) | (in[11] << 10) | ((in[12] & 0b11111111) << 18);
  out[4] = ((in[13] & 0b11111111) >> 0) | (in[14] << 8) | (in[15] << 16) | ((in[16] & 0b00000011) << 24);
  out[5] = (in[16] >> 2); // should be 0 after squeeze?
}

void translate6_17(unsigned int in[6], unsigned int out[17]) 
{ 
  squeeze_6(in);
  // 0b11 1111 1111  1111 1111  1111 1111
  out[0]  = in[0] & 0xff;           // 0b00000000000000000011111111
  out[1]  = (in[0]  >> 8)   & 0xff; // 0b00000000001111111100000000
  out[2]  = (in[0]  >> 16)  & 0xff; // 0b00111111110000000000000000
  out[3]  = ((in[0] >> 24)  & 0x03) | ((in[1] << 2) & 0b11111100); // 0b11000000000000000000000000 and 0b00000000000000000000111111 
  out[4]  = (in[1]  >> 6)   & 0xff; // 0b00000000000011111111000000
  out[5]  = (in[1]  >> 14)  & 0xff; // 0b00001111111100000000000000
  out[6]  = ((in[1] >> 22)  & 0x0f) | ((in[2] << 4) & 0b11110000); // 0b11110000000000000000000000 and 0b00000000000000000000001111 
  out[7]  = (in[2]  >> 4)   & 0xff;
  out[8]  = (in[2]  >> 12)  & 0xff;
  out[9]  = ((in[2] >> 20)  & 0x3f) | ((in[3] << 6) & 0b11000000); // 0b11111100000000000000000000 and 0b00000000000000000000000011
  out[10] = (in[3]  >> 2)   & 0xff;
  out[11] = (in[3]  >> 10)  & 0xff;
  out[12] = (in[3]  >> 18)  & 0xff;
  out[13] = in[4] & 0xff;           // 0b00000000000000000011111111
  out[14] = (in[4]  >> 8)   & 0xff; // 0b00000000001111111100000000
  out[15] = (in[4]  >> 16)  & 0xff; // 0b00111111110000000000000000
  out[16] = (in[4]  >> 24)  & 0x03; 
  out[16] = out[16] | (in[5] << 2); // TODO: is it better to remove this? (see todo hereafter)
   
  // TODO: is this necessary? (see todo before this one)
  // squeeze again :), now 17 (quicksqueeze)
  unsigned int u = 5 * in[5];
  for (unsigned int j = 0; j < 16; j++) {
    u += out[j];
    out[j] = u & 255;
    u >>= 8;
  }
  u += out[16];
  out[16] = u;
  //*/
}

int crypto_onetimeauth_poly1305(unsigned char *out_mac,const unsigned char *in_msg,unsigned long long inlen,const unsigned char *key)
{
  unsigned int j;
  unsigned int r[17];
  unsigned int h[17];
  unsigned int c[17];

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

    //add(h,c);
    unsigned int c_6[6], h_6[6];
    translate17_6(h, c_6);
    translate17_6(c, h_6);
    add_6(h_6, c_6);
    translate6_17(h_6, h);

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
