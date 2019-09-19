#ifndef INTEGER_H 
#define INTEGER_H

typedef enum {
    INTTYPE_DEC,
    INTTYPE_HEX,
    INTTYPE_OCT,
    INTTYPE_BIN
} IntegerType;

typedef struct {
    IntegerType type;
    char*       value;
} IntegerString;

#endif // INTEGER_H

