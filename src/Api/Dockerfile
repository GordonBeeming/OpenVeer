FROM mcr.microsoft.com/dotnet/aspnet:9.0-preview-alpine AS base
RUN apk add icu-libs
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
USER $APP_UID
WORKDIR /app
EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ARG A_COMMIT_HASH
ENV COMMIT_HASH=$A_COMMIT_HASH
ARG A_BRANCH_NAME
ENV BRANCH_NAME=$A_BRANCH_NAME

FROM mcr.microsoft.com/dotnet/sdk:9.0-preview-alpine AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["global.json", "global.json"]
COPY ["src/OpenVeer.Api/OpenVeer.Api.csproj", "src/OpenVeer.Api/"]
RUN dotnet restore "src/OpenVeer.Api/OpenVeer.Api.csproj"
COPY . .
WORKDIR "/src/src/OpenVeer.Api"
RUN dotnet build "OpenVeer.Api.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "OpenVeer.Api.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OpenVeer.Api.dll"]
