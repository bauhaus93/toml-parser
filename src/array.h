#ifndef ARRAY_H
#define ARRAY_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef ARRAY_DEFINED
typedef struct _Array Array;
#define ARRAY_DEFINED
#endif

#include "value.h"

struct _Array
{
	Value * element;
	struct _Array * next;
};

Array * pushValue (Array *, Value *);
Array * arrayFromValue (Value *);

void printArray (const Array *);

#endif // ARRAY_H
