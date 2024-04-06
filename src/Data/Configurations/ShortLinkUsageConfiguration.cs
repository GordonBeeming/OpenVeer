namespace OpenVeer.Data.Configurations;

public sealed class ShortLinkUsageConfiguration
{
  public void Configure(EntityTypeBuilder<ShortLinkUsage> builder)
  {
    builder.ToTable("tb_ShortLinkUsage");

    builder.HasKey(o => new { o.Id })
      .HasName("PK_ShortLinkUsage");
    builder.Property(o => o.Id)
      .UseIdentityColumn(1, 1)
      .IsRequired();

    builder.Property(o => o.ShortLinkId)
      .HasMaxLength(10)
      .IsFixedLength()
      .IsRequired();
    builder.HasOne(sl => sl.ShortLink)
      .WithMany(ld => ld.ShortLinkUsages)
      .HasForeignKey(sl => sl.ShortLinkId)
      .HasConstraintName("FK_ShortLinkUsage_ShortLink");

    builder.Property(o => o.IPAddress)
      .HasMaxLength(39)
      .IsRequired();

    builder.Property(o => o.UserAgent)
      .HasMaxLength(1024)
      .IsRequired();

    builder.Property(o => o.Referer)
      .HasMaxLength(2048)
      .IsRequired();

    builder.Property(o => o.CreatedAt)
      .HasDefaultValueSql("SYSUTCDATETIME()")
      .IsRequired()
      .HasPrecision(7)
      .ValueGeneratedOnAdd();
  }
}
