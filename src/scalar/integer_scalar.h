#ifndef INTEGER_SCALAR_H
#define INTEGER_SCALAR_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

typedef enum { INTTYPE_DEC, INTTYPE_HEX, INTTYPE_OCT, INTTYPE_BIN } IntegerType;

typedef struct {
    IntegerType type;
    char *value;
} IntegerScalar;

void print_scalar_integer(const IntegerScalar *);

#endif // INTEGER_SCALAR_H
