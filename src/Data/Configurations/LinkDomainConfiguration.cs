namespace OpenVeer.Data.Configurations;

public sealed class LinkDomainConfiguration
{
  public void Configure(EntityTypeBuilder<LinkDomain> builder)
  {
    builder.ToTable("tb_LinkDomain");

    builder.HasKey(o => new { o.DomainName })
      .HasName("PK_LinkDomain");
    builder.Property(o => o.DomainName)
      .HasMaxLength(253);

    builder.Property(o => o.Id)
      .HasMaxLength(10)
      .IsFixedLength()
      .IsRequired();
    builder.HasIndex(o => o.Id)
      .IsUnique();

    builder.Property(o => o.Verified)
      .IsRequired();

    builder.Property(o => o.RedirectToOn404)
      .IsRequired();

    builder.Property(o => o.TxtRecordName)
      .HasMaxLength(250)
      .IsRequired();

    builder.Property(o => o.TxtRecordName)
      .HasMaxLength(64)
      .IsRequired();

    builder.Property(o => o.TxtRecordValue)
      .HasMaxLength(64)
      .IsRequired();

    builder.Property(o => o.CreatedAt)
      .HasDefaultValueSql("SYSUTCDATETIME()")
      .HasColumnType("DATETIMEOFFSET(7)")
      .IsRequired()
      .ValueGeneratedOnAdd();
  }
}
