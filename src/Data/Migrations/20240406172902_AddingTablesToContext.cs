using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace OpenVeer.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddingTablesToContext : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ShortLinks_LinkDomain_DomainId",
                table: "ShortLinks");

            migrationBuilder.DropForeignKey(
                name: "FK_ShortLinkUsage_ShortLinks_ShortLinkId",
                table: "ShortLinkUsage");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ShortLinkUsage",
                table: "ShortLinkUsage");

            migrationBuilder.DropPrimaryKey(
                name: "PK_LinkDomain",
                table: "LinkDomain");

            migrationBuilder.RenameTable(
                name: "ShortLinkUsage",
                newName: "ShortLinkUsages");

            migrationBuilder.RenameTable(
                name: "LinkDomain",
                newName: "LinkDomains");

            migrationBuilder.RenameIndex(
                name: "IX_ShortLinkUsage_ShortLinkId",
                table: "ShortLinkUsages",
                newName: "IX_ShortLinkUsages_ShortLinkId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_ShortLinkUsages",
                table: "ShortLinkUsages",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_LinkDomains",
                table: "LinkDomains",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_ShortLinks_LinkDomains_DomainId",
                table: "ShortLinks",
                column: "DomainId",
                principalTable: "LinkDomains",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ShortLinkUsages_ShortLinks_ShortLinkId",
                table: "ShortLinkUsages",
                column: "ShortLinkId",
                principalTable: "ShortLinks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ShortLinks_LinkDomains_DomainId",
                table: "ShortLinks");

            migrationBuilder.DropForeignKey(
                name: "FK_ShortLinkUsages_ShortLinks_ShortLinkId",
                table: "ShortLinkUsages");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ShortLinkUsages",
                table: "ShortLinkUsages");

            migrationBuilder.DropPrimaryKey(
                name: "PK_LinkDomains",
                table: "LinkDomains");

            migrationBuilder.RenameTable(
                name: "ShortLinkUsages",
                newName: "ShortLinkUsage");

            migrationBuilder.RenameTable(
                name: "LinkDomains",
                newName: "LinkDomain");

            migrationBuilder.RenameIndex(
                name: "IX_ShortLinkUsages_ShortLinkId",
                table: "ShortLinkUsage",
                newName: "IX_ShortLinkUsage_ShortLinkId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_ShortLinkUsage",
                table: "ShortLinkUsage",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_LinkDomain",
                table: "LinkDomain",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_ShortLinks_LinkDomain_DomainId",
                table: "ShortLinks",
                column: "DomainId",
                principalTable: "LinkDomain",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ShortLinkUsage_ShortLinks_ShortLinkId",
                table: "ShortLinkUsage",
                column: "ShortLinkId",
                principalTable: "ShortLinks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
