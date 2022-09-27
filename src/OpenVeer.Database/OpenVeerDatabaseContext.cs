using Microsoft.EntityFrameworkCore;
using OpenVeer.Database.Tables;

namespace OpenVeer.Database
{
  public class OpenVeerDatabaseContext : DbContext
  {
    public OpenVeerDatabaseContext(DbContextOptions<OpenVeerDatabaseContext> options)
        : base(options)
    {
      
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
      modelBuilder.Entity<ShortLink>().HasQueryFilter(b => EF.Property<DateTime?>(b, "Deleted") == null);
      modelBuilder.Entity<Domain>().HasQueryFilter(b => EF.Property<DateTime?>(b, "Deleted") == null);
    }

    public DbSet<ShortLink> ShortLinks { get; set; }
    
    public DbSet<Domain> Domains { get; set; }
  }
}
