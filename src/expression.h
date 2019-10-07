#ifndef EXPRESSION_H
#define EXPRESSION_H

#include "key_pair.h"
#include "scalar.h"
#include "table.h"

typedef enum
{
	EXPRESSION_COMMENT,
	EXPRESSION_TABLE,
	EXPRESSION_KEY_PAIR
} ExpressionType;

typedef struct _Expression
{
	ExpressionType type;
	union {
		Scalar * comment;
		Table * table;
		KeyPair * keyPair;
	} expr;
	struct _Expression * next;
} Expression;

Expression * expressionFromComment (Scalar *);
Expression * expressionFromTable (Table *);
Expression * expressionFromKeyPair (KeyPair *);
Expression * pushExpression (Expression *, Expression *);

void printExpressions (const Expression *);
void printExpression (const Expression *);

#endif // EXPRESSION_H
