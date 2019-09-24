#include "value.h"

Value *from_integer(Integer *int_string) {
  Value *val = malloc(sizeof(Value));
  val->type = VALUE_INTEGER;
  val->data.integer_value = int_string;
  return val;
}

Value *from_float(Float *float_string) {
  Value *val = malloc(sizeof(Value));
  val->type = VALUE_FLOAT;
  val->data.float_value = float_string;
  return val;
}

Value *from_string(String *string) {
  Value *val = malloc(sizeof(Value));
  val->type = VALUE_STRING;
  val->data.string_value = string;
  return val;
}

void print_info_value(Value *value) {
  assert(value != NULL);
  printf("Value: ");
  switch (value->type) {
  case VALUE_INTEGER:
    print_info_integer(value->data.integer_value);
    break;
  case VALUE_STRING:
    print_info_string(value->data.string_value);
    break;
  case VALUE_FLOAT:
    print_info_float(value->data.float_value);
    break;
  default:
    assert(0);
  }
}

void destroy_value(Value *value) {
  if (value != NULL) {
    printf("Freeing value of type %d\n", value->type);
    switch (value->type) {
    case VALUE_INTEGER:
      free(value->data.integer_value);
      break;
    case VALUE_FLOAT:
      free(value->data.float_value);
      break;
    case VALUE_STRING:
      free(value->data.string_value);
      break;
    default:
      assert(0);
    }
  }
}
