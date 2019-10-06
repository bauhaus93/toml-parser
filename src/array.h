#ifndef ARRAY_H
#define ARRAY_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "scalar.h"

typedef struct _Array {
    Scalar *element;
    struct _Array *next;
} Array;

void append_element(Array *, Array *);
Array *array_from_scalar(Scalar *);

void print_array(const Array *);

#endif // ARRAY_H
