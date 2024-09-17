bring cloud;
bring vite;
bring util;
bring dynamodb;
bring "./types.w" as types;
bring "./table.w" as Tables;

let api = new cloud.Api({ cors: true});
let spaceTable = new Tables.SpaceTable();

let bucket = new cloud.Bucket({ cors: true}) as "Space Bucket";


api.post("/spaces", inflight (req: cloud.ApiRequest) => {

  if (req.body == nil) {
    return cloud.ApiResponse {
      status: 400,
      body: "Bad Request",
    };
  }

  let id = util.uuidv4();
  let space:types.Space = { id, createdAt: datetime.utcNow().toIso(), locked: false };

  spaceTable.createSpace(space);

  return cloud.ApiResponse {
    status: 201,
    body: Json.stringify(space),
  };
});

api.get("/spaces/:spaceId", inflight (req: cloud.ApiRequest) => {

  let spaceId = req.vars.get("spaceId");
  let space = spaceTable.getSpaceById(spaceId);
  let friends = spaceTable.getFriends(spaceId);

  if space == nil {
    return cloud.ApiResponse {
      status: 404,
      body: "Not Found",
    };
  }

  return cloud.ApiResponse {
    body: Json.stringify(space),
  };

});

api.get("/spaces/:spaceId/upload_url", inflight (req: cloud.ApiRequest) => {

  let spaceId = req.vars.get("spaceId");

  // let url = bucket.signedUrl(spaceId, { 
  //   action: cloud.BucketSignedUrlAction.DOWNLOAD,
  //   duration: 2m
  // });

  // Fake URL for now... until SIM is fixed
  let url = "https://my-bucket.s3.amazonaws.com/my-object.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20220101%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220101T000000Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=56b3c05c36efd4b1b34eb3a7232496c4a30f8f8f9f6fd98979d09a3f6e82744a";


  return cloud.ApiResponse {
    body: Json.stringify({ url }),
  };

});

api.delete("/spaces/:spaceId/friends/:friendId", inflight (req:cloud.ApiRequest) => {

  spaceTable.removeFriendById(req.vars.get("spaceId"),req.vars.get("friendId"));

  return cloud.ApiResponse {
    status: 200,
    body: ""
  };

});

api.post("/spaces/:spaceId/friends", inflight (req: cloud.ApiRequest) => {

  if (req.body == nil) {
    return cloud.ApiResponse {
      status: 400,
      body: "Bad Request",
    };
  }

  // log(Json.stringify(req.body));

  let random = Json.tryParse(req.body);
  log(Json.stringify(random));

  if let payload = Json.tryParse(req.body) {
    let email = payload.get("email").asStr();
    let friend:types.Friend = { id: util.uuidv4(), createdAt: datetime.utcNow().toIso(), email: email };
    spaceTable.addFriend(req.vars.get("spaceId"), friend);  
    return cloud.ApiResponse {
      body: Json.stringify(friend)
    };
  } else {
    return cloud.ApiResponse {
      status: 500,
      body: "Failed to process request",
    };
  }
  
});

// Get all the friends for a space
api.get("/spaces/:spaceId/friends", inflight (req:cloud.ApiRequest) => {

  let friends = spaceTable.getFriends(req.vars.get("spaceId"));

  if friends == nil {
    return cloud.ApiResponse {
      status: 404,
      body: "Not Found",
    };
  }

  return cloud.ApiResponse {
    body: Json.stringify(friends),
  };

});

// share files with all friends
api.post("/spaces/:spaceId/lock", inflight (req: cloud.ApiRequest) => {

  let spaceId = req.vars.get("spaceId");

  spaceTable.lockSpace(spaceId);

  return cloud.ApiResponse {
    status: 200,
    body: Json.stringify({ locked: true }),
  };

});

// Create the website
let website = new vite.Vite(
  root: "../ui",
  publicEnv: {
    API_URL: api.url,
  },
);