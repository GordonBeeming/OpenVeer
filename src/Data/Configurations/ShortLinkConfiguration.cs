namespace OpenVeer.Data.Configurations;

public sealed class ShortLinkConfiguration
{
  public void Configure(EntityTypeBuilder<ShortLink> builder)
  {
    builder.ToTable("tb_ShortLink");

    builder.HasKey(o => new { o.Id })
      .HasName("PK_ShortLink");
    builder.Property(o => o.Id)
      .HasMaxLength(10)
      .IsFixedLength()
      .IsRequired();
    builder.HasIndex(o => o.Id)
      .IsUnique();

    builder.Property(o => o.DomainId)
      .HasMaxLength(10)
      .IsFixedLength()
      .IsRequired();
    builder.HasOne(sl => sl.Domain)
      .WithMany(ld => ld.ShortLinks)
      .HasForeignKey(sl => sl.DomainId)
      .HasConstraintName("FK_ShortLink_LinkDomain");

    builder.Property(t => t.Title)
      .HasMaxLength(250)
      .IsRequired();

    builder.Property(o => o.OriginalUrl)
      .IsRequired();

    builder.Property(o => o.ShortUrl)
      .IsRequired()
      .UseCollation("SQL_Latin1_General_CP1_CS_AS");

    builder.Property(o => o.CreatedAt)
      .HasDefaultValueSql("SYSUTCDATETIME()")
      .HasColumnType("DATETIMEOFFSET(7)")
      .IsRequired()
      .ValueGeneratedOnAdd();
  }
}
