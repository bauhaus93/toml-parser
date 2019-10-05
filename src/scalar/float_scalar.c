#include "float_scalar.h"

static const char *get_type(const FloatScalar *float_value);

void print_scalar_float(const FloatScalar *scalar) {
    assert(scalar != NULL);
    printf("FloatScalar: type = %s, ", get_type(scalar));
    if (scalar->type == FLOATTYPE_NUM) {
        printf("value = %s", scalar->value);
    }
    printf("\n");
}

static const char *get_type(const FloatScalar *scalar) {
    assert(scalar != NULL);
    switch (scalar->type) {
    case FLOATTYPE_NUM:
        return "NUM";
    case FLOATTYPE_INFINITY:
        return "INF";
    case FLOATTYPE_POSITIVE_INFINITY:
        return "POS_INF";
    case FLOATTYPE_NEGATIVE_INFINITY:
        return "NEG_INF";
    case FLOATTYPE_NAN:
        return "NAN";
    case FLOATTYPE_POSITIVE_NAN:
        return "POS_NAN";
    case FLOATTYPE_NEGATIVE_NAN:
        return "NEG_NAN";
    default:
        assert(0);
    }
}
