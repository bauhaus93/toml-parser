#include "expression.h"

Expression * expressionFromComment (Scalar * comment)
{
	assert (comment != NULL);
	Expression * expr = malloc (sizeof (Expression));
	expr->type = EXPRESSION_COMMENT;
	expr->expr.comment = comment;
	expr->next = NULL;
	return expr;
}

Expression * expressionFromTable (Table * table)
{
	assert (table != NULL);
	Expression * expr = malloc (sizeof (Expression));
	expr->type = EXPRESSION_TABLE;
	expr->expr.table = table;
	expr->next = NULL;
	return expr;
}

Expression * expressionFromKeyPair (KeyPair * keyPair)
{
	assert (keyPair != NULL);
	Expression * expr = malloc (sizeof (Expression));
	expr->type = EXPRESSION_KEY_PAIR;
	expr->expr.keyPair = keyPair;
	expr->next = NULL;
	return expr;
}

Expression * pushExpression (Expression * top, Expression * element)
{
	assert (element != NULL);
	if (element->next != NULL)
	{
		Expression * newTop = element;
		while (element->next != NULL)
		{
			element = element->next;
		}
		element->next = top;
		return newTop;
	}
	else
	{
		element->next = top;
		return element;
	}
}

void printExpressions (const Expression * expr)
{
	printExpression (expr);
	if (expr->next != NULL)
	{
		printExpressions (expr->next);
	}
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
