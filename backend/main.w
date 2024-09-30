bring vite;
bring "./routes/api.w" as API;
bring cloud;

// Routes
bring "./routes/friends.w" as Friend;
bring "./routes/spaces.w" as Space;

// Database
bring "./db/db.w" as Database;

// Services
bring "./services/spaces.w" as Spaces;
bring "./services/friends.w" as Friends;
bring "./services/notifications.w" as Notifications;

// create new database
let db = new Database.Instance("SpacesTable");

// create new api
let api = new API.Instance() as "API";

// Services
let spaceService = new Spaces.SpaceService(db, new cloud.Bucket({ cors: true }));
let friendsService = new Friends.FriendsService(db);
let emailService = new Notifications.NotificationService();

// Register routes to the api
api.register(new Space.Routes({ spaceService, friendsService }) as "Space Routes");
api.register(new Friend.Routes({ friendsService }) as "Freind Routes");

// Register listners for changes in the database
spaceService.listenForDBChanges(friendsService, emailService);

// Create the website
let website = new vite.Vite(
  root: "../ui",
  publicEnv: {
    API_URL: api.url 
  },
);