#include "array.h"

static void print_array_element (const Array *);

Array * array_from_value (Value * value)
{
	Array * array = malloc (sizeof (Array));
	array->element = value;
	array->next = NULL;
	return array;
}

Array * push_value (Array * root, Value * value)
{
	assert (root != NULL);
	assert (value != NULL);
	Array * a = array_from_value (value);
	a->next = root;
	return a;
}

void print_array (const Array * array)
{
	assert (array != NULL);
	printf (" [ ");
	print_array_element (array);
	printf (" ] ");
}

static void print_array_element (const Array * array)
{
	assert (array != NULL);
	print_value (array->element);
	if (array->next != NULL)
	{
		printf (", ");
		print_array_element (array->next);
	}
}
