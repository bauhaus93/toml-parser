#ifndef VALUE_H
#define VALUE_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "integer.h"
#include "strings.h"

typedef enum { VALUE_INTEGER, VALUE_FLOAT, VALUE_STRING } ValueType;

typedef struct {
  ValueType type;
  union {
    IntegerString *integer_value;
    String* string_value;
    char *float_value;
  } data;
} Value;

Value *from_integer(IntegerString *int_string);
Value *from_float(char *float_string);
Value *from_string(String* string);
void destroy_value(Value *value);

#endif // VALUE_H
