#include "table.h"

Table * createTable (TableType type, Key * key)
{
	assert (key != NULL);
	Table * table = malloc (sizeof (Table));
	table->type = type;
	table->key = key;
	return table;
}

void printTable (const Table * table)
{
	assert (table != NULL);
	switch (table->type)
	{
	case TABLE_SIMPLE:
		printf ("[");
		printKey (table->key);
		printf ("] (%d)", table->key->name->line);
		break;
	case TABLE_ARRAY:
		printf ("[[");
		printKey (table->key);
		printf ("]] (%d)", table->key->name->line);
		break;
	default:
		assert (0);
	}
}
