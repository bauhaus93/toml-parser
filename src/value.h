#ifndef VALUE_H 
#define VALUE_H

#include <stdlib.h>

#include "integer.h"

typedef enum { VALUE_INTEGER, VALUE_FLOAT, VALUE_STRING } ValueType;

typedef struct {
  ValueType type;
  union {
    IntegerString *integer_value;
    char *float_value;
    char *string_value;
  } data;
} Value;

Value* from_integer(IntegerString* int_string);
Value* from_float(char* float_string);
Value* from_string(char* string);

#endif // VALUE_H
