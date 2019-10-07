#include <stdio.h>

#include "expression.h"

extern int yyparse (Expression **);

int main ()
{
	Expression * root = NULL;
	yyparse (&root);
	printExpressions(root);
	return 0;
}
