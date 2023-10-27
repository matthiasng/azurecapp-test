using Hello.ServiceB.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddGrpcHttpApi();
builder.Services.AddDaprClient();

var app = builder.Build();

app.UseHttpLogging();

app.UseRouting();

app.MapGrpcService<HelloService>();

app.Run();
