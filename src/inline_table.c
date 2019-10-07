#include "inline_table.h"

static void print_inline_table_element (const InlineTable * table);

InlineTable * inline_table_from_key_pair (KeyPair * pair)
{
	assert (pair != NULL);
	InlineTable * table = malloc (sizeof (InlineTable));
	table->pair = pair;
	table->next = NULL;
	return table;
}

InlineTable * push_pair (InlineTable * root, KeyPair * pair)
{
	assert (root != NULL);
	assert (pair != NULL);
	InlineTable * t = inline_table_from_key_pair (pair);
	t->next = root;
	return t;
}

void print_inline_table (const InlineTable * table)
{
	assert (table != NULL);
	printf (" { ");
	print_inline_table_element (table);
	printf (" } ");
}

static void print_inline_table_element (const InlineTable * table)
{
	assert (table != NULL);
	print_key_pair (table->pair);
	if (table->next != NULL)
	{
		printf (", ");
		print_inline_table_element (table->next);
	}
}
