#ifndef DATE_SCALAR_H
#define DATE_SCALAR_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

typedef enum {
    DATE_OFFSET_DATE_TIME,
    DATE_LOCAL_DATE_TIME,
    DATE_LOCAL_DATE,
    DATE_LOCAL_TIME
} DateType;

typedef struct {
    DateType type;
    char *value;
} DateScalar;

void print_scalar_date(const DateScalar *);

#endif // DATE_SCALAR_H
