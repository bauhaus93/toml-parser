#include "strings.h"

String* create_string(StringType type, const char* raw) {
    String* str = malloc(sizeof(String));
    str->type = type;
    str->value = strdup(raw);
    return str;
}
