﻿using Microsoft.EntityFrameworkCore.Design;

namespace OpenVeer.Data;

public sealed class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
  public AppDbContext CreateDbContext(string[] args)
  {
    var optionsBuilder = new DbContextOptionsBuilder<AppDbContext>();
    optionsBuilder.UseSqlServer();
    return new AppDbContext(optionsBuilder.Options);
  }
}
