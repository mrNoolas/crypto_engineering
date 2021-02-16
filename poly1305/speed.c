#include <stdio.h>
#include "poly1305.h"
#include "../common/stm32wrapper.h"

#define INLEN 512

const unsigned char msg[INLEN];

unsigned char tag[POLY1305_BYTES];

unsigned char key[POLY1305_KEYBYTES] = {
  0x57, 0x6c, 0x7c, 0x77, 0x6a, 0xc2, 0x93, 0xc6, 0x78, 0x3a, 0x4a, 0x48, 0xc9, 0x45, 0x20, 0x36};

int main(void)
{
  char outstr[128];
  unsigned int oldcount, newcount;

  clock_setup(CLOCK_BENCHMARK);
  gpio_setup();
  usart_setup(115200);

  SCS_DEMCR |= SCS_DEMCR_TRCENA;
  DWT_CYCCNT = 0;
  DWT_CTRL |= DWT_CTRL_CYCCNTENA;

  send_USART_str((unsigned char*)"\n============ IGNORE OUTPUT BEFORE THIS LINE ============\n");
  
  oldcount = DWT_CYCCNT;
  crypto_onetimeauth_poly1305(tag,msg,INLEN,key);

  newcount = DWT_CYCCNT-oldcount;

  sprintf(outstr, "\ncycles for %d bytes: %u", INLEN, newcount);

  send_USART_str((unsigned char*)outstr);

  while(1);

  return 0;
}
