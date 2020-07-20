docker run -v $1:/app -w /app mcr.microsoft.com/dotnet/core/sdk:3.1 bash -c "dotnet new webapi -o $2 && chown -R 1000:1000 $2"
touch $1/$2/Dockerfile

echo "FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build

WORKDIR /app

# COPY *.sln .
COPY ./*.csproj ./
RUN dotnet restore

COPY . ./
# WORKDIR /source/aspnetapp
RUN dotnet publish -c release -o /dist --no-restore

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
COPY --from=build /dist ./

EXPOSE 80
EXPOSE 5000
EXPOSE 5001

CMD [ \"dotnet\", \"$2.dll\" ]" >$1/$2/Dockerfile
