bring cloud;
bring "./route.w" as Route;


// let api = new cloud.Api({ cors: true});

pub class Instance {
    api: cloud.Api;
    pub url: str;
    new(){
        this.api = new cloud.Api({ cors: true});
        this.url = this.api.url;
    }
    pub register(route: Route.BaseRoute) {
        route.createRoutes(this.api);
    }
}

/**



    let x = new API();
    x.registerRoute(new friends.Routes(x));
    x.registerRoute(new spaces.Routes(x));

    // get(spaces)
    // get(friends);

    Route
     - Access to Models
     - Access to Models


    l = new Routes(api);
    l.registerRoute(new friends.Routes());
    l.registerRoute(new spaces.Routes());

    let models = { friends, spaces };

    registerRoute(route: Route, models) {
        route.registerRoute(this.api, models);
    }

    api.get("/spaces/:spaceId", inflight (req: cloud.ApiRequest) => {
        return models.Friends.getFriends(spaceId);
    });
*/