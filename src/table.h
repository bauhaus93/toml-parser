#ifndef TABLE_H
#define TABLE_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "key.h"

typedef enum
{
	TABLE_SIMPLE,
	TABLE_ARRAY
} TableType;

typedef struct
{
	TableType type;
	Key * key;
} Table;

Table * createTable (TableType, Key *);
void printTable (const Table * table);

#endif // TABLE_H
