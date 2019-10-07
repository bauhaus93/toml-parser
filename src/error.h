#ifndef ERROR_H
#define ERROR_H

#include <stdio.h>
#include <stdlib.h>

#include "expression.h"

int yyerror (Expression ** root, const char * msg);

#endif // ERROR_H
