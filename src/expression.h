#ifndef EXPRESSION_H
#define EXPRESSION_H

typedef enum
{
	EXPRESSION_COMMENT,
	EXPRESSION_TABLE,
	EXPRESSION_KEY_PAIR
} ExpressionType;

typedef struct
{
	ExpressionType type;
	union {
		Scalar * comment;
		Table * table;
		KeyPair * keyPair;
	} expr;
} Expression;

Expression * expressionFromComment (Scalar *);
Expression * expressionFromTable (Table *);
Expression * expressionFromKeyPair (KeyPair *);

#endif // EXPRESSION_H
