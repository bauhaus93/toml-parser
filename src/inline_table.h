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

InlineTable * pushPair (InlineTable *, KeyPair *);
InlineTable * inlineTableFromKeyPair (KeyPair *);

void printInlineTable (const InlineTable * table);

#endif // INLINE_TABLE_H
