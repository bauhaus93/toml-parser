#ifndef KEY_PAIR_H
#define KEY_PAIR_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "key.h"
#include "value.h"

typedef struct
{
	Key * key;
	Value * value;
} KeyPair;

KeyPair * makePair (Key *, Value *);
void printKeyPair (const KeyPair *);

#endif // KEY_PAIR_H
