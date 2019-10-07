#ifndef TABLE_H
#define TABLE_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "key.h"

typedef enum
{
	TABLE_STANDARD,
	TABLE_ARRAY
} TableType;

typedef struct
{
	TableType type;
	Key * key;
} Table;

Table * create_table (TableType, Key *);

#endif // TABLE_H
