bring cloud;
bring "./route.w" as Route;

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