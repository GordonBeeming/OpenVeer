# OpenVeer
A complete reboot of the previous OpenVeer repository, now private at https://github.com/GordonBeeming/zzOpenVeer

## Getting Started

1. Make sure you have .net 9 installed on your machine.
2. Clone the repo
3. Open a terminal and navigate to the root of the project
4. Run the follow command to create and update deploy the database

```
pwsh -c ". ./up.ps1"
```

5. Start coding!

## Database Changes

Once new tables are added to the database context, you will need to run the following command to generate the migration files:

    dotnet tool restore
    cd src
    dotnet dotnet-ef migrations add {{ NAME OF MIGRATION }} --context AppDbContext --project 'Data' --startup-project 'Api'
