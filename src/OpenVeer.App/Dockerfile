#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["OpenVeer.App/OpenVeer.App.csproj", "OpenVeer.App/"]
RUN dotnet restore "OpenVeer.App/OpenVeer.App.csproj"
COPY . .
WORKDIR "/src/OpenVeer.App"
RUN dotnet build "OpenVeer.App.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "OpenVeer.App.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OpenVeer.App.dll"]