bring cloud;

pub interface IRoute {
    createRoutes(api: cloud.Api): void;
    init(): void;
}

pub class BaseRoute impl IRoute {
    pub var api: cloud.Api?;
    new() {
        this.api = nil;
    }
    pub createRoutes(api: cloud.Api) {
        this.api = api;
        this.init();
    }
    pub init() {
        // Method is overriden by route
    }
}
