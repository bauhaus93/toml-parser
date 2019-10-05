#ifndef KEY_H 
#define KEY_H

#include <stdlib.h>

#include "scalar/string_scalar.h"

typedef struct _Key {
    StringScalar* name;
    struct _Key* descendant;
} Key;

void append_key(Key* base, Key* appendant);
Key* key_from_string(StringScalar* scalar);
void print_key(const Key* key);

#endif // KEY_H

