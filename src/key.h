#ifndef KEY_H 
#define KEY_H

#include <stdlib.h>
#include <assert.h>

#include "scalar.h"

typedef struct _Key {
    Scalar* name;
    struct _Key* descendant;
} Key;

void append_key(Key* base, Key* appendant);
Key* key_from_scalar(Scalar* scalar);
void print_key(const Key* key);

#endif // KEY_H

