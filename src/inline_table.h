#ifndef INLINE_TABLE_H
#define INLINE_TABLE_H

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef INLINE_TABLE_DEFINED
typedef struct _InlineTable InlineTable;
#define INLINE_TABLE_DEFINED
#endif

#include "key_pair.h"

struct _InlineTable
{
	KeyPair * pair;
	struct _InlineTable * next;
};

InlineTable * pushPair (InlineTable *, KeyPair *);
InlineTable * inlineTableFromKeyPair (KeyPair *);

void printInlineTable (const InlineTable * table);

#endif // INLINE_TABLE_H
