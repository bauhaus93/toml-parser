#include "key.h"

static void print_sub_key(const Key* key);

Key* key_from_scalar(Scalar* scalar) {
    assert(scalar->type == SCALAR_STRING_BASIC ||
           scalar->type == SCALAR_STRING_LITERAL ||
           scalar->type == SCALAR_STRING_BARE);
    Key* key = malloc(sizeof(Key));
    key->name = scalar;
    key->descendant = NULL;
    return key;
}

void append_key(Key* base, Key* appendant) {
    assert(base != NULL);
    assert(appendant != NULL);

    base->descendant = appendant;
}

void print_key(const Key* key) {
    printf("%s", key->name->str);
    if (key->descendant != NULL) {
        print_sub_key(key->descendant);
    }
}

static void print_sub_key(const Key* key) {
    printf(".%s", key->name->str);
    if (key->descendant != NULL) {
        print_sub_key(key->descendant);
    }
}
