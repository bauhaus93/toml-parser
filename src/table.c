#include "table.h"

Table * createTable (TableType type, Key * key)
{
	assert (key != NULL);
	Table * table = malloc (sizeof (Table));
	table->type = type;
	table->key = key;
}
