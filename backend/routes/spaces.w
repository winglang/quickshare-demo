bring "./route.w" as Route;
bring "../models/spaces.w" as Spaces;
bring "../models/friends.w" as Friends;
bring cloud;
bring util;

struct Props {
    spaceModel: Spaces.SpaceModel;
    friendModel: Friends.FriendModel;
}

pub class Routes extends Route.BaseRoute {
    pub spaceModel: Spaces.SpaceModel;
    pub friendModel: Friends.FriendModel;
    new (props: Props){
        super();
        this.spaceModel = props.spaceModel;
        this.friendModel = props.friendModel;
    }
    pub init() {
        
        this.api?.post("/spaces", inflight (req: cloud.ApiRequest) => {
            if (req.body == nil) {
                return cloud.ApiResponse {
                    status: 400,
                    body: "Bad Request",
                };
                }

            let id = util.uuidv4();
            let space:Spaces.Space = { id, createdAt: datetime.utcNow().toIso(), locked: false };

            this.spaceModel.createSpace(space);
        
            return cloud.ApiResponse {
                status: 201,
                body: Json.stringify(space),
            };
        });

        this.api?.get("/spaces/:spaceId", inflight (req: cloud.ApiRequest) => {

            let spaceId = req.vars.get("spaceId");
            let space = this.spaceModel.getSpaceById(spaceId);
            let friends = this.friendModel.getFriends(spaceId);

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

        // lock space
        this.api?.post("/spaces/:spaceId/lock", inflight (req: cloud.ApiRequest) => {

            this.spaceModel.lockSpace(req.vars.get("spaceId"));

            return cloud.ApiResponse {
                status: 200,
                body: Json.stringify({ locked: true }),
            };

        });
        this.api?.post("/spaces/:spaceId/upload_url", inflight (req: cloud.ApiRequest) => {

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

                let file = {
                    id: util.uuidv4(),
                    createdAt: datetime.utcNow().toIso(),
                    filename: filename,
                    type: filetype
                };

                let url = this.spaceModel.generateUploadURL(spaceId, file);

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

        });
       

    }
}