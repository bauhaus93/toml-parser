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
    Integer*        integer;
    String*         string;
    Float*          float_val;
}

%token <string> COMMENT
%token <integer> DEC_STRING
%token <integer> HEX_STRING
%token <integer> OCT_STRING
%token <integer> BIN_STRING
%token <float_val> FLOAT_STRING
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
%type <integer> ValueInteger
%type <float_val> ValueFloat
%type <string> ValueString

%destructor { destroy_value($$); } <value>

%start Root

%%

Root    : Lines

Lines   :
        | COMMENT Lines { printf("[PARSER] Comment: %d\n", $1->type); }
        | KeyValue Lines
        ;
KeyValue    : Key EQUAL Value {
    printf("[PARSER] K/V:\n");
    print_info_string($1);
    print_info_value($3);
}

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
