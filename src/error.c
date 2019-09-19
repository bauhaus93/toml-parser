#include "error.h"

int yyerror(const char* msg) {
    printf("[ERROR] %s\n", msg);
    exit(1);
}
