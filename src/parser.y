%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "error.h"
#include "key_pair.h"
#include "key.h"
#include "value.h"
#include "array.h"
#include "scalar.h"

extern int yylex();
extern int yyparse();

%}

%code requires {
    #include "key_pair.h"
    #include "key.h"
    #include "value.h"
    #include "array.h"
    #include "scalar.h"
}

%union {
    KeyPair*            key_pair;
    Key*                key;
    Value*              value;
    Array*              array;
    Scalar*             scalar;
}

%token <scalar> COMMENT
%token <scalar> DECIMAL
%token <scalar> HEXADECIMAL
%token <scalar> OCTAL
%token <scalar> BINARY
%token <scalar> FLOAT
%token <scalar> BOOLEAN
%token <scalar> SCALAR
%token <scalar> BARE_STRING
%token <scalar> LITERAL_STRING
%token <scalar> BASIC_STRING
%token <scalar> MULTI_LITERAL_STRING
%token <scalar> MULTI_BASIC_STRING
%token <scalar> OFFSET_DATETIME
%token <scalar> LOCAL_DATETIME
%token <scalar> LOCAL_DATE
%token <scalar> LOCAL_TIME
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
%type <scalar> IntegerScalar
%type <scalar> BooleanScalar
%type <scalar> FloatScalar
%type <scalar> StringScalar
%type <scalar> DateScalar


%start TomlFile

%%

TomlFile   : Lines

Lines   :
        | COMMENT Lines { printf("[PARSER] Comment: "); print_scalar($1); }
        | KeyValue Lines { print_key_pair($1); }
        ;

KeyValue    : Key EQUAL Value { $$ = make_pair($1, $3); }

Key     :   SimpleKey { $$ = $1; }
        |   DottedKey { $$ = $1; }
        ;

SimpleKey   :   BARE_STRING { $$ = key_from_scalar($1); }
            |   LITERAL_STRING { $$ = key_from_scalar($1); }
            |   BASIC_STRING { $$ = key_from_scalar($1); }
            ;

DottedKey   :   SimpleKey DOT Key { append_key($1, $3); $$ = $1; }


Value   :   Scalar { $$ = value_from_scalar($1); }
        |   BRACKETS_OPEN Array BRACKETS_CLOSE { $$ = value_from_array($2); }


Array   :   Scalar COMMA Array { Array* a = array_from_scalar($1); append_element(a, $3); $$ = a; }
        |   Scalar { $$ = array_from_scalar($1); }

Scalar  :   IntegerScalar { $$ = $1; }
        |   BooleanScalar { $$ = $1; }
        |   FloatScalar { $$ = $1; }
        |   StringScalar { $$ = $1; }
        |   DateScalar { $$ = $1; }
        ;


IntegerScalar   :   DECIMAL { $$ = $1; }
                |   HEXADECIMAL { $$ = $1; }
                |   OCTAL { $$ = $1; }
                |   BINARY { $$ = $1; }
                ;

BooleanScalar   :   BOOLEAN { $$ = $1; }
                ;

FloatScalar     :   FLOAT { $$ = $1; }
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
