#include "integer.h"

static const char *get_type(Integer *integer);

void print_info_integer(Integer *integer) {
    assert(integer != NULL);
    printf("Integer: type = %s, value = %s\n", get_type(integer), integer->value);
}

static const char *get_type(Integer *integer) {
  assert(integer != NULL);
  switch (integer->type) {
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
