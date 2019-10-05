#include "key.h"

static void print_sub_key(const Key* key);

Key* key_from_string(StringScalar* scalar) {
    assert(scalar->type == STRING_TYPE_BASIC ||
           scalar->type == STRING_TYPE_LITERAL ||
           scalar->type == STRING_TYPE_BARE);
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
    printf("Key: %s", key->name->data.single_line);
    if (key->descendant != NULL) {
        print_sub_key(key->descendant);
    }
    printf("\n");
}

static void print_sub_key(const Key* key) {
    printf("->%s", key->name->data.single_line);
    if (key->descendant != NULL) {
        print_sub_key(key->descendant);
    }
}
