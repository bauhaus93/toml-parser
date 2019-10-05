#include "array.h"

static void print_array_element(const Array *);

void append_element(Array *base, Array *appendant) {
    assert(base != NULL);
    assert(appendant != NULL);
    base->next = appendant;
}

Array* array_from_scalar(Scalar* scalar) {
    Array* array = malloc(sizeof(Array));
    array->element = scalar;
    array->next = NULL;
    return array;
}

void print_array(const Array *array) {
    assert(array != NULL);
    printf("Array: [\n");
    print_array_element(array);
    printf("]\n");
}

static void print_array_element(const Array *array) {
    assert(array != NULL);
    print_scalar(array->element);
    if (array->next != NULL) {
        print_array_element(array->next);
    }
}
