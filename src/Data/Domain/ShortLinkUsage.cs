namespace OpenVeer.Data.Domain;

public sealed class ShortLinkUsage
{
  public long Id { get; set; }
  public required string ShortLinkId { get; set; }
  public required string IPAddress { get; set; }
  public required string UserAgent { get; set; }
  public required string Referer { get; set; }
  public DateTimeOffset CreatedAt { get; set; }

#pragma warning disable CS8618
  public ShortLink ShortLink { get; set; }
}
