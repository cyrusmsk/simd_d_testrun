// port from 8-m.zig
import std;
import std.outbuffer: OutBuffer;

alias Map = uint[Nullable!Code];
static double hundreed = 100.0;

static struct Code
{
    ulong data;

    void push(ubyte c, ulong mask)
    {
        data = ((data << 2) | cast(ulong) c) & mask;
    }

    static Nullable!Code fromStr(ubyte[] s)
    {
        auto mask = Code.makeMask(s.length);
        auto res = Code(0);
        foreach (c; s)
            res.push(Code.encodeByte(c), mask);
        return nullable(res);
    }

    string toStr(size_t frame)
    {
        char[] res;
        auto code = this.data;
        ubyte c;
        foreach (_; 0 .. frame)
        {
            switch (cast(ubyte) code & 0b11)
            {
            case Code.encodeByte('A'):
                c = 'A';
                break;
            case Code.encodeByte('C'):
                c = 'C';
                break;
            case Code.encodeByte('G'):
                c = 'G';
                break;
            case Code.encodeByte('T'):
                c = 'T';
                break;
            default:
                break;
            }
            res ~= c;
            code >>= 2;
        }
        return cast(string) res.reverse;
    }

    pragma(inline, true)
    static ulong makeMask(size_t frame)
    {
        return (1L << (2 * frame)) - 1L;
    }

    pragma(inline, true)
    static ubyte encodeByte(ubyte c)
    {
        return (c >> 1) & 0b11;
    }
}

// zig implementation
struct Iter
{
    size_t i = 0;
    immutable(ubyte[]) input;
    Nullable!Code code;
    ulong mask;

    this(immutable(ubyte[]) input, size_t frame)
    {
        const mask = Code.makeMask(frame);
        Nullable!Code tmpCode = Code(0);
        foreach (c; input[0 .. frame - 1])
            tmpCode.get.push(c, mask);
        this.mask = mask;
        this.code = tmpCode;
        this.input = input[frame - 1 .. $];
    }

    Nullable!Code next()
    {
        if (this.i >= this.input.length)
            return Nullable!Code();
        const c = this.input[this.i];
        this.code.get.push(c, this.mask);
        this.i += 1;
        return this.code;
    }
}

void genMap(immutable ubyte[] seq, size_t n, ref Map myMap)
{
    myMap.clear();
    auto iter = Iter(seq, n);
    auto code = iter.next();
    while (!code.isNull)
    {
        myMap.update(code,
            () => 1,
            (ref uint v) { v += 1; });
        code = iter.next();
    }
}

struct CountCode
{
    ulong count;
    Nullable!Code code;
}

void printMap(size_t self, Map myMap, ref OutBuffer buf)
{
    CountCode[] v;
    ulong total;
    uint count;
    foreach (pair; myMap.byPair)
    {
        total += pair.value;
        v ~= CountCode(pair.value, pair.key);
    }
    alias asc = (a, b) =>
        a.count < b.count ||
        (a.count == b.count && b.code.get.data < a.code.get.data);

    v.sort!(asc);
    auto i = v.length;
    i--; // try just for loop here
    while (true)
    {
        auto cc = v[i];
        buf.writefln("%s %.3f", cc.code.get.toStr(self), cast(double) cc.count / cast(
                double) total * hundreed);
        if (i == 0)
            break;
        i--;
    }
    buf.write("\n");
}

void printOcc(ubyte[] s, ref Map myMap, ref OutBuffer buf)
{
    auto tmp = Code.fromStr(s);
    buf.writefln("%d\t%s", myMap.get(tmp, 0), cast(string) s);
}

pragma(inline, true)
immutable(ubyte[]) readInput(string[] args)
{
    immutable fileName = args.length > 1 ? args[1] : "25000_in";
    string key = ">THREE";
    ubyte[] res; // check other Array cases

    auto infile = File(args[1]);
    uint linect = 0;
    foreach (line; infile.byLine())
    {
        if (line.startsWith(key))
            break;
    }
    foreach (line; infile.byLine())
    {
        res ~= (cast(ubyte[]) line)[0 .. $].map!(a => Code.encodeByte(a)).array;
    }

    return cast(immutable) res;
}

void main(string[] args)
{
    auto buf1 = new OutBuffer();
    auto buf2 = new OutBuffer();

    static ubyte[][5] occs = [
        cast(ubyte[]) "GGTATTTTAATTTATAGT",
        cast(ubyte[]) "GGTATTTTAATT",
        cast(ubyte[]) "GGTATT",
        cast(ubyte[]) "GGTA",
        cast(ubyte[]) "GGT",
    ];
    immutable input = readInput(args);
    writeln(input);
    Map myMap;

    genMap(input, 1, myMap);
    printMap(1, myMap, buf1);
    genMap(input, 2, myMap);
    printMap(2, myMap, buf1);

    foreach (i; iota(4, -1, -1))
    {
        genMap(input, occs[i].length, myMap);
        printOcc(occs[i], myMap, buf2);
    }
    write(buf1);
    write(buf2);
}
