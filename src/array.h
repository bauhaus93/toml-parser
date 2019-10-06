#ifndef ARRAY_H
#define ARRAY_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "value.h"

typedef struct _Array {
    Value *element;
    struct _Array *next;
} Array;

Array* push_value(Array *, Value *);
Array *array_from_value(Value *);

void print_array(const Array *);

#endif // ARRAY_H
