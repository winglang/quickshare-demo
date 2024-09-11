bring cloud;
bring vite;
bring util;
bring dynamodb;
bring "./types.w" as types;
bring "./table.w" as Tables;

let api = new cloud.Api({ cors: true});
let spaceTable = new Tables.SpaceTable();

api.post("/space", inflight (req: cloud.ApiRequest) => {

  if (req.body == nil) {
    return cloud.ApiResponse {
      status: 400,
      body: "Bad Request",
    };
  }

  let id = util.uuidv4();
  let space:types.Space = { id, createdAt: datetime.utcNow().toIso() };

  spaceTable.createSpace(space);

  return cloud.ApiResponse {
    status: 201,
    body: Json.stringify(space),
  };
});

api.get("/space/:spaceId", inflight (req: cloud.ApiRequest) => {

  let spaceId = req.vars.get("spaceId");
  let space = spaceTable.getSpaceById(spaceId);

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

/**
  Freinds API
*/
api.post("/spaces/:spaceId/friends", inflight (req: cloud.ApiRequest) => {

  if (req.body == nil) {
    return cloud.ApiResponse {
      status: 400,
      body: "Bad Request",
    };
  }

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


api.get("/space/:spaceId/friends/:friendId", inflight (req:cloud.ApiRequest) => {

  let friend = spaceTable.getFriendById(req.vars.get("spaceId"),req.vars.get("friendId"));

  if friend == nil {
    return cloud.ApiResponse {
      status: 404,
      body: "Not Found",
    };
  }

  return cloud.ApiResponse {
    body: Json.stringify(friend),
  };

});

// Create the website
let website = new vite.Vite(
  root: "../ui",
  publicEnv: {
    API_URL: api.url,
  },
);