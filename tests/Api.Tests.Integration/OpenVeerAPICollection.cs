namespace OpenVeer.Api.Tests.Integration;

[CollectionDefinition(Definition)]
public sealed class OpenVeerAPICollection : ICollectionFixture<OpenVeerAPIFactory>
{
  public const string Definition = nameof(OpenVeerAPICollection);
}
