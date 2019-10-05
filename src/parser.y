%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "error.h"
#include "key_pair.h"
#include "key.h"
#include "value.h"
#include "array.h"
#include "scalar/scalar.h"
#include "scalar/integer_scalar.h"
#include "scalar/float_scalar.h"
#include "scalar/string_scalar.h"

extern int yylex();
extern int yyparse();

%}

%code requires {
    #include "key_pair.h"
    #include "key.h"
    #include "value.h"
    #include "array.h"
    #include "scalar/scalar.h"
    #include "scalar/integer_scalar.h"
    #include "scalar/float_scalar.h"
    #include "scalar/string_scalar.h"
    #include "scalar/date_scalar.h"
}

%union {
    KeyPair*            key_pair;
    Key*                key;
    Value*              value;
    Array*              array;
    Scalar*             scalar;
    IntegerScalar*      integer_scalar;
    FloatScalar*        float_scalar;
    StringScalar*       string_scalar;
    DateScalar*         date_scalar;
}

%token <string_scalar> COMMENT
%token <integer_scalar> DEC_STRING
%token <integer_scalar> HEX_STRING
%token <integer_scalar> OCT_STRING
%token <integer_scalar> BIN_STRING
%token <float_scalar> FLOAT_STRING
%token <scalar> SCALAR
%token <string_scalar> BARE_STRING
%token <string_scalar> LITERAL_STRING
%token <string_scalar> BASIC_STRING
%token <string_scalar> MULTI_LITERAL_STRING
%token <string_scalar> MULTI_BASIC_STRING
%token <date_scalar> OFFSET_DATETIME
%token <date_scalar> LOCAL_DATETIME
%token <date_scalar> LOCAL_DATE
%token <date_scalar> LOCAL_TIME
%token EQUAL
%token DOT
%token COMMA
%token BRACKETS_OPEN;
%token BRACKETS_CLOSE;

%type <key_pair> KeyValue
%type <key> Key
%type <key> SimpleKey
%type <key> DottedKey
%type <value> Value
%type <array> Array
%type <scalar> Scalar
%type <integer_scalar> IntegerScalar
%type <float_scalar> FloatScalar
%type <string_scalar> StringScalar
%type <date_scalar> DateScalar

%start TomlFile

%%

TomlFile   : Lines

Lines   :
        | COMMENT Lines { printf("[PARSER] Comment: "); print_scalar_string($1); }
        | KeyValue Lines { print_key_pair($1); }
        ;

KeyValue    : Key EQUAL Value { $$ = make_pair($1, $3); }

Key     :   SimpleKey { $$ = $1; }
        |   DottedKey { $$ = $1; }
        ;

SimpleKey   :   BARE_STRING { $$ = key_from_string($1); }
            |   LITERAL_STRING { $$ = key_from_string($1); }
            |   BASIC_STRING { $$ = key_from_string($1); }
            ;

DottedKey   :   SimpleKey DOT Key { append_key($1, $3); $$ = $1; }


Value   :   Scalar { $$ = value_from_scalar($1); }
        |   BRACKETS_OPEN Array BRACKETS_CLOSE { $$ = value_from_array($2); }


Array   :   Scalar COMMA Array { Array* a = array_from_scalar($1); append_element(a, $3); $$ = a; }
        |   Scalar { $$ = array_from_scalar($1); }

Scalar  :   IntegerScalar { $$ = from_integer($1); }
        |   FloatScalar { $$ = from_float($1); }
        |   StringScalar { $$ = from_string($1); }
        |   DateScalar { $$ = from_date($1); }
        ;


IntegerScalar    :  DEC_STRING { $$ = $1; }
                |   HEX_STRING { $$ = $1; }
                |   OCT_STRING { $$ = $1; }
                |   BIN_STRING { $$ = $1; }
                ;

FloatScalar     :   FLOAT_STRING { $$ = $1; }
                ;

StringScalar    :   LITERAL_STRING { $$ = $1; }
                |   BASIC_STRING { $$ = $1; }
                |   MULTI_LITERAL_STRING { $$ = $1; }
                |   MULTI_BASIC_STRING { $$ = $1; }
                ;

DateScalar      :   OFFSET_DATETIME { $$ = $1; }
                |   LOCAL_DATETIME { $$ = $1; }
                |   LOCAL_DATE { $$ = $1; }
                |   LOCAL_TIME { $$ = $1; }
                ;
%%
