# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY ./*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY ./ ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0

ARG HELLO_ENV=default
ENV HELLO_ENV ${HELLO_ENV}

WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "Hello.ServiceA.dll"]