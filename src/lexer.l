%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "parser.h"
#include "integer.h"
#include "value.h"
#include "strings.h"

static void init_buffer(void);
static void append_buffer(char c);
static void append_buffer_str(const char* str, size_t len);
static const char* get_buffer(void);
static char* duplicate_buffer(void);

static char* string_buffer = NULL;
static int buffer_index = 0;
static int buffer_size = 0;

static char* read_literal(void);
static char* read_basic(void);

%}

%option yylineno
%option noyywrap

alpha [a-zA-Z]
digit [0-9]
alnum {alpha}|{digit}
any_byte [\x00-\xFF]

whitespace_char [\t ]
whitespace {whitespace_char}*
newline (\r\n)|\n

dec_char {digit}
dec_nzero [1-9]
hex_char [0-9a-fA-F]
oct_char [0-8]
bin_char [01]
decimal {dec_nzero}("_"?{dec_char})*
decimal_pm [+-]?{decimal}

bare_char [-_]|{alnum}

%%

"="        return EQUAL;
"."        return DOT;

"#"        { init_buffer();  BEGIN(SC_COMMENT); }

"'" {
    char* str = read_literal();

    yylval.string = create_string(STRING_TYPE_LITERAL, str);
    free(str);
    return LITERAL_STRING;
}

"\"" {
    char* str = read_basic();

    yylval.string = create_string(STRING_TYPE_BASIC, str);
    free(str);
    return BASIC_STRING;

}

{decimal_pm} {
    printf("[LEX] dec: %s\n", yytext);
    yylval.integer = malloc(sizeof(Integer));
    yylval.integer->type = INTTYPE_DEC;
    yylval.integer->value = strdup(yytext);
    return DEC_STRING;
}

("+"|"-")?"0" {
    printf("[LEX] dec: %s\n", yytext);
    yylval.integer = malloc(sizeof(Integer));
    yylval.integer->type = INTTYPE_DEC;
    yylval.integer->value = strdup(yytext);
    return DEC_STRING;
}

"0x"{hex_char}("_"?{hex_char})* {
    printf("[LEX] hex: %s\n", yytext);
    yylval.integer = malloc(sizeof(Integer));
    yylval.integer->type = INTTYPE_HEX;
    yylval.integer->value = strdup(yytext);
    return HEX_STRING;
}

"0o"{oct_char}("_"?{oct_char})* {
    printf("[LEX] oct: %s\n", yytext);
    yylval.integer = malloc(sizeof(Integer));
    yylval.integer->type = INTTYPE_OCT;
    yylval.integer->value = strdup(yytext);
    return OCT_STRING;
}

"0b"{bin_char}("_"?{bin_char})* {
    printf("[LEX] bin: %s\n", yytext);
    yylval.integer = malloc(sizeof(Integer));
    yylval.integer->type = INTTYPE_BIN;
    yylval.integer->value = strdup(yytext);
    return BIN_STRING;
}

{decimal_pm}("."{decimal})?([eE]{decimal_pm})? {
    printf("[LEX] float: %s\n", yytext);
    yylval.float_val = malloc(sizeof(Float));
    yylval.float_val->type = FLOATTYPE_NUM;
    yylval.float_val->value = strdup(yytext);
    return FLOAT_STRING;
}
("+"|"-")?"inf" {
    printf("[LEX] float: %s\n", yytext);
    yylval.float_val = malloc(sizeof(Float));
    switch(yytext[0]) {
        case '+':   yylval.float_val->type = FLOATTYPE_POSITIVE_INFINITY; break;
        case '-':   yylval.float_val->type = FLOATTYPE_NEGATIVE_INFINITY; break;
        default:    yylval.float_val->type = FLOATTYPE_INFINITY;    break;
    }
    return FLOAT_STRING;
}
("+"|"-")?"nan" {
    printf("[LEX] float: %s\n", yytext);
    yylval.float_val = malloc(sizeof(Float));
    switch(yytext[0]) {
        case '+':   yylval.float_val->type = FLOATTYPE_POSITIVE_NAN; break;
        case '-':   yylval.float_val->type = FLOATTYPE_NEGATIVE_NAN; break;
        default:    yylval.float_val->type = FLOATTYPE_NAN;    break;
    return FLOAT_STRING;
}

{whitespace}|{newline} ;

. {
    printf("[LEX] Unexpected sequence: %s\n", yytext);
    exit(1);
}

%%

static char* read_literal(void) {
    char* buffer = malloc(64 * sizeof(char));
    size_t size = 64;
    size_t index = 0;
    char c;

    while((c = yyinput()) != 0x27) { // terminating ' character
        if (c == 0x09 || (c >= 0x20 && c <= 0x7E)) { // read valid ascii chars
            append_char(&buffer, &index, &size, c);
        } else { // read valid non-ascii (utf8 chars)
            unput(c);
            read_non_ascii_char(&buffer, &index, &size);
        }
    }
    buffer = realloc(buffer, index);
    return buffer;
}

static char* read_basic(void) {
    char* buffer = malloc(64 * sizeof(char));
    size_t size = 64;
    size_t index = 0;
    char c;

    while((c = yyinput()) != 0x22) { // terminating " character
        if (c == 0x09 || (c >= 0x20 && c <= 0x7E)) { // read valid ascii chars
            buffer[index++] = c;

            if (index == size) {
                size *= 2;
                buffer = realloc(buffer, size);
            }
            if (c == 0x5C) {    // backslash for escaping
                c = yyinput();
                switch(c) {
                    case 0x22:
                    case 0x5C:
                    case 0x62:
                    case 0x66:
                    case 0x6E:
                    case 0x72:
                    case 0x74:
                        append_char(&buffer, &index, &size, c);
                        break;
                    case 0x75:
                        read_hex(&buffer, &index, &size, 4);
                        break;
                    case 0x55:
                        read_hex(&buffer, &index, &size, 8);
                        break;
                    default:
                        printf("[LEX ERROR] invalid escape char: %c\n", c);
                        exit(1);
                }
            }
        } else { // read valid non-ascii (utf8 chars)
            unput(c);
            read_non_ascii_char(&buffer, &index, &size);
        }
    }
    buffer = realloc(buffer, index);
    return buffer;
}

static void append_char(char** buffer, size_t* index, size_t* len, char c) {
    *buffer[*index++] = c;
    if (*index == *len) {
        *len *= 2;
        *buffer = realloc(*buffer, *len);
    }
}

static int is_hex(char c) {
    return (c >= '0' && c <= '9') ||
           (c >= 'a' && c <= 'f') ||
           (c >= 'A' && c <= 'F');
}

static void read_hex(char** buffer, size_t* index, size_t* len, size_t count) {
    for (size_t i = 0; i < count; i++) {
        char c = yyinput();
        if (!is_hex(c)) {
            printf("[LEX ERROR] invalid unicode escape: expected hex character, got %c\n", c);
            exit(1);
        }
        append_char(buffer, index, len, c);
    }
}


static void read_non_ascii_char(char** buffer, size_t* index, size_t* len) {
    char c = yyinput();

    if (c >= 0xF0 && c < 0xF8) { // 11110xxx
        len = 4;
    } else if (c >= 0xE0 && c < 0xF0) { // 1110xxxx
        len = 3;
    } else if (c >= 0xC0 && c < 0xE0) { // 110xxxxx
        len = 2
    } else if (c < 0x80) {                        // 0xxxxxxx
        // is ascii char
        printf("[LEX ERROR] utf8: unexpected char: ascii: %c\n", buffer[0]);
        exit(1);
    } else {
        printf("[LEX ERROR] utf8: invalid first byte: 0x%X", buffer[0]);
        exit(1);
    }
    append_char(buffer, index, len, c);
    for (size_t i = 1; i < len; i++) {
        c = yyinput();
        if (c < 0x80 || c >= 0xC0) {
            printf("[LEX ERROR] utf8: invalid byte #%d: 0x%X\n", i, c);
            exit(1);
        }
        append_char(buffer, index, len, c);
    }
    return len;
}
static void init_buffer(void) {
    buffer_size = 64;
    if (string_buffer == NULL) {
        string_buffer = malloc(sizeof(char) * buffer_size);
    } else {
        string_buffer = realloc(string_buffer, sizeof(char) * buffer_size);
    }
    memset(string_buffer, 0, sizeof(char) * buffer_size);
    buffer_index = 0;
}

static void append_buffer(char c) {
    assert(string_buffer != NULL);
    if (buffer_index >= buffer_size) {
        buffer_size *= 2;
        string_buffer = realloc(string_buffer, sizeof(char) * buffer_size);
    }
    string_buffer[buffer_index++] = c;
    string_buffer[buffer_index] = 0;
}

static void append_buffer_str(const char* str, size_t len) {
    assert(string_buffer != NULL);
    assert(str != NULL);
    if (buffer_index + len >= buffer_size) {
        buffer_size = buffer_index + len + 1;
        string_buffer = realloc(string_buffer, sizeof(char) * buffer_size);
    }
    memcpy(string_buffer + buffer_index, str, len);
    buffer_index += len;
}

static const char* get_buffer(void) {
    return string_buffer;
}

static char* duplicate_buffer(void) {
    assert(string_buffer != NULL);
    return strdup(string_buffer);
}
