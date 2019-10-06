%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "parser.h"
#include "scalar.h"

static char* read_literal(void);
static char* read_basic(void);
static char* read_multiline_literal(void);
static char* read_multiline_basic(void);
static char* read_comment(void);

static void append_char(char**, size_t*, size_t*, char);
static void read_non_ascii_char(char**, size_t*, size_t*);
static void read_hex(char**, size_t*, size_t*, size_t);
static int is_hex(char);


typedef struct _ConditionStack {
    int condition;
    struct _ConditionStack* next;
} ConditionStack;

static ConditionStack* stack_root = NULL;

static void push_condition(int);
static void pop_condition(void);
static inline void pop_condition_if(int);

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

offset_datetime {full_date}[T ]{full_time}
local_datetime  {full_date}[T ]{partial_time}
local_date {full_date}
local_time {partial_time}

full_date {digit}{4,4}"-"{digit}{2,2}"-"{digit}{2,2}
full_time {partial_time}{time_offset}
partial_time {digit}{2,2}":"{digit}{2,2}":"{digit}{2,2}("."{digit}+)?
time_offset "Z"|{time_num_offset}
time_num_offset [+-]{digit}{2,2}":"{digit}{2,2}

%s RHS
%s IN_BRACKETS
%s IN_CURLY

%%

"=" {
    push_condition(RHS);
    return EQUAL;
}

"." return DOT;
"," return COMMA;

"[" {
    push_condition(IN_BRACKETS);
    return BRACKETS_OPEN;
}
"]" {
    pop_condition();
    pop_condition_if(RHS);
    return BRACKETS_CLOSE;
}

"{" {
    push_condition(IN_CURLY);
    return CURLY_OPEN;
}
"}" {
    pop_condition();
    pop_condition_if(RHS);
    return CURLY_CLOSE;
}

"#" {
    char* str = read_comment();
    yylval.scalar = create_scalar(SCALAR_STRING_COMMENT, str);
    return COMMENT;
}

"'" {
    char* str = read_literal();
    yylval.scalar = create_scalar(SCALAR_STRING_LITERAL, str);
    pop_condition_if(RHS);
    return LITERAL_STRING;
}

"'''" {
    char* str = read_multiline_literal();
    yylval.scalar = create_scalar(SCALAR_STRING_ML_LITERAL, str);
    pop_condition_if(RHS);
    return MULTI_LITERAL_STRING;
}

"\"" {
    char* str = read_basic();
    yylval.scalar = create_scalar(SCALAR_STRING_BASIC, str);
    pop_condition_if(RHS);
    return BASIC_STRING;
}

"\"\"\"" {
    char* str = read_multiline_basic();
    yylval.scalar = create_scalar(SCALAR_STRING_ML_BASIC, str);
    pop_condition_if(RHS);
    return MULTI_BASIC_STRING;
}

<RHS,IN_BRACKETS>{decimal_pm} {
    yylval.scalar = create_scalar_dup(SCALAR_INTEGER_DEC, yytext);
    pop_condition_if(RHS);
    return DECIMAL;
}

<RHS,IN_BRACKETS>("+"|"-")?"0" {
    yylval.scalar = create_scalar_dup(SCALAR_INTEGER_DEC, yytext);
    pop_condition_if(RHS);
    return DECIMAL;
}

<RHS,IN_BRACKETS>"0x"{hex_char}("_"?{hex_char})* {
    yylval.scalar = create_scalar_dup(SCALAR_INTEGER_HEX, yytext);
    pop_condition_if(RHS);
    return HEXADECIMAL;
}

<RHS,IN_BRACKETS>"0o"{oct_char}("_"?{oct_char})* {
    yylval.scalar = create_scalar_dup(SCALAR_INTEGER_OCT, yytext);
    pop_condition_if(RHS);
    return OCTAL;
}

<RHS,IN_BRACKETS>"0b"{bin_char}("_"?{bin_char})* {
    yylval.scalar = create_scalar_dup(SCALAR_INTEGER_BIN, yytext);
    pop_condition_if(RHS);
    return BINARY;
}

<RHS,IN_BRACKETS>{decimal_pm}("."{decimal})?([eE]{decimal_pm})? {
    yylval.scalar = create_scalar_dup(SCALAR_FLOAT_NUM, yytext);
    pop_condition_if(RHS);
    return FLOAT;
}
<RHS,IN_BRACKETS>("+"|"-")?"inf" {
    yylval.scalar = create_scalar_dup(SCALAR_FLOAT_NUM, yytext);
    switch(yytext[0]) {
        case '+':   yylval.scalar->type = SCALAR_FLOAT_POS_INF; break;
        case '-':   yylval.scalar->type = SCALAR_FLOAT_NEG_INF; break;
        default:    yylval.scalar->type = SCALAR_FLOAT_INF;     break;
    }
    pop_condition_if(RHS);
    return FLOAT;
}
<RHS,IN_BRACKETS>("+"|"-")?"nan" {
    yylval.scalar = create_scalar_dup(SCALAR_FLOAT_NUM, yytext);
    switch(yytext[0]) {
        case '+':   yylval.scalar->type = SCALAR_FLOAT_POS_NAN; break;
        case '-':   yylval.scalar->type = SCALAR_FLOAT_NEG_NAN; break;
        default:    yylval.scalar->type = SCALAR_FLOAT_NAN;     break;
    }
    pop_condition_if(RHS);
    return FLOAT;
}

<RHS,IN_BRACKETS>{offset_datetime} {
    yylval.scalar = create_scalar_dup(SCALAR_DATE_OFFSET_DATETIME, yytext);
    pop_condition_if(RHS);
    return OFFSET_DATETIME;
}
<RHS,IN_BRACKETS>{local_datetime} {
    yylval.scalar = create_scalar_dup(SCALAR_DATE_LOCAL_DATETIME, yytext);
    pop_condition_if(RHS);
    return LOCAL_DATETIME;
}
<RHS,IN_BRACKETS>{local_date} {
    yylval.scalar = create_scalar_dup(SCALAR_DATE_LOCAL_DATE, yytext);
    pop_condition_if(RHS);
    return LOCAL_DATE;
}
<RHS,IN_BRACKETS>{local_time} {
    yylval.scalar = create_scalar_dup(SCALAR_DATE_LOCAL_TIME, yytext);
    pop_condition_if(RHS);
    return LOCAL_TIME;
}

<RHS,IN_BRACKETS>"true"|"false" {
    yylval.scalar = create_scalar_dup(SCALAR_BOOLEAN, yytext);
    pop_condition_if(RHS);
    return BOOLEAN;
}

<INITIAL,IN_BRACKETS,IN_CURLY>{bare_char}+ {
    yylval.scalar = create_scalar_dup(SCALAR_STRING_BARE, yytext);
    return BARE_STRING;
}

<IN_CURLY>{newline} {
    printf("[LEX_ERROR] No newline in inline table allowed, but found newline\n");
    exit(1);
}

{whitespace}|{newline} ;

. {
    printf("[LEX_ERROR] Unexpected sequence: %s\n", yytext);
    exit(1);
}

%%

static void push_condition(int condition) {
    if (stack_root == NULL) {
        stack_root = malloc(sizeof(ConditionStack));
        stack_root->condition = condition;
        stack_root->next = NULL;
    } else {
        ConditionStack* new_root = malloc(sizeof(ConditionStack));
        new_root->condition = condition;
        new_root->next = stack_root;
        stack_root = new_root;
    }
    BEGIN(condition);
    // printf("[LEX] push @ '%s' -> %d\n", yytext, YY_START);
}

static void pop_condition(void) {
    if (stack_root == NULL) {
        printf("[LEX_ERROR] Wanted to pop start condition, but stack is empty\n");
        exit(1);
    } else {
        stack_root = stack_root->next;
        if (stack_root == NULL) {
            BEGIN(INITIAL);
        } else {
            BEGIN(stack_root->condition);
        }
    }
    // printf("[LEX] pop @ '%s' -> %d\n", yytext, YY_START);
}

static inline void pop_condition_if(int condition) {
    if (YY_START == condition) {
        pop_condition();
    }
}

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
