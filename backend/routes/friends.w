bring "./route.w" as Route;
bring "../models/friends.w" as Friends;
bring cloud;
bring util;

struct Props {
    friendModel: Friends.FriendModel;
}

pub class Routes extends Route.BaseRoute {
    pub friendModel: Friends.FriendModel;
    new (props: Props){
        super();
        this.friendModel = props.friendModel;
    }
    pub init() {
        this.api?.get("/spaces/:spaceId/friends", inflight (req: cloud.ApiRequest) => {

            let friends = this.friendModel.getFriends(req.vars.get("spaceId"));

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

        // Add a friend
        this.api?.post("/spaces/:spaceId/friends", inflight (req: cloud.ApiRequest) => {

            if (req.body == nil) {
                return cloud.ApiResponse {
                status: 400,
                body: "Bad Request",
                };
            }

            let random = Json.tryParse(req.body);

            if let payload = Json.tryParse(req.body) {
                let email = payload.get("email").asStr();
                let friend:Friends.Friend = { id: util.uuidv4(), createdAt: datetime.utcNow().toIso(), email: email };
                this.friendModel.addFriend(req.vars.get("spaceId"), friend);
                return cloud.ApiResponse {
                    body: Json.stringify(friend)
                };
            } else {
                return cloud.ApiResponse {
                status: 400,
                body: "Invalid payload for friend",
                };
            }
  
        });

        this.api?.delete("/spaces/:spaceId/friends/:friendId", inflight (req:cloud.ApiRequest) => {
            this.friendModel.removeFriendById(req.vars.get("spaceId"),req.vars.get("friendId"));

            return cloud.ApiResponse {
                status: 200,
                body: ""
            };

        });

    }
}