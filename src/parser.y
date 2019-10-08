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

%}

%code requires {
	#include "expression.h"
	#include "key_pair.h"
	#include "key.h"
	#include "value.h"
	#include "array.h"
	#include "scalar.h"
	#include "table.h"
	#include "inline_table.h"
}

%union {
	Expression*	expression;
	KeyPair*    	keyPair;
	Key*        	key;
	Value*      	value;
	Array*      	array;
	Scalar*     	scalar;
	Table*      	table;
	InlineTable*	inlineTable;
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
%token NEWLINE
%token EQUAL
%token DOT
%token COMMA
%token BRACKETS_OPEN
%token BRACKETS_CLOSE
%token CURLY_OPEN
%token CURLY_CLOSE

%type <expression> TomlFile
%type <expression> Expressions
%type <expression> Expression
%type <keyPair> KeyPair
%type <key> Key
%type <key> SimpleKey
%type <key> DottedKey
%type <value> Value
%type <array> Array
%type <array> ArrayList
%type <scalar> Scalar
%type <scalar> IntegerScalar
%type <scalar> BooleanScalar
%type <scalar> FloatScalar
%type <scalar> StringScalar
%type <scalar> DateScalar
%type <table> Table
%type <table> TableSimple
%type <table> TableArray
%type <inlineTable> InlineTable
%type <inlineTable> InlineTableList
%type <scalar> CommentNewline

%start TomlFile

%parse-param { Expression** root }

%define parse.error verbose

%%

TomlFile   : 	Expressions { $$ = $1; *root = $$; }

Expressions	:	Expressions NEWLINE Expression { $$ = pushExpression($1, $3); }
		| 	Expressions NEWLINE { $$ = $1; }
		|	Expression { $$ = $1; }
		|	{ $$ = NULL; }	
		;

Expression	:	COMMENT { $$ = expressionFromComment($1); }
		| 	Table { $$ = expressionFromTable($1); }
		| 	KeyPair { $$ = expressionFromKeyPair($1); }
		|	Table COMMENT {
				Expression * t = expressionFromTable($1);
				Expression * c = expressionFromComment($2);
				$$ = pushExpression(c, t);
			}
		|	KeyPair COMMENT {
				Expression * k = expressionFromKeyPair($1);
				Expression * c = expressionFromComment($2);
				$$ = pushExpression(c, k);
			}
		;

Table	:	TableSimple { $$ = $1; }
	|	TableArray { $$ = $1; }	
	;

TableSimple	:	BRACKETS_OPEN Key BRACKETS_CLOSE { $$ = createTable(TABLE_SIMPLE, $2); }
		;

TableArray	:	BRACKETS_OPEN BRACKETS_OPEN Key BRACKETS_CLOSE BRACKETS_CLOSE { $$ = createTable(TABLE_ARRAY, $3); }
		;
KeyPair	:	Key EQUAL Value { $$ = makePair($1, $3); }

Key     :   	SimpleKey { $$ = $1; }
        |   	DottedKey { $$ = $1; }
        ;

SimpleKey	:	BARE_STRING { $$ = keyFromScalar($1); }
            	|	LITERAL_STRING { $$ = keyFromScalar($1); }
            	|	BASIC_STRING { $$ = keyFromScalar($1); }
            	;

DottedKey	:	SimpleKey DOT Key { appendKey($1, $3); $$ = $1; }


Value   :	Scalar { $$ = valueFromScalar($1); }
        |	InlineTable { $$ = valueFromInlineTable($1); }
	|	Array { $$ = valueFromArray($1); }
	;

InlineTable	:	CURLY_OPEN InlineTableList CURLY_CLOSE { $$ = $2; }
            	|	CURLY_OPEN CURLY_CLOSE { $$ = NULL; }	
		;

InlineTableList	:	KeyPair { $$ = inlineTableFromKeyPair($1); }
		|	COMMA KeyPair { $$ = inlineTableFromKeyPair($2); }
		|	InlineTableList COMMA KeyPair { $$ = pushPair($1, $3); }
		;
Array	:	BRACKETS_OPEN ArrayList CommentNewline BRACKETS_CLOSE { $$ = $2; }
	|	BRACKETS_OPEN ArrayList COMMA CommentNewline BRACKETS_CLOSE { $$ = $2; }
	|	BRACKETS_OPEN BRACKETS_CLOSE { $$ = NULL; }
	;

ArrayList	:	CommentNewline Value { $$ = arrayFromValue($2); addComment($2, $1); }
		|	COMMA CommentNewline Value { $$ = arrayFromValue($3); addComment($3, $2); }
		|	ArrayList COMMA CommentNewline Value  { $$ = pushValue($1, $4); addComment($4, $3); }

CommentNewline	:	CommentNewline NEWLINE { $$ = NULL; }
		|	CommentNewline COMMENT NEWLINE { $$ = $1; }
		|	{ $$ = NULL; }
		;

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
