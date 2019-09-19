%{

#include <stdio.h>
#include "parser.h"

#include "integer.h"
#include "value.h"

%}

%option yylineno
%option noyywrap

alpha [a-zA-Z]
digit [0-9]
alnum {alpha}|{digit}

ascii_chars [.-_]|{alnum}
dec_chars {digit}
hex_chars [0-9a-fA-F]
oct_chars [0-8]
bin_chars [01]

whitespace [ \t]

%%


"="     return EQUAL;
"'"     return QUOTATION_SINGLE;
"\""    return QUOTATION_DOUBLE;
"."     return DOT;

"#"({alnum}|{whitespace})*(\n|<EOF>) {
    printf("[LEX] comment: %s", yytext);
    yylval.string = strdup(yytext);
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

{ascii_chars}+ {
    printf("[LEX] ascii: '%s'\n", yytext);
    yylval.ascii_string = strdup(yytext);
    return ASCII_STRING; 
}

[^ \t\n]+ {
    printf("[LEX] utf8: %s\n", yytext);
    yylval.string = strdup(yytext);
    return UTF8_STRING;
}

. ;

%%
