SCAFFOLD="dotnet new webapi -o $2; dotnet add ./$2/$2.csproj package MongoDB.Driver -v 2.10.4; chown -R 1000:1000 $2"
docker run -v $1:/app -w /app mcr.microsoft.com/dotnet/core/sdk:3.1 bash -c "$SCAFFOLD"
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

CMD [ \"dotnet\", \"$2.dll\" ]" >$1/$2/Dockerfile

cp .dockerignore-template $1/$2/.dockerignore
cp .gitignore-template $1/$2/.gitignore
cp init-mongo.js $1/$2/

PORT=8080

echo "version: \"3\"
services:
  app:
    build: .
    container_name: \"webapi\"
    ports:
      - $PORT:80
    depends_on:
      - db
  db:
    image: mongo
    container_name: \"mongo-container\"
    environment:
      - MONGO_INITDB_DATABASE=sample-db
      - MONGO_INITDB_ROOT_USERNAME=root
      - MONGO_INITDB_ROOT_PASSWORD=root-password
    volumes:
      - ./init-mongo.js:/docker-entrypoint-initdb.d/init-mongo.js:ro
      - ./mongo-volume:/data/db
    ports:
      - 27017:27017
" >$1/$2/docker-compose.yml

echo "Running dockererized app on port $PORT"
docker-compose -f $1/$2/docker-compose.yml up --build
