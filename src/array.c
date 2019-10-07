#include "array.h"

static void printArrayElement (const Array *);

Array * arrayFromValue (Value * value)
{
	Array * array = malloc (sizeof (Array));
	array->element = value;
	array->next = NULL;
	return array;
}

Array * pushValue (Array * root, Value * value)
{
	assert (root != NULL);
	assert (value != NULL);
	Array * a = arrayFromValue (value);
	a->next = root;
	return a;
}

void printArray (const Array * array)
{
	assert (array != NULL);
	printf (" [ ");
	printArrayElement (array);
	printf (" ] ");
}

static void printArrayElement (const Array * array)
{
	assert (array != NULL);
	printValue (array->element);
	if (array->next != NULL)
	{
		printf (", ");
		printArrayElement (array->next);
	}
}
