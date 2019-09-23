#ifndef STRING_MY_H
#define STRING_MY_H

#include <stdlib.h>
#include <string.h>

typedef enum { STRING_TYPE_COMMENT, STRING_TYPE_BARE, STRING_TYPE_SINGLE_QUOTE, STRING_TYPE_DOUBLE_QUOTE } StringType;

typedef struct {
  StringType type;
  char *value;
} String;

String* create_string(StringType type, const char* raw);

#endif // STRING_MY_H
