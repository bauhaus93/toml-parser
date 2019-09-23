%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "error.h"
#include "integer.h"
#include "strings.h"
#include "value.h"

extern int yylex();
extern int yyparse();

%}

%code requires {
    #include "value.h"
    #include "integer.h"
    #include "string.h"
}

%union {
    Value*          value;
    IntegerString*  int_string;
    String*         string;
    char*           float_string;
}

%token <string> COMMENT
%token <int_string> DEC_STRING
%token <int_string> HEX_STRING
%token <int_string> OCT_STRING
%token <int_string> BIN_STRING
%token <float_string> FLOAT_STRING
%token <value> VALUE
%token <string> BARE_STRING
%token <string> SINGLE_QUOTE_STRING
%token <string> DOUBLE_QUOTE_STRING
%token EQUAL
%token DOT

%type <string> Key
%type <value> Value
%type <int_string> ValueInteger
%type <float_string> ValueFloat
%type <string> ValueString

%destructor { destroy_value($$); } <value>

%start Root

%%

Root    : Lines

Lines   :
        | COMMENT Lines { printf("[PARSER] Comment: %s", $1); }
        | KeyValue Lines
        ;
KeyValue    : Key EQUAL Value { printf("[PARSER] K/V: %d -> %d\n", $1->type, $3->type); }

Key     :   SINGLE_QUOTE_STRING { $$ = $1; }
        |   DOUBLE_QUOTE_STRING { $$ = $1; }
        |   BARE_STRING { $$ = $1; }
        ;

Value   :   ValueInteger { $$ = from_integer($1); }
        |   ValueFloat { $$ = from_float($1); }
        |   ValueString { $$ = from_string($1); }
        ;


ValueInteger    :   DEC_STRING { $$ = $1; }
                |   HEX_STRING { $$ = $1; }
                |   OCT_STRING { $$ = $1; }
                |   BIN_STRING { $$ = $1; }
                ;

ValueFloat      :   FLOAT_STRING { $$ = $1; }
                ;

ValueString     :   SINGLE_QUOTE_STRING { $$ = $1; }
                |   DOUBLE_QUOTE_STRING { $$ = $1; }
                ;

%%
