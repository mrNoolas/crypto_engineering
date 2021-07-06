#include "group.h"
#include "smult.h"
#include <stdio.h>
#include <stdbool.h>

group_ge preComputed[16];
bool alreadyComputed = false;



int crypto_scalarmult(unsigned char *ss, const unsigned char *sk, const unsigned char *pk)
{
  group_ge p, k, l;
  unsigned char t[32];
  int i,j;

  for(i=0;i<32;i++) {
    t[i] = sk[i];
  }

  t[0] &= 248;
  t[31] &= 127;
  t[31] |= 64;

  if(group_ge_unpack(&p, pk)) {return -1;}

  group_ge table[16];
  table[0] = group_ge_neutral;
  for(i = 0; i < 15; i++) {
    group_ge_add(table + i + 1, table + i, &p);
  }


  k = p;

  group_ge_double(&k, &k);
  group_ge_double(&k, &k);

  group_ge_lookup(&l, table, (t[31] >> 4)&3);
  group_ge_add(&k, &k, &l);

  for(j=0;j < 4;j++)
  {
    group_ge_double(&k, &k);
  }

  group_ge_lookup(&l, table, t[31] & 15);
  group_ge_add(&k, &k, &l);
  for(i=30;i>=0;i--)
  {
    for(j=0;j < 4;j++)
    {
      group_ge_double(&k, &k);
    }
    group_ge_lookup(&l, table, t[i] >> 4);
    group_ge_add(&k, &k, &l);
    for(j=0;j < 4;j++)
    {
      group_ge_double(&k, &k);
    }
    group_ge_lookup(&l, table, t[i] & 15);
    group_ge_add(&k, &k, &l);
  }

  group_ge_pack(ss, &k);

  return 0;
}

int crypto_scalarmult_base(unsigned char *pk, const unsigned char *sk)
{
  if(!alreadyComputed) {
    compute(preComputed);
    alreadyComputed = true;
  }
  group_ge k, l;
  unsigned char t[32];
  int i,j;

  for(i=0;i<32;i++) {
    t[i] = sk[i];
  }

  t[0] &= 248;
  t[31] &= 127;
  t[31] |= 64;

  k = group_ge_base;
  group_ge_double(&k, &k);
  group_ge_double(&k, &k);
  group_ge_lookup(&l, preComputed, (t[31] >> 4)&3);
  group_ge_add(&k, &k, &l);

  for(j=0;j < 4;j++)
  {
    group_ge_double(&k, &k);
  }

  group_ge_lookup(&l, preComputed, t[31] & 15);
  group_ge_add(&k, &k, &l);

  for(i=30;i>=0;i--)
  {
    for(j=0;j < 4;j++)
    {
      group_ge_double(&k, &k);
    }
    group_ge_lookup(&l, preComputed, t[i] >> 4);
    group_ge_add(&k, &k, &l);

    for(j=0;j < 4;j++)
    {
      group_ge_double(&k, &k);
    }

    group_ge_lookup(&l, preComputed, t[i] & 15);
    group_ge_add(&k, &k, &l);
  }

  group_ge_pack(pk, &k);

  return 0;
}
