#include "integer_scalar.h"

static const char *get_type(IntegerScalar *scalar);

void print_scalar_integer(IntegerScalar *scalar) {
    assert(scalar != NULL);
    printf("IntegerScalar: type = %s, value = %s\n", get_type(scalar),
           scalar->value);
}

static const char *get_type(IntegerScalar *scalar) {
    assert(scalar != NULL);
    switch (scalar->type) {
    case INTTYPE_DEC:
        return "DEC";
    case INTTYPE_HEX:
        return "HEX";
    case INTTYPE_OCT:
        return "OCT";
    case INTTYPE_BIN:
        return "BIN";
    default:
        assert(0);
    }
}
