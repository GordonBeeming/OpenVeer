using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Debug;
using OpenVeer.Data;
using OpenVeer.Data.Domain;

#if DEBUG
var debugLoggerFactory = new LoggerFactory(new[] { new DebugLoggerProvider() });
#endif

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
  options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedHost;
  options.KnownNetworks.Clear();
  options.KnownProxies.Clear();
});
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ??
                       throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
builder.Services.AddDbContext<AppDbContext>(options =>
{
  options.UseSqlServer(connectionString, sqlServerOptions => sqlServerOptions.CommandTimeout(10));
#if DEBUG
  options.UseLoggerFactory(debugLoggerFactory);
  options.EnableSensitiveDataLogging(true);
#endif
});

var app = builder.Build();

app.MapGet("/{shortLinkPath}",
    async (HttpContext context, string shortLinkPath, AppDbContext db, CancellationToken ct) =>
    {
      var host = context.Request.Host.Host;
      var shortUrl = $"{host}/{shortLinkPath}";
      var shortLink = await db.ShortLinks
        .Where(x => x.ShortUrl == shortUrl)
        .Select(o => new { o.Id, o.OriginalUrl })
        .FirstOrDefaultAsync(ct);
      if (shortLink is not null)
      {
        db.ShortLinkUsages.Add(new ShortLinkUsage
        {
          ShortLinkId = shortLink.Id,
          IPAddress = context.Connection.RemoteIpAddress?.ToString() ?? "Unknown",
          Referer = context.Request.Headers.Referer.ToString(),
          UserAgent = context.Request.Headers.UserAgent.ToString(),
        });
        await db.SaveChangesAsync();
        context.Response.Redirect(shortLink.OriginalUrl, permanent: false);
        return;
      }
      var domain = await db.LinkDomains
        .Where(x => x.DomainName == host)
        .Select(o => new { o.RedirectToOn404 })
        .FirstOrDefaultAsync(ct);
      if (domain is not null)
      {
        context.Response.Redirect(domain.RedirectToOn404, permanent: false);
        return;
      }
      //should never get here
      context.Response.StatusCode = StatusCodes.Status404NotFound;
    })
  .WithName("HandleRedirect");

app.Run();
