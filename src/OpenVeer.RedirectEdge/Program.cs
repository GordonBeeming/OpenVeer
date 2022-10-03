using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using OpenVeer.Database;
using Serilog;
using ILogger = Microsoft.Extensions.Logging.ILogger;

namespace OpenVeer.RedirectEdge
{
  public class Program
  {
    public static void Main(string[] args)
    {
      var builder = WebApplication.CreateBuilder(args);

      builder.Configuration.AddJsonFile($"appsettings.overrides.json", optional: true, reloadOnChange: false);

      var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
      builder.Services.AddDbContext<OpenVeerDatabaseContext>(options => options.UseSqlServer(connectionString, o => o.MigrationsAssembly("OpenVeer.Database")));

      builder.Services.AddApplicationInsightsTelemetry();

      var logger = new LoggerConfiguration()
          .ReadFrom.Configuration(builder.Configuration)
          .Enrich.FromLogContext()
          .CreateLogger();

      builder.Logging.ClearProviders();
      builder.Logging.AddSerilog(logger);

      var app = builder.Build();

      app.MapGet("/{*fullPath}", async (context) =>
      {
        var domain = context.Request.Host.HasValue ? context.Request.Host.Value : null;
        var path = context.Request.Path.HasValue ? context.Request.Path.Value.Remove(0, 1) : null;
        if (path == null || path.Length == 0 || domain == null || domain.Length == 0)
        {
#if !DEBUG
          await Results.Redirect("https://devstarops.com", false).ExecuteAsync(context);
#endif
          return;
        }
        var logger = context.RequestServices.GetService<ILogger<Program>>();
        if (logger == null)
        {
          await Results.StatusCode(500).ExecuteAsync(context);
          return;
        }

        if (IgnorePath("favicon.ico", path, logger))
        {
          await Results.NotFound().ExecuteAsync(context);
          return;
        }

        var dbContext = context.RequestServices.GetService<OpenVeerDatabaseContext>();
        if (dbContext == null)
        {
          logger.LogCritical($"Unable to load service {nameof(OpenVeerDatabaseContext)}.");
          await Results.StatusCode(500).ExecuteAsync(context);
          return;
        }

        var configuration = context.RequestServices.GetService<IConfiguration>();
        if (configuration == null)
        {
          logger.LogCritical($"Unable to load service {nameof(IConfiguration)}.");
          await Results.StatusCode(500).ExecuteAsync(context);
          return;
        }

        if (domain == configuration["DefaultDomain"])
        {
          domain = "default";
        }

        var link = await dbContext.ShortLinks
            .FirstOrDefaultAsync(o => o.Token == path &&
            (domain == null || o.Domain.DomainName == domain));

        if (link == null)
        {
          logger.LogInformation($"404: token {path}");
          await Results.NotFound().ExecuteAsync(context);
          return;
        }

        logger.LogDebug($"Redirect token {path} to {link.LongUrl}");
        await Results.Redirect(link.LongUrl, false).ExecuteAsync(context);
      });

      using (var serviceScope = app.Services.GetRequiredService<IServiceScopeFactory>().CreateScope())
      {
        var openVeerDatabaseContext = serviceScope.ServiceProvider.GetService<OpenVeerDatabaseContext>();
        openVeerDatabaseContext!.Database.Migrate();
      }

      app.Run();
    }

    private static bool IgnorePath(string pathToIgnore, string path, ILogger logger)
    {
     if ( path.Equals(pathToIgnore, StringComparison.InvariantCultureIgnoreCase))
      {
        logger.LogInformation($"Ignore path {pathToIgnore} requested.");
        return true;
      }
      return false;
    }
  }
}
