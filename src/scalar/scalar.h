#ifndef SCALAR_H
#define SCALAR_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "float_scalar.h"
#include "integer_scalar.h"
#include "string_scalar.h"
#include "date_scalar.h"

typedef enum {
    SCALAR_INTEGER,
    SCALAR_FLOAT,
    SCALAR_STRING,
    SCALAR_DATE
} ScalarType;

typedef struct {
    ScalarType type;
    union {
        IntegerScalar *integer_scalar;
        StringScalar *string_scalar;
        FloatScalar *float_scalar;
        DateScalar *date_scalar;
    } data;
} Scalar;

Scalar *from_integer(IntegerScalar *);
Scalar *from_float(FloatScalar *);
Scalar *from_string(StringScalar *);
Scalar *from_date(DateScalar *);
void print_scalar(const Scalar *);

#endif // SCALAR_H
