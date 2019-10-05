#ifndef SCALAR_H
#define SCALAR_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "float_scalar.h"
#include "integer_scalar.h"
#include "string_scalar.h"

typedef enum { SCALAR_INTEGER, SCALAR_FLOAT, SCALAR_STRING } ScalarType;

typedef struct {
    ScalarType type;
    union {
        IntegerScalar *integer_scalar;
        StringScalar *string_scalar;
        FloatScalar *float_scalar;
    } data;
} Scalar;

Scalar *from_integer(IntegerScalar *);
Scalar *from_float(FloatScalar *);
Scalar *from_string(StringScalar *);
void print_scalar(Scalar *);
void destroy_scalar(Scalar *);

#endif // SCALAR_H
