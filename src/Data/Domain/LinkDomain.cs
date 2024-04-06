namespace OpenVeer.Data.Domain;

public sealed class LinkDomain
{
  public required string Id { get; set; }
  public required string DomainName { get; set; }
  public required string RedirectToOn404 { get; set; }
  public required bool Verified { get; set; }
  public required string TxtRecordName { get; set; }
  public required string TxtRecordValue { get; set; }
  public DateTimeOffset CreatedAt { get; set; }

#pragma warning disable CS8618
  public ICollection<ShortLink> ShortLinks { get; set; }
}
