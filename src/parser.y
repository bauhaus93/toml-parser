%{

#include <stdio.h>
#include <stdlib.h>

#include "error.h"
#include "integer.h"
#include "value.h"

extern int yylex();
extern int yyparse();

%}

%union {
    Value* value;
    IntegerString* int_string;
    char*   float_string;
    char*   ascii_string;
    char*   string;
}

%token <string> COMMENT
%token <int_string> DEC_STRING
%token <int_string> HEX_STRING
%token <int_string> OCT_STRING
%token <int_string> BIN_STRING
%token <float_string> FLOAT_STRING
%token <value> VALUE
%token <ascii_string> ASCII_STRING
%token <string> UTF8_STRING
%token EQUAL
%token QUOTATION_SINGLE
%token QUOTATION_DOUBLE
%token DOT

%start Root

%%

Root    : Lines

Lines   :
        | COMMENT Lines { printf("Comment: %s", $1); }
        | KeyValue Lines
        ;
KeyValue    : Key EQUAL Value { printf("[PARSER] K/V: %s -> %s", $<string>1, $<string>3); }

Key     :   QUOTATION_SINGLE UTF8_STRING QUOTATION_SINGLE { $<string>$ = $2; }
        |   QUOTATION_DOUBLE UTF8_STRING QUOTATION_DOUBLE { $<string>$ = $2; }
        |   ASCII_STRING { $<string>$ = $1; }
        ;

Value   :   ValueInteger { $<value>$ = from_integer($<int_string>1); }
        |   ValueFloat { $<value>$ = from_float($<float_string>1); }
        |   ValueString { $<value>$ = from_string($<string>1); }
        ;


ValueInteger    :   DEC_STRING { $<int_string>$ = $1; }
                |   HEX_STRING { $<int_string>$ = $1; }
                |   OCT_STRING { $<int_string>$ = $1; }
                |   BIN_STRING { $<int_string>$ = $1; }
                ;

ValueFloat      :   FLOAT_STRING { $<float_string>$ = $1; }
                ;

ValueString     :   ASCII_STRING { $<string>$ = $1; }
                |   UTF8_STRING { $<string>$ = $1; }
                ;

%%
