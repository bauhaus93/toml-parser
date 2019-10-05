#include "scalar.h"

Scalar *from_integer(IntegerScalar *scalar) {
    Scalar *val = malloc(sizeof(Scalar));
    val->type = SCALAR_INTEGER;
    val->data.integer_scalar = scalar;
    return val;
}

Scalar *from_float(FloatScalar *scalar) {
    Scalar *val = malloc(sizeof(Scalar));
    val->type = SCALAR_FLOAT;
    val->data.float_scalar = scalar;
    return val;
}

Scalar *from_string(StringScalar *scalar) {
    Scalar *val = malloc(sizeof(Scalar));
    val->type = SCALAR_STRING;
    val->data.string_scalar = scalar;
    return val;
}

Scalar *from_date(DateScalar *scalar) {
    Scalar *val = malloc(sizeof(Scalar));
    val->type = SCALAR_DATE;
    val->data.date_scalar = scalar;
    return val;
}

void print_scalar(const Scalar *scalar) {
    assert(scalar != NULL);
    printf("Scalar: ");
    switch (scalar->type) {
    case SCALAR_INTEGER:
        print_scalar_integer(scalar->data.integer_scalar);
        break;
    case SCALAR_STRING:
        print_scalar_string(scalar->data.string_scalar);
        break;
    case SCALAR_FLOAT:
        print_scalar_float(scalar->data.float_scalar);
        break;
    case SCALAR_DATE:
        print_scalar_date(scalar->data.date_scalar);
        break;
    default:
        assert(0);
    }
}
