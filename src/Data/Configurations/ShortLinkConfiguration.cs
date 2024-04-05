namespace OpenVeer.Data.Configurations;

public sealed class ShortLinkConfiguration
{
  public void Configure(EntityTypeBuilder<ShortLink> builder)
  {
    builder.ToTable("tb_ShortLink");

    builder.HasKey(e => new { e.Id })
      .HasName("PK_ShortLink");
    builder.Property(t => t.Id)
      .HasDefaultValueSql("NEWID()");

    // builder.Property(t => t.Name)
    //   .HasMaxLength(50)
    //   .IsRequired();
    //
    // builder.Property(t => t.Number)
    //   .HasMaxLength(20)
    //   .IsRequired();
    //
    // builder.Property(t => t.Email)
    //   .HasMaxLength(100);
    //
    // builder.Property(t => t.AvatarUrl)
    //   .HasMaxLength(1024);
  }
}
