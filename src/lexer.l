%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "parser.h"
#include "scalar/scalar.h"
#include "scalar/integer_scalar.h"
#include "scalar/float_scalar.h"
#include "scalar/string_scalar.h"

static char* read_literal(void);
static char* read_basic(void);
static char* read_multiline_literal(void);
static char* read_multiline_basic(void);
static char* read_comment(void);

static void append_char(char**, size_t*, size_t*, char);
static void read_non_ascii_char(char**, size_t*, size_t*);
static void read_hex(char**, size_t*, size_t*, size_t);
static int is_hex(char);

%}

%option yylineno
%option noyywrap

alpha [a-zA-Z]
digit [0-9]
alnum {alpha}|{digit}

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

"#" {
    char* str = read_comment();
    yylval.string_scalar = create_string(STRING_TYPE_COMMENT, str);
    free(str);
    return COMMENT;
}

"'" {
    char* str = read_literal();
    yylval.string_scalar = create_string(STRING_TYPE_LITERAL, str);
    free(str);
    return LITERAL_STRING;
}

"'''" {
    char* str = read_multiline_literal();
    yylval.string_scalar = create_string(STRING_TYPE_MULTILINE_LITERAL, str);
    free(str);
    return MULTI_LITERAL_STRING;
}

"\"" {
    char* str = read_basic();
    yylval.string_scalar = create_string(STRING_TYPE_BASIC, str);
    free(str);
    return BASIC_STRING;
}

"\"\"\"" {
    char* str = read_multiline_basic();
    yylval.string_scalar = create_string(STRING_TYPE_MULTILINE_BASIC, str);
    free(str);
    return MULTI_BASIC_STRING;

}

{decimal_pm} {
    printf("[LEX] dec: %s\n", yytext);
    yylval.integer_scalar = malloc(sizeof(IntegerScalar));
    yylval.integer_scalar->type = INTTYPE_DEC;
    yylval.integer_scalar->value = strdup(yytext);
    return DEC_STRING;
}

("+"|"-")?"0" {
    printf("[LEX] dec: %s\n", yytext);
    yylval.integer_scalar = malloc(sizeof(IntegerScalar));
    yylval.integer_scalar->type = INTTYPE_DEC;
    yylval.integer_scalar->value = strdup(yytext);
    return DEC_STRING;
}

"0x"{hex_char}("_"?{hex_char})* {
    printf("[LEX] hex: %s\n", yytext);
    yylval.integer_scalar = malloc(sizeof(IntegerScalar));
    yylval.integer_scalar->type = INTTYPE_HEX;
    yylval.integer_scalar->value = strdup(yytext);
    return HEX_STRING;
}

"0o"{oct_char}("_"?{oct_char})* {
    printf("[LEX] oct: %s\n", yytext);
    yylval.integer_scalar = malloc(sizeof(IntegerScalar));
    yylval.integer_scalar->type = INTTYPE_OCT;
    yylval.integer_scalar->value = strdup(yytext);
    return OCT_STRING;
}

"0b"{bin_char}("_"?{bin_char})* {
    printf("[LEX] bin: %s\n", yytext);
    yylval.integer_scalar = malloc(sizeof(IntegerScalar));
    yylval.integer_scalar->type = INTTYPE_BIN;
    yylval.integer_scalar->value = strdup(yytext);
    return BIN_STRING;
}

{decimal_pm}("."{decimal})?([eE]{decimal_pm})? {
    printf("[LEX] float: %s\n", yytext);
    yylval.float_scalar = malloc(sizeof(FloatScalar));
    yylval.float_scalar->type = FLOATTYPE_NUM;
    yylval.float_scalar->value = strdup(yytext);
    return FLOAT_STRING;
}
("+"|"-")?"inf" {
    printf("[LEX] float: %s\n", yytext);
    yylval.float_scalar = malloc(sizeof(FloatScalar));
    switch(yytext[0]) {
        case '+':   yylval.float_scalar->type = FLOATTYPE_POSITIVE_INFINITY; break;
        case '-':   yylval.float_scalar->type = FLOATTYPE_NEGATIVE_INFINITY; break;
        default:    yylval.float_scalar->type = FLOATTYPE_INFINITY;    break;
    }
    return FLOAT_STRING;
}
("+"|"-")?"nan" {
    printf("[LEX] float: %s\n", yytext);
    yylval.float_scalar = malloc(sizeof(FloatScalar));
    switch(yytext[0]) {
        case '+':   yylval.float_scalar->type = FLOATTYPE_POSITIVE_NAN; break;
        case '-':   yylval.float_scalar->type = FLOATTYPE_NEGATIVE_NAN; break;
        default:    yylval.float_scalar->type = FLOATTYPE_NAN;    break;
    }
    return FLOAT_STRING;
}

{bare_char}+ {
    printf("[LEX] bare.string_scalar: %s\n", yytext);
    yylval.string_scalar = create_string(STRING_TYPE_BARE, yytext);
    return BARE_STRING;
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

    while((c = input()) != 0x27) { // terminating ' character
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

    while((c = input()) != 0x22) { // terminating " character
        if (c == 0x09 || (c >= 0x20 && c <= 0x7E)) { // read valid ascii chars
            append_char(&buffer, &index, &size, c);
            if (c == 0x5C) {    // backslash for escaping
                c = input();
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
                        append_char(&buffer, &index, &size, c);
                        read_hex(&buffer, &index, &size, 4);
                        break;
                    case 0x55:
                        append_char(&buffer, &index, &size, c);
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

static char* read_multiline_literal(void) {
    char* buffer = malloc(64 * sizeof(char));
    size_t size = 64;
    size_t index = 0;
    char c;
    int terminator_count = 0;

    while(terminator_count < 3) {
        c = input();
        if (c == 0x27) {
            terminator_count++;
        } else {
            while (terminator_count > 0) {
                append_char(&buffer, &index, &size, 0x27);
                terminator_count--;
            }
            if (c == 0x09 || c == 0x0A || (c >= 0x20 && c <= 0x7E)) { // read valid ascii chars
                append_char(&buffer, &index, &size, c);
            } else { // read valid non-ascii (utf8 chars)
                unput(c);
                read_non_ascii_char(&buffer, &index, &size);
            }
        }
    }
    buffer = realloc(buffer, index);
    return buffer;
}

static char* read_multiline_basic(void) {
    char* buffer = malloc(64 * sizeof(char));
    size_t size = 64;
    size_t index = 0;
    char c;
    int terminator_count = 0;

    while(terminator_count < 3) {
        c = input();
        if (c == 0x22) {
            terminator_count++;
        } else {
            while (terminator_count > 0) {
                append_char(&buffer, &index, &size, 0x22);
                terminator_count--;
            }
            if (c == 0x09 || c == 0x0A || (c >= 0x20 && c <= 0x7E)) { // read valid ascii chars
                append_char(&buffer, &index, &size, c);
                if (c == 0x5C) {    // backslash for escaping
                    c = input();
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
                            append_char(&buffer, &index, &size, c);
                            read_hex(&buffer, &index, &size, 4);
                            break;
                        case 0x55:
                            append_char(&buffer, &index, &size, c);
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
    }
    buffer = realloc(buffer, index);
    return buffer;
}

static char* read_comment(void) {
    char* buffer = malloc(64 * sizeof(char));
    size_t size = 64;
    size_t index = 0;
    char c;

    while((c = input()) != '\n') { // terminating ' character
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

static void append_char(char** buffer, size_t* index, size_t* len, char c) {
    (*buffer)[*index] = c;
    *index = *index + 1;
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
        char c = input();
        if (!is_hex(c)) {
            printf("[LEX ERROR] invalid unicode escape: expected hex character, got %c\n", c);
            exit(1);
        }
        append_char(buffer, index, len, c);
    }
}


static void read_non_ascii_char(char** buffer, size_t* index, size_t* len) {
    unsigned char c = (unsigned char) input();
    size_t utf_len;

    if (c >= 0xF0 && c < 0xF8) { // 11110xxx
        utf_len = 4;
    } else if (c >= 0xE0 && c < 0xF0) { // 1110xxxx
        utf_len = 3;
    } else if (c >= 0xC0 && c < 0xE0) { // 110xxxxx
        utf_len = 2;
    } else if (c < 0x80) {                        // 0xxxxxxx
        // is ascii char
        printf("[LEX ERROR] utf8: unexpected char: ascii: %c, 0x%02X\n", c, c & 0xFF);
        exit(1);
    } else {
        printf("[LEX ERROR] utf8: invalid first byte: 0x%X", c);
        exit(1);
    }
    append_char(buffer, index, len, c);
    for (size_t i = 1; i < utf_len; i++) {
        c = input();
        if (c < 0x80 || c >= 0xC0) {
            printf("[LEX ERROR] utf8: invalid byte #%d: 0x%X\n", i, c);
            exit(1);
        }
        append_char(buffer, index, len, c);
    }
}
