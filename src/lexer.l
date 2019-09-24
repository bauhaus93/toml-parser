%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "parser.h"
#include "integer.h"
#include "value.h"
#include "strings.h"

char* copy_strip_leading_trailing(const char* str, int count);
char* copy_quoted_string(const char* quoted_string);
char* copy_triple_quoted_string(const char* quoted_string);
char* copy_comment(const char* comment);

void init_buffer(void);
void append_buffer(char c);
void append_buffer(const char* str);
const char* get_buffer(void);
char* duplicate_buffer(void);

char* string_buffer = NULL;
int buffer_index = 0;
int buffer_size = 0;

%}

%option yylineno
%option noyywrap

alpha [a-zA-Z]
digit [0-9]
alnum {alpha}|{digit}

bare_chars [.-_]|{alnum}
dec_chars {digit}
hex_chars [0-9a-fA-F]
oct_chars [0-8]
bin_chars [01]

%s SC_BASIC
%s SC_LITERAL
%s SC_ML_BASIC
%s SC_ML_LITERAL

%{
    /* Source for patterns:
       https://www.w3.org/2005/03/23-lex-U#utf8toot
    */
%}
ascii_chars [\x00-\x7F]
utf8_chars_pat1 [\x80-\xBF]
utf8_chars_pat2 [\xC2-\xDF]
utf8_chars_pat3 [\xA0-\xBF]
utf8_chars_pat4 [\x80-\x9F]
utf8_chars_pat5 \xE0
utf8_chars_pat6 [\xE1-\xEC]
utf8_chars_pat7 \xED
utf8_chars_pat8 [\xEE-\xEF]
utf8_chars_pat9 \xF0
utf8_chars_pat10 [\xF1-\xF3]
utf8_chars_pat11 \xF4
utf8_chars_pat12 [\x90-\xBF]
utf8_chars_pat13 [\x80-\x8F]

utf8_2byte {utf8_chars_pat2}{utf8_chars_pat1}

utf8_3byte1 {utf8_chars_pat5}{utf8_chars_pat3}
utf8_3byte2 {utf8_chars_pat6}{utf8_chars_pat1}
utf8_3byte3 {utf8_chars_pat7}{utf8_chars_pat4}
utf8_3byte4 {utf8_chars_pat8}{utf8_chars_pat1}
utf8_3byte ({utf8_3byte1}|{utf8_3byte2}|{utf8_3byte3}|{utf8_3byte4}){utf8_chars_pat1}

utf8_4byte1 {utf8_chars_pat9}{utf8_chars_pat12}
utf8_4byte2 {utf8_chars_pat10}{utf8_chars_pat1}
utf8_4byte3 {utf8_chars_pat11}{utf8_chars_pat13}
utf8_4byte ({utf8_4byte1}|{utf8_4byte2}{utf8_4byte3}){utf8_chars_pat1}{2,2}

ascii_no_nl [\x00-\x09\x0B-\x7F]
ascii_chars_literal [\x00-\x09\x0B-\x26\x28-\x7F]
ascii_chars_ml_literal [\x00-\x26\x28-\x7F]|(\x27/\x27/\x27)

ascii_chars_basic_normal [\x00-\x07\x0B\x0E-\x21\x23-\x5B\x5D-\x7F]
ascii_chars_basic_escaped \x5C[btnfr"\x5C]
ascii_chars_basic_escaped_u \x5C(u|U)({hex_chars}{4,4}|{hex_chars}{8,8})
ascii_chars_basic {ascii_chars_basic_normal}|{ascii_chars_basic_escaped}|{ascii_chars_basic_escaped_u}

utf8_non_ascii_chars {utf8_2byte}|{utf8_3byte}|{utf8_4byte}

utf8_chars {ascii_chars}|{utf8_non_ascii_chars}
utf8_chars_comment {ascii_no_nl}|{utf8_non_ascii_chars}
utf8_chars_literal {ascii_chars_literal}|{utf8_non_ascii_chars}
utf8_chars_basic {ascii_chars_basic}|{utf8_non_ascii_chars}
utf8_chars_ml_literal {ascii_chars_ml_literal}|{utf8_non_ascii_chars}

%%

<INITIAL>"="     return EQUAL;
<INITIAL>"."     return DOT;
<INITIAL>"#" {
    init_buffer();
    BEGIN(SC_COMMENT);
}

<SC_COMMENT>{utf8_chars_comment}+ {
    append_buffer(yytext);
}

<SC_COMMENT>"\n"|<EOF> {
    yylval.string = create_string(STRING_TYPE_COMMENT, get_buffer());
    BEGIN(INITIAL);
    return COMMENT;
}

"#"{utf8_chars_comment}*(\n|<EOF>) {
    char* stripped = copy_comment(yytext);
    printf("[LEX] comment: %s", stripped);
    yylval.string = create_string(STRING_TYPE_COMMENT, stripped);
    free(stripped);
    return COMMENT;
}

("+"|"-")?{dec_chars}("_"?{dec_chars})* {
    printf("[LEX] dec: %s\n", yytext);
    yylval.int_string = malloc(sizeof(IntegerString));
    yylval.int_string->type = INTTYPE_DEC;
    yylval.int_string->value = strdup(yytext);
    return DEC_STRING;
}

"0x"{hex_chars}("_"?{hex_chars})* {
    printf("[LEX] hex: %s\n", yytext);
    yylval.int_string = malloc(sizeof(IntegerString));
    yylval.int_string->type = INTTYPE_HEX;
    yylval.int_string->value = strdup(yytext);
    return HEX_STRING;
}

"0o"{oct_chars}("_"?{oct_chars})* {
    printf("[LEX] oct: %s\n", yytext);
    yylval.int_string = malloc(sizeof(IntegerString));
    yylval.int_string->type = INTTYPE_OCT;
    yylval.int_string->value = strdup(yytext);
    return OCT_STRING;
}

"0b"{bin_chars}("_"?{bin_chars})* {
    printf("[LEX] bin: %s\n", yytext);
    yylval.int_string = malloc(sizeof(IntegerString));
    yylval.int_string->type = INTTYPE_BIN;
    yylval.int_string->value = strdup(yytext);
    return BIN_STRING;
}


("+"|"-")?{dec_chars}("_"?{dec_chars})*("."{dec_chars}("_"?{dec_chars})*)?([eE]("+"|"-")?{dec_chars}("_"?{dec_chars})*)? {
    printf("[LEX] float: %s\n", yytext);
    yylval.float_string = strdup(yytext);
    return FLOAT_STRING;
}

"'"{utf8_chars_literal}*"'" {
    char* stripped = copy_quoted_string(yytext);
    printf("[LEX] literal string: '%s'\n", stripped);
    yylval.string = create_string(STRING_TYPE_LITERAL, stripped);
    free(stripped);
    return LITERAL_STRING;
}

"\""{utf8_chars_basic}*"\"" {
    char* stripped = copy_quoted_string(yytext);
    printf("[LEX] basic string: \"%s\"\n", stripped);
    yylval.string = create_string(STRING_TYPE_BASIC, stripped);
    free(stripped);
    return BASIC_STRING;
}

"'''"{utf8_chars_ml_literal}*"'''" {
    char* stripped = copy_triple_quoted_string(yytext);
    printf("[LEX] multiline literal string: '%s'\n", stripped);
    yylval.string = create_string(STRING_TYPE_MULTILINE_LITERAL, stripped);
    free(stripped);
    return MULTI_LITERAL_STRING;
}

{bare_chars}+ {
    printf("[LEX] bare string: %s\n", yytext);
    yylval.string = create_string(STRING_TYPE_BARE, yytext);
    return BARE_STRING; 
}

"\n" {};

. {};

%%

void init_buffer(void) {
    buffer_size = 64;
    if (string_buffer == NULL) {
        string_buffer = malloc(sizeof(char) * buffer_size);
    } else {
        string_buffer = realloc(string_buffer, sizeof(char) * buffer_size);
    }
    memset(string_buffer, 0, sizeof(char) * buffer_size);
    buffer_index = 0;
}

void append_buffer(char c) {
    assert(string_buffer != NULL);
    if (buffer_index >= buffer_size) {
        buffer_size *= 2;
        string_buffer = realloc(string_buffer, sizeof(char) * buffer_size);
    }
    buffer[buffer_index++] = c;
}

void append_buffer(const char* str) {
    assert(string_buffer != NULL);
    assert(str != NULL);
    int len = strlen(str);
    if (buffer_index + len >= buffer_size) {
        buffer_size = buffer_index + len + 1;
        string_buffer = realloc(string_buffer, sizeof(char) * buffer_size);
    }
    strncat(string_buffer, str, buffer_size);
}

const char* get_buffer(void) {
    return string_buffer;
}

char* duplicate_buffer(void) {
    assert(string_buffer != NULL);
    return strdup(string_buffer);
}

char* copy_strip_leading_trailing(const char* str, int count) {
    assert(count > 0);
    assert(strlen(str) >= count * 2);
    int len = strlen(str) - count * 2;
    char* copy = malloc(len);
    strncpy(copy, str + count, len);
    return copy;
}

char* copy_quoted_string(const char* quoted_string) {
    return copy_strip_leading_trailing(quoted_string, 1);
}

char* copy_triple_quoted_string(const char* quoted_string) {
    return copy_strip_leading_trailing(quoted_string, 3);
}

char* copy_comment(const char* comment_string) {
    int len = strlen(comment_string) - 1;
    char* copy = malloc(len);
    strncpy(copy, comment_string, len);
    return copy;
}


