#include <stdio.h>

extern int yylex();
extern int yyparse();

int main(int argc, char **argv) {
    yyparse();
    return 0;
}
