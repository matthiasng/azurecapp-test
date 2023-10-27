# Azure Container apps minimal example


**Requiremed tools**
- az cli
- terraform
- docker

## Steps to reproduce

1. `cd terraform`
2. make sure you are signed in: `az login`
3. Run `terraform init` and `terraform apply`. You can also create the infrastructure manually. Double check the container apps configuration with the terraform module
4. build & push the service containers (pwsh script)
    ```pwsh
    $registryName = (terraform output -raw registry_name)

    cd ..

    az acr login --name "$registryName"

    docker build `
        -f ./src/Hello.ServiceA/Dockerfile `
        --build-arg HELLO_ENV `
        -t "$registryName.azurecr.io/testcapp/hello-servicea:0.0.1" `
        ./src/Hello.ServiceA

    docker push "$registryName.azurecr.io/testcapp/hello-servicea:0.0.1"

    docker build `
        -f ./src/Hello.ServiceB/Dockerfile `
        --build-arg HELLO_ENV `
        -t "$registryName.azurecr.io/testcapp/hello-serviceb:0.0.1" `
        ./src/Hello.ServiceB

    docker push "$registryName.azurecr.io/testcapp/hello-serviceb:0.0.1"
    ```
5. Go to the azure portal and deploy the two containers to the two container apps provisioned by terraform.
6. To run the test just copy the `Revision URL` to your browse rand open it.
   1. This triggers a handler in `service A` which then call `service B` via a grpc call
   2. Check the container app logs
      1. `Service A`: throws an exception after ~15 sec
        ```
        2023-10-27T12:38:56.72051  Connecting to the container 'examplecontainerapp'...
        2023-10-27T12:38:56.74385  Successfully Connected to container: 'examplecontainerapp' [Revision: 'testcapp-servicea-capp-oyov--5whxxtr-7469d8876d-gbmlp', Replica: 'testcapp-servicea-capp-oyov--5whxxtr']
        2023-10-27T12:37:55.900039215Z warn: Microsoft.AspNetCore.Server.Kestrel[0]
        2023-10-27T12:37:55.900083249Z       Overriding address(es) 'http://+:80'. Binding to endpoints defined via IConfiguration and/or UseKestrel() instead.
        2023-10-27T12:37:55.991733828Z info: Microsoft.Hosting.Lifetime[14]
        2023-10-27T12:37:55.991777011Z       Now listening on: http://[::]:80
        2023-10-27T12:37:55.992641445Z info: Microsoft.Hosting.Lifetime[0]
        2023-10-27T12:37:55.992648645Z       Application started. Press Ctrl+C to shut down.
        2023-10-27T12:37:55.992651178Z info: Microsoft.Hosting.Lifetime[0]
        2023-10-27T12:37:55.992654427Z       Hosting environment: Production
        2023-10-27T12:37:55.992656772Z info: Microsoft.Hosting.Lifetime[0]
        2023-10-27T12:37:55.992660085Z       Content root path: /app/
        2023-10-27T12:39:16.997105731Z info: Microsoft.AspNetCore.Hosting.Diagnostics[1]
        2023-10-27T12:39:16.997156503Z       Request starting HTTP/1.1 GET http://testcapp-servicea-capp-oyov.delightfulmeadow-96396c70.westeurope.azurecontainerapps.io/ - -
        2023-10-27T12:39:17.011616103Z info: Microsoft.AspNetCore.HttpLogging.HttpLoggingMiddleware[1]
        2023-10-27T12:39:17.011642694Z       Request:
        2023-10-27T12:39:17.011648589Z       Protocol: HTTP/1.1
        2023-10-27T12:39:17.011653680Z       Method: GET
        2023-10-27T12:39:17.011658800Z       Scheme: http
        2023-10-27T12:39:17.011664320Z       PathBase: 
        2023-10-27T12:39:17.011668737Z       Path: /
        2023-10-27T12:39:17.011673131Z       Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
        2023-10-27T12:39:17.011677605Z       Host: testcapp-servicea-capp-oyov.delightfulmeadow-96396c70.westeurope.azurecontainerapps.io
        2023-10-27T12:39:17.011681951Z       User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36
        2023-10-27T12:39:17.011686768Z       Accept-Encoding: gzip, deflate, br
        2023-10-27T12:39:17.011690977Z       Accept-Language: en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7
        2023-10-27T12:39:17.011695290Z       Upgrade-Insecure-Requests: [Redacted]
        2023-10-27T12:39:17.011699497Z       sec-ch-ua: [Redacted]
        2023-10-27T12:39:17.011703402Z       sec-ch-ua-mobile: [Redacted]
        2023-10-27T12:39:17.011707369Z       sec-ch-ua-platform: [Redacted]
        2023-10-27T12:39:17.011711176Z       sec-fetch-site: [Redacted]
        2023-10-27T12:39:17.011714719Z       sec-fetch-mode: [Redacted]
        2023-10-27T12:39:17.011718675Z       sec-fetch-user: [Redacted]
        2023-10-27T12:39:17.011722350Z       sec-fetch-dest: [Redacted]
        2023-10-27T12:39:17.011725936Z       x-forwarded-for: [Redacted]
        2023-10-27T12:39:17.011729616Z       x-envoy-external-address: [Redacted]
        2023-10-27T12:39:17.011733344Z       x-request-id: [Redacted]
        2023-10-27T12:39:17.011737069Z       x-envoy-expected-rq-timeout-ms: [Redacted]
        2023-10-27T12:39:17.011740818Z       x-k8se-app-name: [Redacted]
        2023-10-27T12:39:17.011744653Z       x-k8se-app-namespace: [Redacted]
        2023-10-27T12:39:17.011748494Z       x-k8se-protocol: [Redacted]
        2023-10-27T12:39:17.011775681Z       x-k8se-app-kind: [Redacted]
        2023-10-27T12:39:17.011781008Z       x-ms-containerapp-name: [Redacted]
        2023-10-27T12:39:17.011785008Z       x-ms-containerapp-revision-name: [Redacted]
        2023-10-27T12:39:17.011788841Z       x-arr-ssl: [Redacted]
        2023-10-27T12:39:17.011792921Z       x-forwarded-proto: [Redacted]
        2023-10-27T12:39:17.088868298Z info: Microsoft.AspNetCore.Routing.EndpointMiddleware[0]
        2023-10-27T12:39:17.088909850Z       Executing endpoint 'HTTP: GET /'
        2023-10-27T12:39:17.191659434Z do call serviceB (AppId: serviceb, daprGrpcPort50001)
        2023-10-27T12:39:17.394740676Z info: System.Net.Http.HttpClient.HelloClient.LogicalHandler[100]
        2023-10-27T12:39:17.394791076Z       Start processing HTTP request POST http://localhost:50001/hello.v1.Hello/Hello
        2023-10-27T12:39:17.395983768Z info: System.Net.Http.HttpClient.HelloClient.ClientHandler[100]
        2023-10-27T12:39:17.396021333Z       Sending HTTP request POST http://localhost:50001/hello.v1.Hello/Hello
        2023-10-27T12:39:32.634104799Z info: System.Net.Http.HttpClient.HelloClient.ClientHandler[101]
        2023-10-27T12:39:32.634148799Z       Received HTTP response headers after 15236.233ms - 200
        2023-10-27T12:39:32.635083679Z info: System.Net.Http.HttpClient.HelloClient.LogicalHandler[101]
        2023-10-27T12:39:32.635104073Z       End processing HTTP request after 15243.6881ms - 200
        2023-10-27T12:39:32.640173561Z info: Grpc.Net.Client.Internal.GrpcCall[3]
        2023-10-27T12:39:32.640197453Z       Call failed with gRPC error status. Status code: 'Unavailable', Message: 'upstream request timeout'.
        2023-10-27T12:39:32.642524667Z info: Microsoft.AspNetCore.Routing.EndpointMiddleware[1]
        2023-10-27T12:39:32.642543685Z       Executed endpoint 'HTTP: GET /'
        2023-10-27T12:39:32.653805087Z fail: Microsoft.AspNetCore.Server.Kestrel[13]
        2023-10-27T12:39:32.653905584Z       Connection id "0HMUMT65ON7N0", Request id "0HMUMT65ON7N0:00000002": An unhandled exception was thrown by the application.
        2023-10-27T12:39:32.653925275Z       Grpc.Core.RpcException: Status(StatusCode="Unavailable", Detail="upstream request timeout")
        2023-10-27T12:39:32.653938054Z          at Grpc.Net.Client.Internal.HttpClientCallInvoker.BlockingUnaryCall[TRequest,TResponse](Method`2 method, String host, CallOptions options, TRequest request)
        2023-10-27T12:39:32.653943712Z          at Grpc.Core.Interceptors.InterceptingCallInvoker.<BlockingUnaryCall>b__3_0[TRequest,TResponse](TRequest req, ClientInterceptorContext`2 ctx)
        2023-10-27T12:39:32.653956342Z          at Dapr.Client.InvocationInterceptor.BlockingUnaryCall[TRequest,TResponse](TRequest request, ClientInterceptorContext`2 context, BlockingUnaryCallContinuation`2 continuation)
        2023-10-27T12:39:32.653960707Z          at Grpc.Core.Interceptors.InterceptingCallInvoker.BlockingUnaryCall[TRequest,TResponse](Method`2 method, String host, CallOptions options, TRequest request)
        2023-10-27T12:39:32.653965041Z          at Grpc.Core.Interceptors.InterceptingCallInvoker.<BlockingUnaryCall>b__3_0[TRequest,TResponse](TRequest req, ClientInterceptorContext`2 ctx)
        2023-10-27T12:39:32.653970406Z          at Grpc.Core.ClientBase.ClientBaseConfiguration.ClientBaseConfigurationInterceptor.BlockingUnaryCall[TRequest,TResponse](TRequest request, ClientInterceptorContext`2 context, BlockingUnaryCallContinuation`2 continuation)
        2023-10-27T12:39:32.653975846Z          at Grpc.Core.Interceptors.InterceptingCallInvoker.BlockingUnaryCall[TRequest,TResponse](Method`2 method, String host, CallOptions options, TRequest request)
        2023-10-27T12:39:32.653980263Z          at Hello.ServiceB.Hello.HelloClient.Hello(HelloRequest request, CallOptions options) in /app/obj/Release/net6.0/HelloV1Grpc.cs:line 102
        2023-10-27T12:39:32.653984121Z          at Hello.ServiceB.Hello.HelloClient.Hello(HelloRequest request, Metadata headers, Nullable`1 deadline, CancellationToken cancellationToken) in /app/obj/Release/net6.0/HelloV1Grpc.cs:line 97
        2023-10-27T12:39:32.653987579Z          at Program.<>c__DisplayClass0_0.<<Main>$>b__2(HelloClient client) in /app/Program.cs:line 29
        2023-10-27T12:39:32.653991836Z          at lambda_method1(Closure , Object , HttpContext )
        2023-10-27T12:39:32.654006044Z          at Microsoft.AspNetCore.Http.RequestDelegateFactory.<>c__DisplayClass36_0.<Create>b__0(HttpContext httpContext)
        2023-10-27T12:39:32.654010049Z          at Microsoft.AspNetCore.Routing.EndpointMiddleware.Invoke(HttpContext httpContext)
        2023-10-27T12:39:32.654013947Z       --- End of stack trace from previous location ---
        2023-10-27T12:39:32.654017955Z          at Microsoft.AspNetCore.HttpLogging.HttpLoggingMiddleware.InvokeInternal(HttpContext context)
        2023-10-27T12:39:32.654023311Z          at Microsoft.AspNetCore.Server.Kestrel.Core.Internal.Http.HttpProtocol.ProcessRequests[TContext](IHttpApplication`1 application)
        2023-10-27T12:39:32.655044687Z info: Microsoft.AspNetCore.Hosting.Diagnostics[2]
        2023-10-27T12:39:32.655066079Z       Request finished HTTP/1.1 GET http://testcapp-servicea-capp-oyov.delightfulmeadow-96396c70.westeurope.azurecontainerapps.io/ - - - 500 0 - 15658.4013ms

        ```
      2. `Sevice B`: finished the request with 200
        ```
        2023-10-27T12:39:06.07669  Connecting to the container 'examplecontainerapp'...
        2023-10-27T12:39:06.09532  Successfully Connected to container: 'examplecontainerapp' [Revision: 'testcapp-serviceb-capp-oyov--6j6lftp-b77b96cc5-6kcr5', Replica: 'testcapp-serviceb-capp-oyov--6j6lftp']
        2023-10-27T12:38:27.529473645Z warn: Microsoft.AspNetCore.Server.Kestrel[0]
        2023-10-27T12:38:27.529535495Z       Overriding address(es) 'http://+:80'. Binding to endpoints defined via IConfiguration and/or UseKestrel() instead.
        2023-10-27T12:38:27.539862071Z info: Microsoft.Hosting.Lifetime[14]
        2023-10-27T12:38:27.539885517Z       Now listening on: http://[::]:5001
        2023-10-27T12:38:27.540417955Z info: Microsoft.Hosting.Lifetime[14]
        2023-10-27T12:38:27.540430343Z       Now listening on: http://[::]:80
        2023-10-27T12:38:27.540533714Z info: Microsoft.Hosting.Lifetime[0]
        2023-10-27T12:38:27.540539212Z       Application started. Press Ctrl+C to shut down.
        2023-10-27T12:38:27.540542379Z info: Microsoft.Hosting.Lifetime[0]
        2023-10-27T12:38:27.540545591Z       Hosting environment: Production
        2023-10-27T12:38:27.540548254Z info: Microsoft.Hosting.Lifetime[0]
        2023-10-27T12:38:27.540551504Z       Content root path: /app/
        2023-10-27T12:39:17.649979278Z info: Microsoft.AspNetCore.Hosting.Diagnostics[1]
        2023-10-27T12:39:17.650024666Z       Request starting HTTP/2 POST http://127.0.0.1:5001/hello.v1.Hello/Hello application/grpc+proto -
        2023-10-27T12:39:17.654482214Z info: Microsoft.AspNetCore.HttpLogging.HttpLoggingMiddleware[1]
        2023-10-27T12:39:17.654507852Z       Request:
        2023-10-27T12:39:17.654514787Z       Protocol: HTTP/2
        2023-10-27T12:39:17.654524595Z       Method: POST
        2023-10-27T12:39:17.654528257Z       Scheme: http
        2023-10-27T12:39:17.654532361Z       PathBase: 
        2023-10-27T12:39:17.654536275Z       Path: /hello.v1.Hello/Hello
        2023-10-27T12:39:17.654540639Z       Host: 127.0.0.1:5001
        2023-10-27T12:39:17.654545652Z       User-Agent: grpc-go/1.56.2
        2023-10-27T12:39:17.654550482Z       :method: [Redacted]
        2023-10-27T12:39:17.654555606Z       Content-Type: application/grpc+proto
        2023-10-27T12:39:17.654569876Z       Grpc-Accept-Encoding: [Redacted]
        2023-10-27T12:39:17.654573213Z       Grpc-Timeout: [Redacted]
        2023-10-27T12:39:17.654576447Z       TE: trailers
        2023-10-27T12:39:17.654579750Z       traceparent: [Redacted]
        2023-10-27T12:39:17.654583107Z       x-k8se-app-namespace: [Redacted]
        2023-10-27T12:39:17.654586429Z       x-k8se-app-kind: [Redacted]
        2023-10-27T12:39:17.654589794Z       x-arr-ssl: [Redacted]
        2023-10-27T12:39:17.654593046Z       x-forwarded-proto: [Redacted]
        2023-10-27T12:39:17.654596437Z       grpc-trace-bin: [Redacted]
        2023-10-27T12:39:17.654599692Z       x-envoy-external-address: [Redacted]
        2023-10-27T12:39:17.654603372Z       x-request-id: [Redacted]
        2023-10-27T12:39:17.654606637Z       x-ms-containerapp-name: [Redacted]
        2023-10-27T12:39:17.654610068Z       x-k8se-protocol: [Redacted]
        2023-10-27T12:39:17.654613424Z       x-forwarded-for: [Redacted]
        2023-10-27T12:39:17.654616875Z       x-k8se-endpoint-name: [Redacted]
        2023-10-27T12:39:17.654620118Z       dapr-app-id: [Redacted]
        2023-10-27T12:39:17.654623366Z       x-envoy-expected-rq-timeout-ms: [Redacted]
        2023-10-27T12:39:17.654626994Z       x-ms-containerapp-revision-name: [Redacted]
        2023-10-27T12:39:17.654630215Z       dapr-callee-app-id: [Redacted]
        2023-10-27T12:39:17.654633434Z       x-k8se-dapr-app-id: [Redacted]
        2023-10-27T12:39:17.654636634Z       dapr-caller-app-id: [Redacted]
        2023-10-27T12:39:17.654639869Z       x-k8se-app-name: [Redacted]
        2023-10-27T12:39:17.739650424Z info: Microsoft.AspNetCore.Routing.EndpointMiddleware[0]
        2023-10-27T12:39:17.739720799Z       Executing endpoint 'gRPC - /hello.v1.Hello/Hello'
        2023-10-27T12:39:17.932996574Z received Hello request. wait 30 seconds
        2023-10-27T12:39:47.933095777Z finished waiting, lets respond
        2023-10-27T12:39:47.938593712Z info: Microsoft.AspNetCore.Routing.EndpointMiddleware[1]
        2023-10-27T12:39:47.938628216Z       Executed endpoint 'gRPC - /hello.v1.Hello/Hello'
        2023-10-27T12:39:47.938919203Z info: Microsoft.AspNetCore.HttpLogging.HttpLoggingMiddleware[2]
        2023-10-27T12:39:47.938941687Z       Response:
        2023-10-27T12:39:47.938947076Z       StatusCode: 200
        2023-10-27T12:39:47.938951662Z       Content-Type: application/grpc
        2023-10-27T12:39:47.938955783Z       Date: Fri, 27 Oct 2023 12:39:47 GMT
        2023-10-27T12:39:47.938975771Z       Server: Kestrel
        2023-10-27T12:39:47.940016916Z info: Microsoft.AspNetCore.Hosting.Diagnostics[2]
        2023-10-27T12:39:47.940031042Z       Request finished HTTP/2 POST http://127.0.0.1:5001/hello.v1.Hello/Hello application/grpc+proto - - 200 - application/grpc 30290.6690ms
        ```
