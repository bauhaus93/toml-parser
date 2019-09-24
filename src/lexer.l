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
static void append_buffer_str(const char* str);
static const char* get_buffer(void);
static char* duplicate_buffer(void);

static char* string_buffer = NULL;
static int buffer_index = 0;
static int buffer_size = 0;

%}

%option yylineno
%option noyywrap

%s SC_BASIC
%s SC_LITERAL
%s SC_ML_BASIC
%s SC_ML_LITERAL
%s SC_COMMENT

alpha [a-zA-Z]
digit [0-9]
alnum {alpha}|{digit}

bare_chars [.-_]|{alnum}
dec_chars {digit}
dec_nzero [1-9]
hex_chars [0-9a-fA-F]
oct_chars [0-8]
bin_chars [01]

%{
    /* Source for patterns:
       https://www.w3.org/2005/03/23-lex-U#utf8toot
    */
%}
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

ascii_chars_literal [\x09\x20-\x26\x28-\x7E]
ascii_chars_basic [\x09\x20\x21\x23-\x5B\x5D-\x7E]
basic_escaped [btnfr"\\]
basic_escaped_illegal [^btnfr"\\uU]

utf8_non_ascii_chars {utf8_2byte}|{utf8_3byte}|{utf8_4byte}

utf8_chars_comment {ascii_chars_literal}|{utf8_non_ascii_chars}
utf8_chars_literal {ascii_chars_literal}|{utf8_non_ascii_chars}
utf8_chars_basic {ascii_chars_basic}|{utf8_non_ascii_chars}

whitespace [\t ]
newline (\r\n)|\n

decimal {dec_nzero}("_"?{dec_chars})*
decimal_pm [+-]?{decimal}

%%

<INITIAL>"="        return EQUAL;
<INITIAL>"."        return DOT;

<INITIAL>"#"        { init_buffer();  BEGIN(SC_COMMENT); }
<INITIAL>"'"        { init_buffer();  BEGIN(SC_LITERAL); }
<INITIAL>"\""       { init_buffer();  BEGIN(SC_BASIC); } 
<INITIAL>"'''"      { init_buffer();  BEGIN(SC_ML_LITERAL); }
<INITIAL>"\"\"\""   { init_buffer();  BEGIN(SC_ML_BASIC); }

<INITIAL>{decimal_pm} {
    printf("[LEX] dec: %s\n", yytext);
    yylval.integer = malloc(sizeof(Integer));
    yylval.integer->type = INTTYPE_DEC;
    yylval.integer->value = strdup(yytext);
    return DEC_STRING;
}

<INITIAL>("+"|"-")?"0" {
    printf("[LEX] dec: %s\n", yytext);
    yylval.integer = malloc(sizeof(Integer));
    yylval.integer->type = INTTYPE_DEC;
    yylval.integer->value = strdup(yytext);
    return DEC_STRING;
}

<INITIAL>"0x"{hex_chars}("_"?{hex_chars})* {
    printf("[LEX] hex: %s\n", yytext);
    yylval.integer = malloc(sizeof(Integer));
    yylval.integer->type = INTTYPE_HEX;
    yylval.integer->value = strdup(yytext);
    return HEX_STRING;
}

<INITIAL>"0o"{oct_chars}("_"?{oct_chars})* {
    printf("[LEX] oct: %s\n", yytext);
    yylval.integer = malloc(sizeof(Integer));
    yylval.integer->type = INTTYPE_OCT;
    yylval.integer->value = strdup(yytext);
    return OCT_STRING;
}

<INITIAL>"0b"{bin_chars}("_"?{bin_chars})* {
    printf("[LEX] bin: %s\n", yytext);
    yylval.integer = malloc(sizeof(Integer));
    yylval.integer->type = INTTYPE_BIN;
    yylval.integer->value = strdup(yytext);
    return BIN_STRING;
}

<INITIAL>{decimal_pm}("."{decimal})?([eE]{decimal_pm})? {
    printf("[LEX] float: %s\n", yytext);
    yylval.float_string = strdup(yytext);
    return FLOAT_STRING;
}

<INITIAL>{bare_chars}+ {
    printf("[LEX] bare string: %s\n", yytext);
    yylval.string = create_string(STRING_TYPE_BARE, yytext);
    return BARE_STRING; 
}

<INITIAL>{whitespace}|{newline} {}

<SC_LITERAL,SC_BASIC,SC_ML_LITERAL,SC_ML_BASIC><<EOF>> {
    printf("[LEX ERROR] EOF, but in some string state\n");
    exit(1);
}

<SC_COMMENT>{newline}|<EOF> {
    printf("[LEX] comment: %s\n", get_buffer());
    yylval.string = create_string(STRING_TYPE_COMMENT, get_buffer());
    BEGIN(INITIAL);
    return COMMENT;
}
<SC_COMMENT>{utf8_chars_comment}+ {
    append_buffer_str(yytext);
}

<SC_LITERAL>"'" {
    printf("[LEX] literal: %s\n", get_buffer());
    yylval.string = create_string(STRING_TYPE_LITERAL, get_buffer());
    BEGIN(INITIAL);
    return LITERAL_STRING;
}

<SC_ML_LITERAL>"'''" {
    printf("[LEX] multiline literal: %s\n", get_buffer());
    yylval.string = create_string(STRING_TYPE_MULTILINE_LITERAL, get_buffer());
    BEGIN(INITIAL);
    return MULTI_LITERAL_STRING;
}

<SC_LITERAL,SC_ML_LITERAL>{utf8_chars_literal}+ {
    append_buffer_str(yytext);
}

<SC_ML_LITERAL>"'" {
    append_buffer('\'');
}

<SC_ML_LITERAL>{newline} {
    append_buffer_str(yytext);
}

<SC_BASIC>"\"" {
    printf("[LEX] basic: %s\n", get_buffer());
    yylval.string = create_string(STRING_TYPE_BASIC, get_buffer());
    BEGIN(INITIAL);
    return BASIC_STRING;
}

<SC_ML_BASIC>"\"\"\"" {
    printf("[LEX] multiline basic: %s\n", get_buffer());
    yylval.string = create_string(STRING_TYPE_MULTILINE_BASIC, get_buffer());
    BEGIN(INITIAL);
    return MULTI_BASIC_STRING;
}

<SC_BASIC,SC_ML_BASIC>{utf8_chars_basic}+ {
    append_buffer_str(yytext);
}
<SC_BASIC,SC_ML_BASIC>"\\"{basic_escaped} {
    append_buffer_str(yytext);
}
<SC_BASIC,SC_ML_BASIC>"\\"(u|U)({hex_chars}{4,4}|{hex_chars}{8,8}) {
    append_buffer_str(yytext);
}

<SC_BASIC,SC_ML_BASIC>"\\"{basic_escaped_illegal} {
    printf("[LEX] Illegal escape sequence: %s\n", yytext);
    exit(1);
}

%{ // TODO: heading empty line handling %}

<SC_ML_BASIC>{newline} {
    append_buffer_str(yytext);
}

. {
    printf("[LEX] Unexpected sequence: %s\n", yytext);
    exit(1);
}

%%

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

static void append_buffer_str(const char* str) {
    assert(string_buffer != NULL);
    assert(str != NULL);
    int len = strlen(str);
    if (buffer_index + len >= buffer_size) {
        buffer_size = buffer_index + len + 1;
        string_buffer = realloc(string_buffer, sizeof(char) * buffer_size);
    }
    strncat(string_buffer, str, buffer_size);
    buffer_index = strlen(string_buffer);
}

static const char* get_buffer(void) {
    return string_buffer;
}

static char* duplicate_buffer(void) {
    assert(string_buffer != NULL);
    return strdup(string_buffer);
}
