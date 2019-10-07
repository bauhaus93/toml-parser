#ifndef ARRAY_H
#define ARRAY_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "value.h"

typedef struct _Array
{
	Value * element;
	struct _Array * next;
} Array;

Array * pushValue (Array *, Value *);
Array * arrayFromValue (Value *);

void printArray (const Array *);

#endif // ARRAY_H
