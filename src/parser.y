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
%token <string> LITERAL_STRING
%token <string> BASIC_STRING
%token <string> MULTI_LITERAL_STRING
%token <string> MULTI_BASIC_STRING
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
        | COMMENT Lines { printf("[PARSER] Comment: %d\n", $1->type); }
        | KeyValue Lines
        ;
KeyValue    : Key EQUAL Value { printf("[PARSER] K/V: %d -> %d\n", $1->type, $3->type); }

Key     :   BARE_STRING { $$ = $1; }
        |   LITERAL_STRING { $$ = $1; }
        |   BASIC_STRING { $$ = $1; }
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

ValueString     :   LITERAL_STRING { $$ = $1; }
                |   BASIC_STRING { $$ = $1; }
                |   MULTI_LITERAL_STRING { $$ = $1; }
                |   MULTI_BASIC_STRING { $$ = $1; }
                ;

%%
