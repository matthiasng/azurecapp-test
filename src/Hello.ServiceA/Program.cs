using Hello.ServiceB;
using static Hello.ServiceB.Hello;
using Dapr.Client;
using Grpc.Core;

var builder = WebApplication.CreateBuilder(args);

var daprGrpcPort = builder.Configuration.GetSection("Dapr").GetValue<int>("GrpcPort");
var serviceBAppID = "serviceb";

builder.Services.AddGrpcClient<HelloClient>(options =>
{
    options.Address = new Uri($"http://localhost:{daprGrpcPort}");
    options.ChannelOptionsActions.Add(channelOptions =>
    {
        channelOptions.Credentials = ChannelCredentials.Insecure;
    });
})
.AddInterceptor(x => new InvocationInterceptor(serviceBAppID, null));

var app = builder.Build();

app.UseHttpLogging();

app.MapGet("/", (HelloClient client) =>
{
    Console.WriteLine("do call serviceB (AppId: {0}, daprGrpcPort{1})", serviceBAppID, daprGrpcPort);

    var response = client.Hello(new HelloRequest(), deadline: DateTime.UtcNow.AddSeconds(60));
    if (response is null)
        return "empty response";

    return "seed: " + response.RandomId + ", msg: " + response.Message;
});

app.Run();
