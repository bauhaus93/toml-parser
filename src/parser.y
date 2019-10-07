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
#include "value.h"
#include "table.h"
#include "inline_table.h"

extern int yylex();
extern int yyparse();

%}

%code requires {
    #include "key_pair.h"
    #include "key.h"
    #include "value.h"
    #include "array.h"
    #include "scalar.h"
    #include "table.h"
    #include "inline_table.h"
}

%union {
    KeyPair*            keyPair;
    Key*                key;
    Value*              value;
    Array*              array;
    Scalar*             scalar;
    Table*              table;
    InlineTable*        inlineTable;
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
%token BRACKETS_OPEN
%token BRACKETS_CLOSE
%token CURLY_OPEN
%token CURLY_CLOSE

%type <keyPair> KeyPair
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
%type <table> Table
%type <inlineTable> InlineTable

%start TomlFile

%%

TomlFile   : Lines

Lines   :
        | COMMENT Lines { printScalar($1); printf("\n"); }
        | Table Comment Lines
        | KeyPair Comment Lines { printKeyPair($1); printf("\n"); }
        ;

Comment :
        |   COMMENT { printScalar($1); }
        ;

Table   :   BRACKETS_OPEN Key BRACKETS_CLOSE { printf("[PARSER] table: "); printKey($2); }

KeyPair    : Key EQUAL Value { $$ = makePair($1, $3); }

Key     :   SimpleKey { $$ = $1; }
        |   DottedKey { $$ = $1; }
        ;

SimpleKey   :   BARE_STRING { $$ = keyFromScalar($1); }
            |   LITERAL_STRING { $$ = keyFromScalar($1); }
            |   BASIC_STRING { $$ = keyFromScalar($1); }
            ;

DottedKey   :   SimpleKey DOT Key { appendKey($1, $3); $$ = $1; }


Value   :   Scalar { $$ = valueFromScalar($1); }
        |   CURLY_OPEN InlineTable CURLY_CLOSE { $$ = valueFromInlineTable($2); }
        |   BRACKETS_OPEN Array BRACKETS_CLOSE { $$ = valueFromArray($2); }


InlineTable :   KeyPair COMMA InlineTable { $$ = pushPair($3, $1); }
            |   KeyPair { $$ = inlineTableFromKeyPair($1); }


Array   :   Value COMMA Array { $$ = pushValue($3, $1); }
        |   Value { $$ = arrayFromValue($1); }

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
