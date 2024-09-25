bring vite;
bring "./routes/api.w" as API;
bring cloud;

// Routes
bring "./routes/friends.w" as Friend;
bring "./routes/spaces.w" as Space;

// Database
bring "./db/db.w" as Database;

// Models
bring "./models/spaces.w" as Spaces;
bring "./models/friends.w" as Friends;

// create new database
let db = new Database.Instance("SpacesTable");

// create new api
let api = new API.Instance() as "API";

// Data models
let spaceModel = new Spaces.SpaceModel(db, new cloud.Bucket({ cors: true }));
let friendModel = new Friends.FriendModel(db);

// Register routes to the api
api.register(new Space.Routes({ spaceModel, friendModel }) as "Space Routes");
api.register(new Friend.Routes({ friendModel }) as "Freind Routes");

// Create the website
let website = new vite.Vite(
  root: "../ui",
  publicEnv: {
    API_URL: api.url 
  },
);