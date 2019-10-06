#include "key_pair.h"

KeyPair* make_pair(Key* key, Value* value) {
    assert(key != NULL);
    assert(value != NULL);
    KeyPair* pair = malloc(sizeof(KeyPair));
    pair->key = key;
    pair->value = value;
    return pair;
}

void print_key_pair(const KeyPair* key_pair) {
    assert(key_pair != NULL);
    print_key(key_pair->key);
    printf(" : ");
    print_value(key_pair->value);
}
