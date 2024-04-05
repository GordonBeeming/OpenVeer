using Bogus;
using OpenVeer.Data;
using OpenVeer.Data.Domain;

namespace OpenVeer.Api.Tests.Integration.Extensions;

public static class DataExtensions
{
  // public static async Task<List<Contact>> CreateContacts(this OpenVeerAPIFactory factory, int rows)
  // {
  //   var testContacts = factory.ContactFaker();
  //
  //   var data = testContacts.Generate(rows);
  //   using (var scope = factory.Services.CreateScope())
  //   {
  //     var scopedServices = scope.ServiceProvider;
  //     var dbContext = scopedServices.GetRequiredService<PhonebookDbContext>();
  //
  //     await dbContext.Contacts.AddRangeAsync(data);
  //     await dbContext.SaveChangesAsync();
  //   }
  //   return data;
  // }
  // public static Faker<Contact> ContactFaker(this OpenVeerAPIFactory factory) => new Faker<Contact>()
  //     .UseSeed(42)
  //     .RuleFor(_ => _.Name, o => o.Person.FirstName)
  //     .RuleFor(_ => _.Number, o => o.Person.Phone)
  //     .RuleFor(_ => _.Email, o => o.Person.Email)
  //     .RuleFor(_ => _.AvatarUrl, o => o.Person.Avatar);
}
