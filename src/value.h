#ifndef VALUE_H
#define VALUE_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "float.h"
#include "integer.h"
#include "strings.h"

typedef enum { VALUE_INTEGER, VALUE_FLOAT, VALUE_STRING } ValueType;

typedef struct {
    ValueType type;
    union {
        Integer *integer_value;
        String *string_value;
        Float *float_value;
    } data;
} Value;

Value *from_integer(Integer *);
Value *from_float(Float *);
Value *from_string(String *);
void print_info_value(Value *);
void destroy_value(Value *);

#endif // VALUE_H
