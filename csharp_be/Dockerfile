FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS builder

WORKDIR /app

# tải thư viện
COPY csharp-be.csproj .
RUN dotnet restore

# build
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine

WORKDIR /app

COPY --from=builder /app/publish .

EXPOSE 8080

CMD ["dotnet", "csharp-be.dll"]

# docker build -t csharp_be_image .
# docker run --name csharp_be_container -d -p 8001:8080 --env-file=.env csharp_be_image

