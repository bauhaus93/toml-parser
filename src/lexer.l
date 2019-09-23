%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.h"
#include "integer.h"
#include "value.h"
#include "strings.h"

char* copy_quoted_string(const char* quoted_string);

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
utf8_3byte (({utf8_chars_pat5}{utf8_chars_pat3})|({utf8_chars_pat6}{utf8_chars_pat1})|({utf8_chars_pat7}{utf8_chars_pat4})|({utf8_chars_pat8}{utf8_chars_pat1})){utf8_chars_pat1}
utf8_4byte (({utf8_chars_pat9}{utf8_chars_pat12})|({utf8_chars_pat10}{utf8_chars_pat1})|({utf8_chars_pat11}{utf8_chars_pat13})){utf8_chars_pat1}{utf8_chars_pat1}


ascii_no_nl [\x00-\x09\x0B-\x7F]
ascii_chars_sq [\x00-\x09\x0B-\x26\x28-\x7F]

ascii_chars_dq_literal [\x00-\x07\x0B\x0E-\x21\x23-\x5B\x5D-\x7F]
ascii_chars_dq_special \x5C[\x08-\x0A\x0C\x0D\x22\x5C]
ascii_chars_dq_special_u \x5C(u|U)([0-9]{4,4}|[0-9]{8,8})
ascii_chars_dq {ascii_chars_dq_literal}|{ascii_chars_dq_special}|{ascii_chars_dq_special_u}

utf8_non_ascii_chars {utf8_2byte}|{utf8_3byte}|{utf8_4byte}

utf8_chars {ascii_chars}|{utf8_non_ascii_chars}
utf8_chars_no_newline {ascii_no_nl}|{utf8_non_ascii_chars}
utf8_chars_sq {ascii_chars_sq}|{utf8_non_ascii_chars}
utf8_chars_dq {ascii_chars_dq}|{utf8_non_ascii_chars}

%%

"="     return EQUAL;
"."     return DOT;

"#"{utf8_chars_no_newline}*(\n|<EOF>) {
    printf("[LEX] comment: %s", yytext);
    yylval.string = create_string(STRING_TYPE_COMMENT, yytext);
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

"'"{utf8_chars_sq}*"'" {
    char* stripped = copy_quoted_string(yytext);
    printf("[LEX] single quote string: '%s'\n", stripped);
    yylval.string = create_string(STRING_TYPE_SINGLE_QUOTE, stripped);
    free(stripped);
    return SINGLE_QUOTE_STRING;
}

"\""{utf8_chars_dq}*"\"" {
    char* stripped = copy_quoted_string(yytext);
    printf("[LEX] double quote string: \"%s\"\n", stripped);
    yylval.string = create_string(STRING_TYPE_DOUBLE_QUOTE, stripped);
    free(stripped);
    return DOUBLE_QUOTE_STRING;
}

{bare_chars}+ {
    printf("[LEX] bare string: %s\n", yytext);
    yylval.string = create_string(STRING_TYPE_BARE, yytext);
    return BARE_STRING; 
}

%%

char* copy_quoted_string(const char* quoted_string) {
    int len = strlen(quoted_string) - 2;
    char* copy = malloc(len);
    strncpy(copy, quoted_string + 1, len);
    return copy;
}


