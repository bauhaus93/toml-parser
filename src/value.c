#include "value.h"


Value* from_integer(IntegerString* int_string) {
    Value* val = malloc(sizeof(Value));
    val->type = VALUE_INTEGER;
    val->data.integer_value = int_string;
    return val;
}

Value* from_float(char* float_string) {
    Value* val = malloc(sizeof(Value));
    val->type = VALUE_FLOAT;
    val->data.float_value = float_string;
    return val;
}

Value* from_string(char* string) {
    Value* val = malloc(sizeof(Value));
    val->type = VALUE_STRING;
    val->data.string_value = string;
    return val;
}
