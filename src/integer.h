#ifndef INTEGER_H
#define INTEGER_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

typedef enum { INTTYPE_DEC, INTTYPE_HEX, INTTYPE_OCT, INTTYPE_BIN } IntegerType;

typedef struct {
    IntegerType type;
    char *value;
} Integer;

void print_info_integer(Integer *);

#endif // INTEGER_H
