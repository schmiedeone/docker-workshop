db.createUser({
  user: "andy",
  pwd: "supersecret",
  roles: [
    {
      role: "readWrite",
      db: "sample-db",
    },
  ],
});
