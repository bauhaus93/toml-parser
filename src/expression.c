#include "expression.h"

Expression * expressionFromComment (Scalar * comment)
{
	assert (comment != NULL);
	Expression * expr = malloc (sizeof (Expression));
	expr->type = EXPRESSION_COMMENT;
	expr->expr.comment = comment;
	return expr;
}

Expression * expressionFromTable (Table * table)
{
	assert (table != NULL);
	Expression * expr = malloc (sizeof (Expression));
	expr->type = EXPRESSION_TABLE;
	expr->expr.table = table;
	return expr;
}

Expression * expressionFromKeyPair (KeyPair * keyPair)
{
	assert (keyPair != NULL);
	Expression * expr = malloc (sizeof (Expression));
	expr->type = EXPRESSION_KEY_PAIR;
	expr->expr.keyPair = keyPair;
	return expr;
}

void printExpression (const Expression * expr)
{
	assert (expr != NULL);
	switch (expr->type)
	{
	case EXPRESSION_COMMENT:
		printScalar (expr->expr.comment);
		break;
	case EXPRESSION_TABLE:
		printTable (expr->expr.table);
		break;
	case EXPRESSION_KEY_PAIR:
		printKeyPair (expr->expr.keyPair);
		break;
	default:
		assert (0);
	}
	printf ("\n");
}
