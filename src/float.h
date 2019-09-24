#ifndef FLOAT_H
#define FLOAT_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

typedef enum {
  FLOATTYPE_NUM,
  FLOATTYPE_INFINITY,
  FLOATTYPE_POSITIVE_INFINITY,
  FLOATTYPE_NEGATIVE_INFINITY,
  FLOATTYPE_NAN,
  FLOATTYPE_POSITIVE_NAN,
  FLOATTYPE_NEGATIVE_NAN
} FloatType;

typedef struct {
  FloatType type;
  char *value;
} Float;

void print_info_float(Float *);

#endif // FLOAT_H
