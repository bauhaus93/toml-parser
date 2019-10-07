#include "scalar.h"

static const char * getType (const Scalar * scalar);

Scalar * createScalar (ScalarType type, char * scalarString)
{
	assert (scalarString != NULL);
	Scalar * scalar = malloc (sizeof (Scalar));
	scalar->type = type;
	scalar->str = scalarString;
	return scalar;
}

Scalar * createScalarDup (ScalarType type, const char * scalarString)
{
	assert (scalarString != NULL);
	Scalar * scalar = malloc (sizeof (Scalar));
	scalar->type = type;
	scalar->str = strdup (scalarString);
	return scalar;
}

void printScalar (const Scalar * scalar)
{
	assert (scalar != NULL);
	printf ("/%s = '%s'", getType (scalar), scalar->str);
}

static const char * getType (const Scalar * scalar)
{
	switch (scalar->type)
	{
	case SCALAR_INTEGER_DEC:
		return "DECIMAL";
	case SCALAR_INTEGER_HEX:
		return "HEXADECIMAL";
	case SCALAR_INTEGER_OCT:
		return "OCTAL";
	case SCALAR_INTEGER_BIN:
		return "BINARY";
	case SCALAR_BOOLEAN:
		return "BOOLEAN";
	case SCALAR_FLOAT_NUM:
		return "FLOAT";
	case SCALAR_FLOAT_INF:
		return "FLOAT_INF";
	case SCALAR_FLOAT_POS_INF:
		return "FLOAT_POS_INF";
	case SCALAR_FLOAT_NEG_INF:
		return "FLOAT_NEG_INF";
	case SCALAR_FLOAT_NAN:
		return "FLOAT_NAN";
	case SCALAR_FLOAT_POS_NAN:
		return "FLOAT_POS_NAN";
	case SCALAR_FLOAT_NEG_NAN:
		return "FLOAT_NEG_NAN";
	case SCALAR_STRING_COMMENT:
		return "COMMENT";
	case SCALAR_STRING_BARE:
		return "STRING_BARE";
	case SCALAR_STRING_LITERAL:
		return "STRING_LITERAL";
	case SCALAR_STRING_BASIC:
		return "STRING_BASIC";
	case SCALAR_STRING_ML_LITERAL:
		return "STRING_ML_LITERAL";
	case SCALAR_STRING_ML_BASIC:
		return "STRING_ML_BASIC";
	case SCALAR_DATE_OFFSET_DATETIME:
		return "DATE_OFFSET_DATETIME";
	case SCALAR_DATE_LOCAL_DATETIME:
		return "DATE_LOCAL_DATETIME";
	case SCALAR_DATE_LOCAL_DATE:
		return "DATE_LOCAL_DATE";
	case SCALAR_DATE_LOCAL_TIME:
		return "DATE_LOCAL_TIME";
	default:
		assert (0);
	}
}
