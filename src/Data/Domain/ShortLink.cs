namespace OpenVeer.Data.Domain;

public sealed class ShortLink
{
  public required string Id { get; set; }
  public required string DomainId { get; set; }
  public required string OriginalUrl { get; set; }
  public required string ShortUrl { get; set; }
  public required string Title { get; set; }
  public DateTimeOffset CreatedAt { get; set; }

#pragma warning disable CS8618
  public LinkDomain Domain { get; set; }
  public ICollection<ShortLinkUsage> ShortLinkUsages { get; set; }
}
