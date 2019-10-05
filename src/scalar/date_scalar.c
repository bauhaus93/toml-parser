#include "date_scalar.h"

static const char* get_type(const DateScalar *scalar);


void print_scalar_date(const DateScalar *scalar) { 
    assert(scalar != NULL);
    printf("Date: type = %s, value = %s\n", get_type(scalar), scalar->value);
}

static const char* get_type(const DateScalar *scalar) {
    assert(scalar != NULL);
    switch (scalar->type) {
    case DATE_OFFSET_DATE_TIME:
        return "OFFSET_DATE_TIME";
    case DATE_LOCAL_DATE_TIME:
        return "LOCAL_DATE_TIME";
    case DATE_LOCAL_DATE:
        return "LOCAL_DATE";
    case DATE_LOCAL_TIME:
        return "LOCAL_TIME";
    default:
        assert(0);
    }
}
