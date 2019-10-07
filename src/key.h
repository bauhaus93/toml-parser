#ifndef KEY_H
#define KEY_H

#include <assert.h>
#include <stdlib.h>

#include "scalar.h"

typedef struct _Key
{
	Scalar * name;
	struct _Key * descendant;
} Key;

void appendKey (Key * base, Key * appendant);
Key * keyFromScalar (Scalar * scalar);
void printKey (const Key * key);

#endif // KEY_H
