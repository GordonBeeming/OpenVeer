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
COPY ["Directory.Build.props", "Directory.Build.props"]
COPY ["Directory.Packages.props", "Directory.Packages.props"]
COPY ["src/Redirect/Redirect.csproj", "src/Redirect/"]
COPY ["src/Data/Data.csproj", "src/Data/"]
RUN dotnet restore "src/Redirect/Redirect.csproj"
COPY . .
WORKDIR "/src/src/Redirect"
RUN dotnet build "Redirect.csproj" -c $BUILD_CONFIGURATION --no-restore

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Redirect.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false --no-restore --no-build

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OpenVeer.Redirect.dll"]
