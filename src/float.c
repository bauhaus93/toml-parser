#include "float.h"

static const char *get_type(Float *float_value);

void print_info_float(Float *float_value) {
  assert(float_value != NULL);
  printf("Float: type = %s", get_type(float_value));
  if (float_value->type == FLOATTYPE_NUM) {
    printf("value = %s", float_value->value);
  }
  printf("\n");
}

static const char *get_type(Float *float_value) {
  assert(float_value != NULL);
  switch (float_value->type) {
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
