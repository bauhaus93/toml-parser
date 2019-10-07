#include "inline_table.h"

static void printInlineTableElement (const InlineTable * table);

InlineTable * inlineTableFromKeyPair (KeyPair * pair)
{
	assert (pair != NULL);
	InlineTable * table = malloc (sizeof (InlineTable));
	table->pair = pair;
	table->next = NULL;
	return table;
}

InlineTable * pushPair (InlineTable * root, KeyPair * pair)
{
	assert (root != NULL);
	assert (pair != NULL);
	InlineTable * t = inlineTableFromKeyPair (pair);
	t->next = root;
	return t;
}

void printInlineTable (const InlineTable * table)
{
	assert (table != NULL);
	printf (" { ");
	printInlineTableElement (table);
	printf (" } ");
}

static void printInlineTableElement (const InlineTable * table)
{
	assert (table != NULL);
	printKeyPair (table->pair);
	if (table->next != NULL)
	{
		printf (", ");
		printInlineTableElement (table->next);
	}
}
