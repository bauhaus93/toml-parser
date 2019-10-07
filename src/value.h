#ifndef VALUE_H
#define VALUE_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "scalar.h"

// Break include cycle by forward declarations
// #include "array.h"
// #include "inline_table.h"
typedef struct _Array Array;
typedef struct _InlineTable InlineTable;

typedef enum
{
	VALUE_SCALAR,
	VALUE_ARRAY,
	VALUE_INLINE_TABLE
} ValueType;

typedef struct
{
	ValueType type;
	union {
		Scalar * scalar;
		Array * array;
		InlineTable * table;
	} data;
} Value;

Value * value_from_scalar (Scalar *);
Value * value_from_array (Array *);
Value * value_from_inline_table (InlineTable *);
void print_value (const Value *);

extern void print_array (const Array *);
extern void print_inline_table (const InlineTable *);

#endif // VALUE_H
