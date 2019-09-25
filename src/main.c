#include <stdio.h>

extern int yylex();
extern int yyparse();
int yyerror(const char *msg);

int main(int argc, char **argv) {
    yyparse();
    return 0;
}
