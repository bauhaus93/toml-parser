#ifndef VALUE_H
#define VALUE_H

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "scalar/scalar.h"
#include "array.h"

typedef enum { VALUE_SCALAR, VALUE_ARRAY } ValueType;

typedef struct {
    ValueType type;
    union {
        Scalar *scalar;
        Array *array;
    } data;
} Value;

Value *value_from_scalar(Scalar *);
Value *value_from_array(Array *);
void print_value(const Value *);

#endif // VALUE_H
