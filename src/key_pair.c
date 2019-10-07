#include "key_pair.h"

KeyPair * makePair (Key * key, Value * value)
{
	assert (key != NULL);
	assert (value != NULL);
	KeyPair * pair = malloc (sizeof (KeyPair));
	pair->key = key;
	pair->value = value;
	return pair;
}

void printKeyPair (const KeyPair * keyPair)
{
	assert (keyPair != NULL);
	printKey (keyPair->key);
	printf (" : ");
	printValue (keyPair->value);
}
