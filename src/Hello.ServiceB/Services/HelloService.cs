using System;
using Grpc.Core;
using Google.Protobuf.WellKnownTypes;

namespace Hello.ServiceB.Services;

public class HelloService : Hello.HelloBase
{
    public HelloService(){}

    public override async Task<HelloMessage> Hello(HelloRequest request, ServerCallContext context)
    {
        context.CancellationToken.ThrowIfCancellationRequested();
        
        Console.WriteLine("received Hello request. wait 30 seconds");
        Thread.Sleep(30 * 1000);
        Console.WriteLine("finished waiting, lets respond");

        var msg = new HelloMessage();
        msg.RandomId = Guid.NewGuid().ToString();
        msg.Message = "hello dapr";

        return msg;
    }
}
