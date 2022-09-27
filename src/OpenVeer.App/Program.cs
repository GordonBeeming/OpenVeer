using System.Diagnostics.Metrics;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using OpenVeer.App.Data;
using OpenVeer.Database;

namespace OpenVeer.App
{
  public class Program
  {
    public static void Main(string[] args)
    {
      var builder = WebApplication.CreateBuilder(args);

      builder.Configuration.AddJsonFile($"appsettings.overrides.json", optional: true, reloadOnChange: true);

      // Add services to the container.
      var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
      builder.Services.AddDbContext<ApplicationDbContext>(options => options.UseSqlServer(connectionString));
      builder.Services.AddDbContext<OpenVeerDatabaseContext>(options => options.UseSqlServer(connectionString, o => o.MigrationsAssembly("OpenVeer.Database")));
      builder.Services.AddDatabaseDeveloperPageExceptionFilter();

      builder.Services.AddDefaultIdentity<IdentityUser>(options => options.SignIn.RequireConfirmedAccount = true)
          .AddEntityFrameworkStores<ApplicationDbContext>();
      builder.Services.AddControllersWithViews();

      var app = builder.Build();

      // Configure the HTTP request pipeline.
      if (app.Environment.IsDevelopment())
      {
        app.UseMigrationsEndPoint();
      }
      else
      {
        app.UseExceptionHandler("/Home/Error");
        // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
        app.UseHsts();
      }

      app.UseHttpsRedirection();
      app.UseStaticFiles();

      app.UseRouting();

      app.UseAuthorization();

      app.MapControllerRoute(
          name: "default",
          pattern: "{controller=Home}/{action=Index}/{id?}");
      app.MapRazorPages();

      using (var serviceScope = app.Services.GetRequiredService<IServiceScopeFactory>().CreateScope())
      {
        var applicationDbContext = serviceScope.ServiceProvider.GetService<ApplicationDbContext>();
        applicationDbContext!.Database.Migrate();

        var openVeerDatabaseContext = serviceScope.ServiceProvider.GetService<OpenVeerDatabaseContext>();
        openVeerDatabaseContext!.Database.Migrate();
      }


      app.Run();
    }
  }
}
