#include "error.h"

extern int yylineno;

int yyerror (Expression ** root, const char * msg)
{
	free(*root);
	printf ("[ERROR] at line %d: %s\n", yylineno, msg);
	exit (1);
}
