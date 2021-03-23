/*
20080912
D. J. Bernstein
Public domain.
*/

#include "poly1305.h"
#include "../common/stm32wrapper.h"
#include <stdio.h>

static void add(unsigned int h[6], const unsigned int c[6]) {
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

static const unsigned int minusp[6] = {
  5, 0, 0, 0, 0, 0b11111111111111111111111111
} ;

static void freeze(unsigned int h[6])
{
  unsigned int horig[6];
  unsigned int j;
  unsigned int negative;
  for (j = 0;j < 6;++j) {
    horig[j] = h[j];
  }
  add(h,minusp);
  negative = -(h[6] >> 25);
  for (j = 0;j < 6;++j) {
    h[j] ^= negative & (horig[j] ^ h[j]);
  }
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

static void mulmod_6(unsigned int h[6],const unsigned int r[6])
{
  unsigned int h_17[17], r_17[17], hr_17[17];
  
  unsigned int hr[6];
  unsigned int i;
  unsigned int j;
  unsigned int u;
  
  translate6_17(h, h_17);
  translate6_17(r, r_17);
  for (i = 0;i < 17;++i) {
    u = 0;
    for (j = 0;j <= i;++j) {
      u += h_17[j] * r_17[i - j];
    }
    for (j = i + 1;j < 17;++j) {
      u += 320 * h_17[j] * r_17[i + 17 - j];
    }
    hr_17[i] = u;
  } 
  translate17_6(hr_17, hr);
  translate17_6(r_17, r);/*
  for (i = 0;i < 6;++i) {
    u = 0;
    for (j = 0;j <= i;++j) {
      u += h[j] * r[i - j];
    }
    for (j = i + 1;j < 6;++j) {
      u += 5 * h[j] * r[i + 6 - j];
    }
    hr[i] = u;
  }*/  
  
  for (i = 0;i < 6;++i) {
    h[i] = hr[i];
  }
  squeeze_6(h);
}

static void load_input_block(unsigned int c_6[6], unsigned long long inlen, const unsigned char *in_msg) {
    unsigned int j;
    for (j = 0;j < 6;++j) c_6[j] = 0;

    // copy input block
    if (inlen >= 16) c_6[4] |= (1 << 24);
    if (inlen == 15) c_6[4] |= 1 << 16; else if (inlen > 15) c_6[4] |= in_msg[15] << 16;
    if (inlen == 14) c_6[4] |= 1 << 8;  else if (inlen > 14) c_6[4] |= in_msg[14] << 8;
    if (inlen == 13) c_6[4] |= 1;       else if (inlen > 13) c_6[4] |= in_msg[13];
    if (inlen == 12) c_6[3] |= 1 << 18; else if (inlen > 12) c_6[3] |= in_msg[12] << 18;
    if (inlen == 11) c_6[3] |= 1 << 10; else if (inlen > 11) c_6[3] |= in_msg[11] << 10;
    if (inlen == 10) c_6[3] |= 1 << 2;  else if (inlen > 10) c_6[3] |= in_msg[10] << 2;
    if (inlen == 9) {
        c_6[2] |= 1 << 20;
    } else if (inlen > 9) {
        c_6[3] |= (in_msg[9] & 0b11000000) >> 6;
        c_6[2] |= (in_msg[9] & 0b00111111) << 20;
    }
    if (inlen == 8) c_6[2] |= 1 << 12; else if (inlen > 8) c_6[2] |= in_msg[8] << 12;
    if (inlen == 7) c_6[2] |= 1 << 4;  else if (inlen > 7) c_6[2] |= in_msg[7] << 4;
    if (inlen == 6) {
        c_6[1] |= 1 << 22;
    } else if (inlen > 6) {
        c_6[2] |= (in_msg[6] & 0b11110000) >> 4;
        c_6[1] |= (in_msg[6] & 0b00001111) << 22;
    }
    if (inlen == 5) c_6[1] |= 1 << 14; else if (inlen > 5) c_6[1] |= in_msg[5] << 14;
    if (inlen == 4) c_6[1] |= 1 << 6;  else if (inlen > 4) c_6[1] |= in_msg[4] << 6;
    if (inlen == 3) {
        c_6[0] |= 1 << 24;
    } else if (inlen > 3) {
        c_6[1] |= (in_msg[3] & 0b11111100) >> 2;
        c_6[0] |= (in_msg[3] & 0b00000011) << 24;
    }
    if (inlen == 2) c_6[0] |= 1 << 16; else if (inlen > 2) c_6[0] |= in_msg[2] << 16;
    if (inlen == 1) c_6[0] |= 1 << 8; else if (inlen > 1) c_6[0] |= in_msg[1] << 8;
    c_6[0] |= in_msg[0]; 
}

int crypto_onetimeauth_poly1305(unsigned char *out_mac,const unsigned char *in_msg,unsigned long long inlen,const unsigned char *key)
{
  unsigned int j;
  unsigned int c[6], h[6], r[6];
  
  r[0] = ((key[0]  & 0b11111111) >> 0) | (key[1] << 8)         | (key[2] << 16)         | ((key[3]  & 0b00000011) << 24);
  r[1] = ((key[3]  & 0b00001100) >> 2) | ((key[4] & 252) << 6) | (key[5] << 14)         | ((key[6]  & 0b00001111) << 22);
  r[2] = ((key[6]  & 0b11110000) >> 4) | ((key[7] &  15) << 4) | ((key[8] & 252) << 12) | ((key[9]  & 0b00111111) << 20);
  r[3] = ((key[9]  & 0b11000000) >> 6) | (key[10] << 2)        | ((key[11] & 15) << 10) | ((key[12] & 252) << 18);
  r[4] = ((key[13] & 0b11111111) >> 0) | (key[14] << 8)        | ((key[15] & 15) << 16);
  r[5] = 0;

  for (j = 0;j < 6;++j) h[j] = 0;

  while (inlen > 0) {
    load_input_block(c, inlen, in_msg); 
    j = 16; if (inlen < j) j = inlen;
    in_msg += j;
    inlen -= j;

    add(h, c);
    mulmod_6(h,r);
  }

  
  freeze(h);
  
  c[0] = ((key[16] & 0b11111111) >> 0) | (key[17] << 8) | (key[18] << 16) | ((key[19]  & 0b00000011) << 24);
  c[1] = ((key[19] & 0b11111100) >> 2) | (key[20] << 6) | (key[21] << 14) | ((key[22]  & 0b00001111) << 22);
  c[2] = ((key[22] & 0b11110000) >> 4) | (key[23] << 4) | (key[24] << 12) | ((key[25]  & 0b00111111) << 20);
  c[3] = ((key[25] & 0b11000000) >> 6) | (key[26] << 2) | (key[27] << 10) | (key[28] << 18);
  c[4] = ((key[29] & 0b11111111) >> 0) | (key[30] << 8) | (key[31] << 16);
  c[5] = 0;
  
  add(h,c);
  
  out_mac[0]  = h[0] & 0xff;                                           // 0b00000000000000000011111111
  out_mac[1]  = (h[0]  >> 8)   & 0xff;                                 // 0b00000000001111111100000000
  out_mac[2]  = (h[0]  >> 16)  & 0xff;                                 // 0b00111111110000000000000000
  out_mac[3]  = ((h[0] >> 24)  & 0x03) | ((h[1] << 2) & 0b11111100);  // 0b11000000000000000000000000 and 0b00000000000000000000111111 
  out_mac[4]  = (h[1]  >> 6)   & 0xff;                                 // 0b00000000000011111111000000
  out_mac[5]  = (h[1]  >> 14)  & 0xff;                                 // 0b00001111111100000000000000
  out_mac[6]  = ((h[1] >> 22)  & 0x0f) | ((h[2] << 4) & 0b11110000);  // 0b11110000000000000000000000 and 0b00000000000000000000001111 
  out_mac[7]  = (h[2]  >> 4)   & 0xff;
  out_mac[8]  = (h[2]  >> 12)  & 0xff;
  out_mac[9]  = ((h[2] >> 20)  & 0x3f) | ((h[3] << 6) & 0b11000000);  // 0b11111100000000000000000000 and 0b00000000000000000000000011
  out_mac[10] = (h[3]  >> 2)   & 0xff;
  out_mac[11] = (h[3]  >> 10)  & 0xff;
  out_mac[12] = (h[3]  >> 18)  & 0xff;
  out_mac[13] = h[4] & 0xff;                                           // 0b00000000000000000011111111
  out_mac[14] = (h[4]  >> 8)   & 0xff;                                 // 0b00000000001111111100000000
  out_mac[15] = (h[4]  >> 16)  & 0xff;                                 // 0b00111111110000000000000000
  return 0;
}
