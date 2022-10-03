using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace OpenVeer.Database.Migrations
{
    /// <inheritdoc />
    public partial class BasicStartingTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Domains",
                columns: table => new
                {
                    DomainId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DomainName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    OwnerUserId = table.Column<string>(type: "nvarchar(450)", maxLength: 450, nullable: true),
                    Deleted = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Domains", x => x.DomainId);
                });

            migrationBuilder.CreateTable(
                name: "ShortLinks",
                columns: table => new
                {
                    Token = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false, collation: "SQL_Latin1_General_CP1_CS_AS"),
                    DomainId = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                    Created = table.Column<DateTime>(type: "datetime2", nullable: false),
                    LongUrl = table.Column<string>(type: "nvarchar(2048)", maxLength: 2048, nullable: false),
                    Archived = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Deleted = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ShortLinks", x => x.Token);
                    table.ForeignKey(
                        name: "FK_ShortLinks_Domains_DomainId",
                        column: x => x.DomainId,
                        principalTable: "Domains",
                        principalColumn: "DomainId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ShortLinks_DomainId",
                table: "ShortLinks",
                column: "DomainId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ShortLinks");

            migrationBuilder.DropTable(
                name: "Domains");
        }
    }
}
