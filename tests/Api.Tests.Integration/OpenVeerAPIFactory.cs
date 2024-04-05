using DotNet.Testcontainers.Builders;
using DotNet.Testcontainers.Configurations;
using DotNet.Testcontainers.Containers;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using WebMotions.Fake.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace OpenVeer.Api.Tests.Integration;

public sealed class OpenVeerAPIFactory : WebApplicationFactory<IApiMarker>, IAsyncLifetime
{
  private readonly IContainer _dbContainer;
  private readonly GravatarServer _gravatarServer;

  private const string Databaseusername = "sa";
  private const string DatabasePassword = "!U6tQrYmDPWvjBX6-Pfi";

  public OpenVeerAPIFactory()
  {
    _dbContainer = new ContainerBuilder()
        .WithImage("mcr.microsoft.com/azure-sql-edge")
        .WithEnvironment("SA_PASSWORD", DatabasePassword)
        .WithEnvironment("ACCEPT_EULA", "Y")
        .WithExposedPort(1433)
        .WithPortBinding(1433, true)
        .Build();
    _gravatarServer = new();
  }

  public string? GravatarServerUrl => _gravatarServer.Url;

  protected override void ConfigureWebHost(IWebHostBuilder builder)
  {
    builder.ConfigureAppConfiguration(config =>
    {
      config.AddCommandLine(new[] { $"ConnectionStrings:DefaultConnection=Server={_dbContainer.Hostname},{_dbContainer.GetMappedPublicPort(1433)};Database=OpenVeer-Phonebook;User Id={Databaseusername};Password={DatabasePassword};MultipleActiveResultSets=true;TrustServerCertificate=True" });
    });

    builder.ConfigureTestServices(services =>
    {
      services.AddAuthentication(options =>
      {
        options.DefaultAuthenticateScheme = FakeJwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = FakeJwtBearerDefaults.AuthenticationScheme;
      }).AddFakeJwtBearer();

      services.AddHttpClient("Gravatar", configure =>
      {
        configure.BaseAddress = new Uri(_gravatarServer.Url!);
      });
    });
  }

  public new HttpClient CreateClient()
  {
    var httpClient = base.CreateClient();
    return httpClient;
  }

  public HttpClient CreateAuthenticatedClient(string userId)
  {
    var httpClient = CreateClient();
    httpClient.SetFakeBearerToken(userId.ToString());
    return httpClient;
  }

  public async Task InitializeAsync()
  {
    _gravatarServer.Start();
    _gravatarServer.SetupAvatar(ValidGravatarEmail);
    await _dbContainer.StartAsync();
    RunMigrations();
  }

  public new async Task DisposeAsync()
  {
    await _dbContainer.DisposeAsync();
    await base.DisposeAsync();
    _gravatarServer.Dispose();
  }

  private void RunMigrations()
  {
    using var serviceScope = Services.GetRequiredService<IServiceScopeFactory>().CreateScope();
    // var applicationDbContext = serviceScope.ServiceProvider.GetRequiredService<PhonebookDbContext>();
    // applicationDbContext.Database.Migrate();
  }
}
