#ifndef INLINE_TABLE_H
#define INLINE_TABLE_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "key_pair.h"

typedef struct _InlineTable
{
	KeyPair * pair;
	struct _InlineTable * next;
} InlineTable;

InlineTable * push_pair (InlineTable *, KeyPair *);
InlineTable * inline_table_from_key_pair (KeyPair *);

void print_inline_table (const InlineTable * table);

#endif // INLINE_TABLE_H
