using FastEndpoints;
using Microsoft.AspNetCore.HttpOverrides;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
  options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedHost;
});
builder.Services.AddFastEndpoints();

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseForwardedHeaders();

app.MapPost("/deploy/version", (IConfiguration configuration) => configuration["COMMIT_HASH"])
  .WithName("GetDeployVersion_POST");
app.MapGet("/deploy/version", (IConfiguration configuration) => configuration["COMMIT_HASH"])
  .WithName("GetDeployVersion_GET");
app.MapPost("/deploy/branch", (IConfiguration configuration) => configuration["BRANCH_NAME"])
  .WithName("GetDeployBranch_POST");
app.MapGet("/deploy/branch", (IConfiguration configuration) => configuration["BRANCH_NAME"])
  .WithName("GetDeployBranch_GET");

app.UseFastEndpoints();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
  app.UseSwagger();
  app.UseSwaggerUI();
}

var summaries = new[]
{
  "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
  {
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
          DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
          Random.Shared.Next(-20, 55),
          summaries[Random.Shared.Next(summaries.Length)]
        ))
      .ToArray();
    return forecast;
  })
  .WithName("GetWeatherForecast")
  .WithOpenApi();

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
  public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
