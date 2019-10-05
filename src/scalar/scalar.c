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

void print_scalar(Scalar *scalar) {
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
    default:
        assert(0);
    }
}

void destroy_scalar(Scalar *scalar) {
    if (scalar != NULL) {
        printf("Freeing scalar of type %d\n", scalar->type);
        switch (scalar->type) {
        case SCALAR_INTEGER:
            free(scalar->data.integer_scalar);
            break;
        case SCALAR_FLOAT:
            free(scalar->data.float_scalar);
            break;
        case SCALAR_STRING:
            free(scalar->data.string_scalar);
            break;
        default:
            assert(0);
        }
    }
}
