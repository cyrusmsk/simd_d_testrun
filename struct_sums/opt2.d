version(LDC)
{
    import ldc.attributes; // for @restrict
}
version(GNU)
{
    import gcc.attributes;
}
// Type your code here, or load an example.
struct S2 {
    ulong a,b;
}

ulong add_numbers2(S2 x, S2 y, S2 z) {
    return x.a + x.b + z.a + y.a + y.b + z.b;
}

struct S3 {
    ulong a,b,c;
}

ulong add_numbers3(in S3 x, in S3 y) {
    return x.a + y.a + x.b + y.b + x.c + y.c;
}

void addn(size_t n, S3* xs, S3* ys, @restrict ulong* dst)
{
    foreach(i; 0 .. n)
    {
        dst[i] = add_numbers3(xs[i], ys[i]);

    }
}

void main() {
    add_numbers2(S2(1111,2222), S2(3333,4444), S2(5555,6666));
    add_numbers3(S3(1111,2222, 3333), S3(4444,5555,6666));
}
