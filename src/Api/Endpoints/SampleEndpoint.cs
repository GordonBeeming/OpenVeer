// using FastEndpoints;
//
// namespace OpenVeer.Api.Endpoints.Pub;
//
// public record RedirectShortLinkRequest(string ShortLink);
//
// public sealed class RedirectShortLinkResponse
// {
//     public string Url { get; set; }
// }
//
// public sealed class RedirectShortLinkEndpoint : Endpoint<RedirectShortLinkRequest, RedirectShortLinkResponse>
// {
//   private readonly AppDbContext _context;
//
//   public RedirectShortLinkEndpoint(AppDbContext context)
//   {
//     _context = context;
//   }
//
//   public override void Configure()
//   {
//     Post("/l/{ShortLink}");
//     AllowAnonymous();
//   }
//
//   public override async Task HandleAsync(RedirectShortLinkRequest req, CancellationToken ct)
//   {
//     var domainName = this.HttpContext.Request.Host.Host;
//     var shortLink = await _context.ShortLinks
//       .Include(x => x.Domain)
//       .FirstOrDefaultAsync(x => x.Domain.DomainName == domainName && x.ShortUrl == req.ShortLink, ct);
//     await SendAsync(new()
//     {
//       FullName = req.FirstName + " " + req.LastName,
//       IsOver18 = req.Age > 18
//     });
//   }
// }
