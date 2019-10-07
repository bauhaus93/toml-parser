#include "key.h"

static void printSubKey (const Key * key);

Key * keyFromScalar (Scalar * scalar)
{
	assert (scalar->type == SCALAR_STRING_BASIC || scalar->type == SCALAR_STRING_LITERAL || scalar->type == SCALAR_STRING_BARE);
	Key * key = malloc (sizeof (Key));
	key->name = scalar;
	key->descendant = NULL;
	return key;
}

void appendKey (Key * base, Key * appendant)
{
	assert (base != NULL);
	assert (appendant != NULL);

	base->descendant = appendant;
}

void printKey (const Key * key)
{
	printf ("%s", key->name->str);
	if (key->descendant != NULL)
	{
		printSubKey (key->descendant);
	}
}

static void printSubKey (const Key * key)
{
	printf (".%s", key->name->str);
	if (key->descendant != NULL)
	{
		printSubKey (key->descendant);
	}
}
