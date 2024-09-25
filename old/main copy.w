bring cloud;
bring vite;
bring util;
bring dynamodb;
bring "./types.w" as types;
bring "./tables/SpaceTable.w" as Tables;

bring email;

let api = new cloud.Api({ cors: true});
let spaceTable = new Tables.SpaceTable();

let bucket = new cloud.Bucket({ cors: true}) as "Space Bucket";
let emailSender = new email.Email(sender: "hello@quickshare.net");

// Group APIS into its own class
// Table new API(table);
// Also good tests...

// Raise a ticket for this....
// bucket.onCreate(prefix: 'spaces-")


bucket.onCreate(inflight (key: str) => {
    // key what is .......
});

// api.post("/spaces", inflight (req: cloud.ApiRequest) => {

//   if (req.body == nil) {
//     return cloud.ApiResponse {
//       status: 400,
//       body: "Bad Request",
//     };
//   }

//   let id = util.uuidv4();
//   let space:types.Space = { id, createdAt: datetime.utcNow().toIso(), locked: false };

//   spaceTable.createSpace(space);

//   return cloud.ApiResponse {
//     status: 201,
//     body: Json.stringify(space),
//   };
// });

// api.get("/spaces/:spaceId", inflight (req: cloud.ApiRequest) => {

//   let spaceId = req.vars.get("spaceId");
//   let space = spaceTable.getSpaceById(spaceId);
//   let friends = spaceTable.getFriends(spaceId);

//   if space == nil {
//     return cloud.ApiResponse {
//       status: 404,
//       body: "Not Found",
//     };
//   }

//   return cloud.ApiResponse {
//     body: Json.stringify(space),
//   };

// });

struct File {
  id: str;
}

api.post("/spaces/:spaceId/upload_url", inflight (req: cloud.ApiRequest) => {

  if (req.body == nil) {
    return cloud.ApiResponse {
      status: 400,
      body: "Bad Request",
    };
  }

  let spaceId = req.vars.get("spaceId");

  if let payload = Json.tryParse(req.body) {
    let filename = payload.get("filename").asStr();
    let filetype = payload.get("type").asStr();
    let file:types.File = { id: util.uuidv4(), createdAt: datetime.utcNow().toIso(), filename: filename, type: filetype };

    // get presigned url
    let url = bucket.signedUrl(spaceId, { 
      action: cloud.BucketSignedUrlAction.UPLOAD,
      duration: 2m
    });

    // add the file to the table
    spaceTable.addNewFile(req.vars.get("spaceId"), file);  

    return cloud.ApiResponse {
      body: Json.stringify({
        file,
        url
      })
    };
  } else {
    return cloud.ApiResponse {
      status: 500,
      body: "Failed to process request",
    };
  }


  // let id = util.uuidv4();
  // let space:types.Space = { id, createdAt: datetime.utcNow().toIso(), filename:  };

  // // upload the space table with new upload

  

  // let url = bucket.signedUrl(spaceId, { 
  //   action: cloud.BucketSignedUrlAction.UPLOAD,
  //   duration: 2m
  // });

  // return cloud.ApiResponse {
  //   body: Json.stringify({ url }),
  // };

});

api.get("/spaces/:spaceId/upload_url", inflight (req: cloud.ApiRequest) => {


  // upload the space table with new upload

  let spaceId = req.vars.get("spaceId");

  let url = bucket.signedUrl(spaceId, { 
    action: cloud.BucketSignedUrlAction.UPLOAD,
    duration: 2m
  });

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

  let random = Json.tryParse(req.body);

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