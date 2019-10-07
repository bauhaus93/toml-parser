#include "scalar.h"


Scalar * createScalar (ScalarType type, char * scalarString, int line)
{
	assert (scalarString != NULL);
	Scalar * scalar = malloc (sizeof (Scalar));
	scalar->type = type;
	scalar->str = scalarString;
	scalar->line = line;
	return scalar;
}

Scalar * createScalarDup (ScalarType type, const char * scalarString, int line)
{
	assert (scalarString != NULL);
	Scalar * scalar = malloc (sizeof (Scalar));
	scalar->type = type;
	scalar->str = strdup (scalarString);
	scalar->line = line;
	return scalar;
}

void printScalar (const Scalar * scalar)
{
	assert (scalar != NULL);
	printf ("'%s' (%d)", scalar->str, scalar->line);
}
