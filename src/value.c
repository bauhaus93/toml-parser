#include "value.h"

static const char * getType (const Value * value);

Value * valueFromScalar (Scalar * scalar)
{
	assert (scalar != NULL);
	Value * val = malloc (sizeof (Value));
	val->type = VALUE_SCALAR;
	val->data.scalar = scalar;
	return val;
}

Value * valueFromArray (Array * array)
{
	assert (array != NULL);
	Value * val = malloc (sizeof (Value));
	val->type = VALUE_ARRAY;
	val->data.array = array;
	return val;
}

Value * valueFromInlineTable (InlineTable * table)
{
	assert (table != NULL);
	Value * val = malloc (sizeof (Value));
	val->type = VALUE_INLINE_TABLE;
	val->data.table = table;
	return val;
}

void printValue (const Value * value)
{
	printf ("VALUE/%s", getType (value));
	switch (value->type)
	{
	case VALUE_SCALAR:
		printScalar (value->data.scalar);
		break;
	case VALUE_ARRAY:
		printArray (value->data.array);
		break;
	case VALUE_INLINE_TABLE:
		printInlineTable (value->data.table);
		break;
	default:
		assert (0);
	}
}

static const char * getType (const Value * value)
{
	assert (value != NULL);
	switch (value->type)
	{
	case VALUE_SCALAR:
		return "SCALAR";
	case VALUE_ARRAY:
		return "ARRAY";
	case VALUE_INLINE_TABLE:
		return "INLINE_TABLE";
	default:
		assert (0);
	}
}
