<div align="center">

<h1>QuickShare: Share files with friends</h1>
<p>Demo Wing application to showcase functions, queues, tables and abstractions.</p>


<img alt="header" src="./images/quickshare.png"  />
<img alt="header" src="./images/console.png"  />

</div>

<hr/>

### How it works

This demo application shows how you can write Wing applications with cloud primitives and custom abstractions into services, routes and listening to database changes.

To use the application

- Make sure you have Wing installed and clone the repo.
- Run `wing it` in the `backend` project directory
- The wing console will load in your browser. 
- Go to http://localhost:5173/ to load the Vite application.
- Click `Create Magical Space`
- Add email address and files into the application.
- Click `Share with Friends` to send emails to your selected friends.

This application consists of a collection of cloud primitives with Wing and winglibs:

- [Cloud API](https://www.winglang.io/docs/api/standard-library/cloud/api) - API for the frontend to add/edit and delete freinds/spaces.
- [Cloud functions](https://www.winglang.io/docs/api/standard-library/cloud/function) - Compute to process API requests, queues and database changes.
- [Queues](https://www.winglang.io/docs/api/standard-library/cloud/queue) - To handle sending the email, configured DLQ on the queue
- [winglib DynamoDB](https://www.winglang.io/docs/winglibs/dynamodb) - Single table design to store friends and spaces into the database.
- [winglib email](https://www.winglang.io/docs/winglibs/email) - To send emails to friends.  

### How the project is structured
The project consists of a Vite application (front end), routes (for API) and services (spaces, friends and notifications service).

Wing is flexible in the ways you want to abstract your code and how you want to implement your resources. This application follows a standard `/routes` and `/services` pattern.

### Using in production

Warning: This solution does not enforce any auth and is for demo purposes only.

### Contributing

Feel free to raise a issue or pull request if you have any questions of feature requests.

# License

MIT.
