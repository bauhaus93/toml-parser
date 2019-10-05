#ifndef STRING_SCALAR_H
#define STRING_SCALAR_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    STRING_TYPE_COMMENT,
    STRING_TYPE_BARE,
    STRING_TYPE_LITERAL,
    STRING_TYPE_BASIC,
    STRING_TYPE_MULTILINE_LITERAL,
    STRING_TYPE_MULTILINE_BASIC
} StringType;

typedef struct {
    StringType type;
    union {
        char* single_line;
        struct {
            size_t count;
            char** line;
        } multi_line;
    } data;
} StringScalar;

StringScalar *create_string(StringType, const char *);
void print_scalar_string(StringScalar*);

#endif // STRING_SCALAR_H
