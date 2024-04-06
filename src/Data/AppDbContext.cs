namespace OpenVeer.Data;

#pragma warning disable CS8618
public sealed class AppDbContext : DbContext
{
  public AppDbContext(DbContextOptions options) : base(options)
  {
  }

  public DbSet<ShortLink> ShortLinks { get; set; }
  public DbSet<ShortLinkUsage> ShortLinkUsages { get; set; }
  public DbSet<LinkDomain> LinkDomains { get; set; }

  protected override void OnModelCreating(ModelBuilder builder)
  {
    base.OnModelCreating(builder);

    builder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
  }
}
