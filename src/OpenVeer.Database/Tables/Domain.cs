using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenVeer.Database.Tables
{
  public class Domain
  {
    [Key]
    public int DomainId { get; set; }

    [Required]
#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.
    public string DomainName { get; set; }
#pragma warning restore CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.

    [MaxLength(450)]
    public string? OwnerUserId { get; set; }

    public DateTime? Deleted { get; set; }

  }
}
