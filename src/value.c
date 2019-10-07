#include "value.h"

static const char * get_type (const Value * value);

Value * value_from_scalar (Scalar * scalar)
{
	assert (scalar != NULL);
	Value * val = malloc (sizeof (Value));
	val->type = VALUE_SCALAR;
	val->data.scalar = scalar;
	return val;
}

Value * value_from_array (Array * array)
{
	assert (array != NULL);
	Value * val = malloc (sizeof (Value));
	val->type = VALUE_ARRAY;
	val->data.array = array;
	return val;
}

Value * value_from_inline_table (InlineTable * table)
{
	assert (table != NULL);
	Value * val = malloc (sizeof (Value));
	val->type = VALUE_INLINE_TABLE;
	val->data.table = table;
	return val;
}

void print_value (const Value * value)
{
	printf ("VALUE/%s", get_type (value));
	switch (value->type)
	{
	case VALUE_SCALAR:
		print_scalar (value->data.scalar);
		break;
	case VALUE_ARRAY:
		print_array (value->data.array);
		break;
	case VALUE_INLINE_TABLE:
		print_inline_table (value->data.table);
		break;
	default:
		assert (0);
	}
}

static const char * get_type (const Value * value)
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
