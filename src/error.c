#include "error.h"

extern int yylineno;

int yyerror(const char *msg) {
    printf("[ERROR] at line %d: %s\n", yylineno, msg);
    exit(1);
}
