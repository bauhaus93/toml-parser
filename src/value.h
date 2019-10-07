#ifndef VALUE_H
#define VALUE_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "scalar.h"

// Break include cycle by forward declarations
// #include "array.h"
// #include "inline_table.h"

#ifndef ARRAY_DEFINED
typedef struct _Array Array;
#define ARRAY_DEFINED
#endif
#ifndef INLINE_TABLE_DEFINED
typedef struct _InlineTable InlineTable;
#define INLINE_TABLE_DEFINED
#endif

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
	Scalar * comment;
} Value;

Value * valueFromScalar (Scalar *);
Value * valueFromArray (Array *);
Value * valueFromInlineTable (InlineTable *);
void addComment (Value *, Scalar *);
void printValue (const Value *);

extern void printArray (const Array *);
extern void printInlineTable (const InlineTable *);

#endif // VALUE_H
