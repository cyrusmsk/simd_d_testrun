import std;

struct S1 {
    int a, b;
}

struct S2 {
    int c, d;
}

int func(S1[] array1, S2[] array2) {
    assert(cast(size_t)array1.ptr !is cast(size_t)array2.ptr);

    int result;

    foreach(chunk; zip(array1, array2).chunks(8)) {
        size_t valueInChunk;
        foreach(values; chunk) {
            assert(valueInChunk++ < 4);
            result += values[0].a + values[0].b + values[1].c + values[1].d;
        }
    }

    return result;
}

