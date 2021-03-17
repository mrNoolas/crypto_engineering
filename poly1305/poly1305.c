/*
20080912
D. J. Bernstein
Public domain.
*/

#include "poly1305.h"

static void add(unsigned int h[6],const unsigned int c[6])
{
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0;j < 6;++j) {
    u += h[j] + c[j];
    h[j] = u & 67108863;
    u >>= 26;
  }
}

static void squeeze(unsigned int h[6])
{
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0;j < 5;++j) {
    u += h[j];
    h[j] = u & 67108863;
    u >>= 26;
  }
  u += h[5];
  h[5] = 0; // u & 0; // mod 2^130
  u = 5 * (u >> 2);
  for (j = 0;j < 5;++j) {
    u += h[j];
    h[j] = u & 67108863;
    u >>= 26;
  }
  u += h[5]; // u += 0?
  h[5] = u;
}

/*static const unsigned int minusp[17] = {
  5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 252
} ;*/
static const unsigned int minusp[6] = {
  5, 0, 0, 0, 0, 0xffff
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

static void mulmod(unsigned int h[6],const unsigned int r[6])
{
  unsigned int hr[6];
  unsigned int i;
  unsigned int j;
  unsigned int u;

  for (i = 0;i < 6;++i) {
    u = 0;
    for (j = 0;j <= i;++j) {
      u += h[j] * r[i - j];
    }
    for (j = i + 1;j < 6;++j) {
      u += 335544320 * h[j] * r[i + 6 - j];
    }
    hr[i] = u;
  }
  for (i = 0;i < 6;++i) {
    h[i] = hr[i];
  }
  squeeze(h);
}

int crypto_onetimeauth_poly1305(unsigned char *out_mac,const unsigned char *in_msg,unsigned long long inlen,const unsigned char *key)
{
  unsigned int j;
  unsigned int r[6];
  unsigned int h[6]; 
  unsigned int c[6]; // current operating block
  
  r[0] = key[0] | (key[1] << 8) | (key[2] << 16) | ((key[3] & 3) << 24);
  // key[3] & 15; key[4] & 252;
  r[1] = ((key[3] & 12) >> 2) | ((key[4] & 252) << 6) | (key[5] << 14) | ((key[6] & 15) << 22);
  r[2] = ((key[6] & 240) >> 4) | ((key[7] & 15) << 4) | ((key[8] & 252) << 12) | ((key[9] & 63) << 20);
  r[3] = ((key[9] & 3) >> 6) | (key[10] << 2) | ((key[11] & 15) << 10) | ((key[12] & 252) << 18);
  r[4] = key[13] | (key[14] << 8) | ((key[15] & 15) << 16);
  r[5] = 0;
  
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

  for (j = 0;j < 6;++j) h[j] = 0;

  while (inlen > 0) {
    // reset c
    for (j = 0;j < 6;++j) {
      c[j] = 0;
    }
    
    // copy input block
    switch(inlen){
        case 16:
            c[4] =(in_msg[15] << 16);
        case 15:
            c[4] |= in_msg[13];
        case 14:
            c[4] |= (in_msg[14] << 8) ;
        case 13:
            c[3] |= (in_msg[12] << 18);
        case 12:
            c[3] |= (in_msg[11] << 10);
        case 11:
            c[3] |= (in_msg[10] << 2);
        case 10:
            c[3] |= ((in_msg[9] & 3) >> 6);
            c[2] |= ((in_msg[9] & 63) << 20);
        case 9:
            c[2] |= (in_msg[8] << 12);
        case 8:
            c[2] |= (in_msg[7] << 4);
        case 7:
            c[2] |= ((in_msg[6] & 240) >> 4);
            c[1] |= ((in_msg[6] & 15) << 22);
        case 6:
            c[1] |= (in_msg[5] << 14);
        case 5:
            c[1] |= (in_msg[4] << 6);
        case 4:
            c[1] |= ((in_msg[3] & 252) >> 2);
            c[0] |= ((in_msg[3] & 3) << 24);
        case 3:
            c[0] |= (in_msg[2] << 16);
        case 2:
            c[0] |= (in_msg[1] << 8);
        case 1:
            c[0] |= in_msg[0];        
    }
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

  // add last part of key
  c[0] = key[16] | (key[17] << 8) | (key[18] << 16) | ((key[19] & 3) << 24);
  c[1] = ((key[19] & 252) >> 2) | (key[20] << 6) | (key[21] << 14) | ((key[22] & 15) << 22);
  c[2] = ((key[22] & 240) >> 4) | (key[23] << 4) | (key[24] << 12) | ((key[25] & 63) << 20);
  c[3] = ((key[25] & 3) >> 6) | (key[26] << 2) | (key[27] << 10) | (key[28] << 18);
  c[4] = (key[29] | (key[30] << 8) | (key[31] << 16)) & 0x0fff;
  c[5] = 0;
  /*for (j = 0;j < 16;++j) {
    c[j] = key[j + 16];
  }*/
  
  add(h,c);
  /*
  for (j = 0;j < 16;++j) {
    out_mac[j] = h[j];
  }*/
  out_mac[0] = h[0] & 255;
  out_mac[1] = (h[0] >> 8) & 255;
  out_mac[2] = (h[0] >> 16) & 255;
  out_mac[3] = ((h[0] >> 24) | (h[1] << 2)) & 255;
  out_mac[4] = (h[1] >> 6) & 255;
  out_mac[5] = (h[1] >> 14) & 255;
  out_mac[6] = ((h[1] >> 22) | (h[2] << 4)) & 255;
  out_mac[7] = (h[2] >> 4) & 255;
  out_mac[8] = (h[2] >> 12) & 255;
  out_mac[9] = ((h[2] >> 20) | (h[3] << 6)) & 255;
  out_mac[10] = (h[3] >> 2) & 255;
  out_mac[11] = (h[3] >> 10) & 255;
  out_mac[12] = (h[3] >> 18) & 255;
  out_mac[13] = h[4] & 255;
  out_mac[14] = (h[4] >> 8) & 255;
  out_mac[15] = (h[4] >> 16) & 255;
  
  return 0;
}
