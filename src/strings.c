#include "strings.h"

static int count_newlines(const char* str);

String* create_string(StringType type, const char* raw) {
    String* str = malloc(sizeof(String));
    str->type = type;
    int nl_count = count_newlines(raw);
    printf("COUNT = %d\n", nl_count);
    if (nl_count == 0) {
        str->data.single_line = strdup(raw);
    } else {
        assert(type == STRING_TYPE_MULTILINE_BASIC || type == STRING_TYPE_MULTILINE_LITERAL);
        char* raw_copy = strdup(raw);
        char** multi_str = malloc(sizeof(char**) * (nl_count + 1));
        char* token = strtok(raw_copy, "\n");
        int multi_index = 0;
        while (token != NULL) {
            assert(multi_index < nl_count + 1);
            multi_str[multi_index++] = strdup(token);
            token = strtok(NULL, "\n");
        }
        str->data.multi_line.line = multi_str;
        str->data.multi_line.count = nl_count + 1;
    }
    return str;
}

static int count_newlines(const char* str) {
    int count = 0;
    while(*str != 0) {
        if (*str == '\n') {
            count++;
        }
        str++;
    }
    return count;
}
