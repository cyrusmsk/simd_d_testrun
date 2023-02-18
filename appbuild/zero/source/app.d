module app;

import std;
import arsd.cgi;

static void startServer(RequestServer s) {
    s.serve!(postFunc, Cgi, defaultMaxContentLength);
}

void postFunc(Cgi cgi) {
    cgi.setResponseContentType("text/plain");
    cgi.write(cgi.post["value"]);

}

int reqSend(Tuple!(string, int) val) {
    while (true) {
        auto content = std.net.curl.post(val[0], ["value" : val[1].to!string]);
        return content.to!int;
    }
}

int reqSendF(Tuple!(string, int) v) {
    return v[1];
}

int main(string[] args)
{
    import std.datetime.stopwatch : AutoStart, StopWatch;
    auto sw = StopWatch(AutoStart.no);
    sw.start();
    int n = args.length > 1 ? args[1].to!int : 10;
    auto rnd = Random(unpredictableSeed);
    auto port = uniform(30000, 40000, rnd);
    string api = "127.0.0.1:"~to!string(port)~"/";
    RequestServer server = RequestServer("127.0.0.1", cast(ushort) port);
    auto tid = spawn(&startServer, server);
    auto init = iota(1,n + 1,1).map!(a => tuple(api, a));
    auto res = taskPool.amap!reqSend(init, n);
    writeln(res.sum);
    sw.stop();
    writeln(sw.peek.total!"msecs");
    server.stop();
    return 0;
}
