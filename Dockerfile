   FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
   WORKDIR /src
   COPY . .
   RUN dotnet restore Rise.sln
   RUN dotnet test Rise.sln --no-restore
   RUN dotnet publish src/Rise.Server/Rise.Server.csproj -c Release -o /app/publish --no-restore

   FROM mcr.microsoft.com/dotnet/aspnet:9.0
   WORKDIR /app
   COPY --from=build /app/publish .
   ENV ASPNETCORE_URLS=http://+:8080
   EXPOSE 8080
   ENTRYPOINT ["dotnet", "Rise.Server.dll"]
