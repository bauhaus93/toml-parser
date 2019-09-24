#include "strings.h"

static int count_newlines(const char *str);
static const char *get_type(String *str);
char** strip_empty_head_tail(char** multiline, int* len);

String *create_string(StringType type, const char *raw) {
  String *str = malloc(sizeof(String));
  str->type = type;
  int nl_count = count_newlines(raw);
  if (nl_count == 0) {
    str->data.single_line = strdup(raw);
  } else {
    assert(type == STRING_TYPE_MULTILINE_BASIC ||
           type == STRING_TYPE_MULTILINE_LITERAL);
    int line_count = nl_count + 1;
    char *raw_copy = strdup(raw);
    char **multi_str = malloc(sizeof(char **) * line_count);
    char *token = strsep(&raw_copy, "\n");
    int multi_index = 0;
    while (token != NULL) {
      assert(multi_index < line_count);
      multi_str[multi_index++] = strdup(token);
      token = strsep(&raw_copy, "\n");
    }
    free(raw_copy);
    str->data.multi_line.line = strip_empty_head_tail(multi_str, &line_count);
    str->data.multi_line.count = line_count;
    free(multi_str);
  }
  return str;
}

char** strip_empty_head_tail(char** multiline, int* len) {
    int strip_head = strlen(multiline[0]) == 0 ? 1 : 0;
    int strip_tail = strlen(multiline[(*len) - 1]) == 0 ? 1: 0;
    int strip_count =  strip_head + strip_tail;
    char** stripped = malloc(sizeof(char*) * ((*len) - strip_count));
    memcpy(stripped, multiline + strip_head, sizeof(char*) * ((*len) - strip_count));
    *len -= strip_count;
    return stripped;
}

void print_info_string(String *str) {
  assert(str != NULL);
  printf("String: type = %s, content = ", get_type(str));
  if (str->type == STRING_TYPE_MULTILINE_LITERAL ||
      str->type == STRING_TYPE_MULTILINE_BASIC) {
    printf("\n");
    for (int i = 0; i < str->data.multi_line.count; i++) {
      printf("line %d: %s\n", i, str->data.multi_line.line[i]);
    }
  } else {
    printf("%s\n", str->data.single_line);
  }
}

static const char *get_type(String *str) {
  assert(str != NULL);
  switch (str->type) {
  case STRING_TYPE_COMMENT:
    return "COMMENT";
  case STRING_TYPE_BARE:
    return "BARE";
  case STRING_TYPE_LITERAL:
    return "LITERAL";
  case STRING_TYPE_BASIC:
    return "BASIC";
  case STRING_TYPE_MULTILINE_LITERAL:
    return "ML_LITERAL";
  case STRING_TYPE_MULTILINE_BASIC:
    return "ML_BASIC";
  default:
    assert(0);
  }
}

static int count_newlines(const char *str) {
  int count = 0;
  while (*str != 0) {
    if (*str == '\n') {
      count++;
    }
    str++;
  }
  return count;
}
