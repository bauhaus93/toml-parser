#include "value.h"

static const char *get_type(const Value *value);

Value *value_from_scalar(Scalar *scalar) {
    assert(scalar != NULL);
    Value *val = malloc(sizeof(Value));
    val->type = VALUE_SCALAR;
    val->data.scalar = scalar;
    return val;
}

Value *value_from_array(Array *array) {
    assert(array != NULL);
    Value *val = malloc(sizeof(Value));
    val->type = VALUE_ARRAY;
    val->data.array = array;
    return val;
}

void print_value(const Value *value) {
    printf("Value: type = %s, ", get_type(value));
    switch (value->type) {
    case VALUE_SCALAR:
        print_scalar(value->data.scalar);
        break;
    case VALUE_ARRAY:
        print_array(value->data.array);
        break;
    default:
        assert(0);
    }
}

static const char *get_type(const Value *value) {
    assert(value != NULL);
    switch (value->type) {
    case VALUE_SCALAR:
        return "SCALAR";
    case VALUE_ARRAY:
        return "ARRAY";
    default:
        assert(0);
    }
}
