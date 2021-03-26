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
  for (unsigned int j = 0; j < 6; j++) {
    u += h[j] + c[j];
    h[j] = u & 67108863;
    u >>= 26;
  }
}

static void squeeze(unsigned int h[6]) {
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0; j < 5; ++j) {
    u += h[j];
    h[j] = u & 67108863;
    u >>= 26;
  }
  u += h[5];
  u *= 5;
  h[5] = 0;
  for (j = 0;j < 5;++j) {
    u += h[j];
    h[j] = u & 67108863;
    u >>= 26;
  }
  u += h[5];
  h[5] = u;
}

/*
void translate17_6(unsigned int in[17], unsigned int out[6])
{
  squeeze(in);
  out[0] = ((in[0]  & 0b11111111) >> 0) | (in[1] << 8)  | (in[2] << 16)  | ((in[3]  & 0b00000011) << 24);
  out[1] = ((in[3]  & 0b11111100) >> 2) | (in[4] << 6)  | (in[5] << 14)  | ((in[6]  & 0b00001111) << 22);
  out[2] = ((in[6]  & 0b11110000) >> 4) | (in[7] << 4)  | (in[8] << 12)  | ((in[9]  & 0b00111111) << 20);
  out[3] = ((in[9]  & 0b11000000) >> 6) | (in[10] << 2) | (in[11] << 10) | ((in[12] & 0b11111111) << 18);
  out[4] = ((in[13] & 0b11111111) >> 0) | (in[14] << 8) | (in[15] << 16) | ((in[16] & 0b00000011) << 24);
  out[5] = 0;
}

void translate6_17(unsigned int in[6], unsigned int out[17]) 
{ 
  squeeze(in);
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
}*/

static void mulmod(unsigned int h[6],const unsigned int r[6]) {
    unsigned long long hr[6];
    
    squeeze(h);
    hr[0] = (unsigned long long) h[0]*r[0] + (unsigned long long) h[1]*r[4]*5 + (unsigned long long) h[2]*r[3]*5 
                + (unsigned long long) h[3]*r[2]*5 + (unsigned long long) h[4]*r[1]*5;
    hr[1] = (unsigned long long) h[0]*r[1] + (unsigned long long) h[1]*r[0]   + (unsigned long long) h[2]*r[4]*5 
                + (unsigned long long) h[3]*r[3]*5 + (unsigned long long) h[4]*r[2]*5;
    hr[2] = (unsigned long long) h[0]*r[2] + (unsigned long long) h[1]*r[1]   + (unsigned long long) h[2]*r[0]   
                + (unsigned long long) h[3]*r[4]*5 + (unsigned long long) h[4]*r[3]*5;
    hr[3] = (unsigned long long) h[0]*r[3] + (unsigned long long) h[1]*r[2]   + (unsigned long long) h[2]*r[1]   
                + (unsigned long long) h[3]*r[0]   + (unsigned long long) h[4]*r[4]*5;
    hr[4] = (unsigned long long) h[0]*r[4] + (unsigned long long) h[1]*r[3]   + (unsigned long long) h[2]*r[2]   
                + (unsigned long long) h[3]*r[1]   + (unsigned long long) h[4]*r[0]  ;
    hr[5] = 0;
    
    // squeeze 64 bit and write to h
    unsigned int j;
    unsigned long long u;
    u = 0;
    for (j = 0; j < 5; ++j) {
        u += hr[j];
        h[j] = u & 67108863;
        u >>= 26;
    }
    u += hr[5];
    u *= 5;
    h[5] = 0;
    for (j = 0;j < 5;++j) {
        u += h[j];
        h[j] = u & 67108863;
        u >>= 26;
    }
    h[5] += u;
}

static const unsigned int minusp[6] = {5, 0, 0, 0, 0, 0xffffffff} ;

int crypto_onetimeauth_poly1305(unsigned char *out_mac,const unsigned char *in_msg,unsigned long long inlen,const unsigned char *key)
{
  unsigned int c[6], h[6], r[6];
  
  r[0] =  key[0]                       | (key[1] << 8)         | (key[2] << 16)         | ((key[3]  & 0b00000011) << 24);
  r[1] = ((key[3]  & 0b00001100) >> 2) | ((key[4] & 252) << 6) | (key[5] << 14)         | ((key[6]  & 0b00001111) << 22);
  r[2] = ((key[6]  & 0b11110000) >> 4) | ((key[7] &  15) << 4) | ((key[8] & 252) << 12) | ((key[9]  & 0b00111111) << 20);
  r[3] = ((key[9]  & 0b11000000) >> 6) | (key[10] << 2)        | ((key[11] & 15) << 10) | ((key[12] & 252) << 18);
  r[4] =  key[13]                      | (key[14] << 8)        | ((key[15] & 15) << 16);
  r[5] = 0;

  h[0] = 0; h[1] = 0; h[2] = 0; h[3] = 0; h[4] = 0; h[5] = 0;

  while (inlen > 0) {
    // copy input block
    c[0] = in_msg[0]; c[1] = 0; c[2] = 0; c[3] = 0; c[4] = 0; c[5] = 0; // reset c
    if (inlen >= 16) { // most common case
        c[0] |= in_msg[1] << 8 | in_msg[2] << 16 | (in_msg[3] & 0b00000011) << 24;
        c[1] =  in_msg[3] >> 2 | in_msg[4] << 6  | in_msg[5] << 14  | (in_msg[6] & 0b00001111) << 22;
        c[2] =  in_msg[6] >> 4 | in_msg[7] << 4  | in_msg[8] << 12  | (in_msg[9] & 0b00111111) << 20;
        c[3] =  in_msg[9] >> 6 | in_msg[10] << 2 | in_msg[11] << 10 | in_msg[12] << 18;
        c[4] =  in_msg[13]     | in_msg[14] << 8 | in_msg[15] << 16 | (1 << 24);
        
        in_msg += 16;
        inlen -= 16;
        add(h, c);    
        mulmod(h,r);
    } else { 
        if (inlen == 1) c[0] |= 1 << 8; else {
            c[0] |= in_msg[1] << 8;
            if (inlen == 2) c[0] |= 1 << 16; else {
                c[0] |= in_msg[2] << 16;
                if (inlen == 3) c[0] |= 1 << 24; else {
                    c[1] |= in_msg[3] >> 2;
                    c[0] |= (in_msg[3] & 0b00000011) << 24;
                    if (inlen == 4) c[1] |= 1 << 6;  else {
                        c[1] |= in_msg[4] << 6;
                        if (inlen == 5) c[1] |= 1 << 14; else {
                            c[1] |= in_msg[5] << 14;
                            if (inlen == 6) c[1] |= 1 << 22; else  {
                                c[2] |= in_msg[6] >> 4;
                                c[1] |= (in_msg[6] & 0b00001111) << 22;
                                if (inlen == 7) c[2] |= 1 << 4;  else {
                                    c[2] |= in_msg[7] << 4;
                                    if (inlen == 8) c[2] |= 1 << 12; else {
                                        c[2] |= in_msg[8] << 12;
                                        if (inlen == 9) c[2] |= 1 << 20; else {
                                            c[3] |= in_msg[9] >> 6;
                                            c[2] |= (in_msg[9] & 0b00111111) << 20;
                                            if (inlen == 10) c[3] |= 1 << 2;  else {
                                                c[3] |= in_msg[10] << 2;
                                                if (inlen == 11) c[3] |= 1 << 10; else {
                                                    c[3] |= in_msg[11] << 10;
                                                    if (inlen == 12) c[3] |= 1 << 18; else {
                                                        c[3] |= in_msg[12] << 18;
                                                        if (inlen == 13) c[4] |= 1; else {
                                                            c[4] |= in_msg[13];
                                                            if (inlen == 14) c[4] |= 1 << 8; else { // inlen == 15
                                                                c[4] |= in_msg[14] << 8;
                                                                c[4] |= 1 << 16;
                                                                    
        }}}}}}}}}}}}}}
        in_msg += inlen;
        inlen -= inlen;
        add(h, c);    
        mulmod(h,r);
    }
  }
  
  // freeze 
  // unsigned int horig[6]; use r, since its no longer needed now
  unsigned int negative;
  r[0] = h[0]; r[1] = h[1]; r[2] = h[2]; r[3] = h[3]; r[4] = h[4]; r[5] = h[5];
  add(h,minusp);
  negative = -(h[5] >> 25);
  h[0] ^= negative & (r[0] ^ h[0]);
  h[1] ^= negative & (r[1] ^ h[1]);
  h[2] ^= negative & (r[2] ^ h[2]);
  h[3] ^= negative & (r[3] ^ h[3]);
  h[4] ^= negative & (r[4] ^ h[4]);
  h[5] ^= negative & (r[5] ^ h[5]);
  // end of freeze
  
  c[0] = ((key[16] & 0b11111111) >> 0) | (key[17] << 8) | (key[18] << 16) | ((key[19]  & 0b00000011) << 24);
  c[1] = ((key[19] & 0b11111100) >> 2) | (key[20] << 6) | (key[21] << 14) | ((key[22]  & 0b00001111) << 22);
  c[2] = ((key[22] & 0b11110000) >> 4) | (key[23] << 4) | (key[24] << 12) | ((key[25]  & 0b00111111) << 20);
  c[3] = ((key[25] & 0b11000000) >> 6) | (key[26] << 2) | (key[27] << 10) | (key[28] << 18);
  c[4] = ((key[29] & 0b11111111) >> 0) | (key[30] << 8) | (key[31] << 16);
  
  add(h, c);
  
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
