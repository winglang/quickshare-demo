bring dynamodb;
bring cloud;
bring "../db/db.w" as Database;
bring "./friends.w" as Friends;
bring "./notifications.w" as Notifications;

pub struct Space {
  id: str;
  createdAt: str;
  expiresAt: num?;
  locked: bool;
}

pub struct File {
  id: str;
  createdAt: str;
  filename: str;
  type: str;
  status: str;
}

pub class SpaceService {
    db: Database.Instance;
    bucket: cloud.Bucket;
    new(db: Database.Instance, storage: cloud.Bucket) {
        this.db = db;
        this.bucket = storage;
        nodeof(this).icon = "sparkles";
        nodeof(this).color = "orange";
    }

    pub inflight createSpace(space: Space){
        this.db.table.put(
            Item: {
              "PK": "SPACE#{space.id}",
              "SK": "META#SPACE",
              "id": space.id,
              "createdAt": space.createdAt,
              "locked": false,
            }
        );
    }

    pub inflight getSpaceById(id: str): Space? {
      let data = this.db.table.query(
        KeyConditionExpression: "PK = :spaceID AND begins_with(SK, :spaceMeta)",
        ExpressionAttributeValues: {
          ":spaceID": "SPACE#{id}", 
          ":spaceMeta": "META#SPACE"      
        },
      );

      if (data.Count == 0) {
        return nil;
      }

      return Space.fromJson(data.Items[0]);

    }

    pub inflight lockSpace(spaceId: str) {

      // Update the space to be locked/
      this.db.table.update(
        Key: {
          "PK": "SPACE#{spaceId}",
          "SK": "META#SPACE",
        },
        UpdateExpression: "SET locked = :locked",
        ExpressionAttributeValues: {
          ":locked": true,
        }
     );

    

  }

  pub inflight generateUploadURL(spaceId: str, file:File): str {
    let url = this.bucket.signedUrl("spaces/{spaceId}/{file.id}", { 
      action: cloud.BucketSignedUrlAction.UPLOAD,
      duration: 2m
    });

    this.addFileToSpace(spaceId, file);

    return url;
  }

  pub inflight addFileToSpace(spaceId: str, file: File) {
    this.db.table.put(
        Item: {
          "PK": "SPACE#{spaceId}",
          "SK": "FILE_ID#{file.id}",
          "id": file.id,
          "createdAt": file.createdAt,
          "filename": file.filename,
          "type": file.type,
          "expiresAt": datetime.utcNow().toIso(),// now + 5 mins,
          "status": file.status,
        }
    );
  }

  // Condition check to see if all files are ready (uploaded to the space)
  pub inflight allFilesComplete(spaceId: str) {
    // Get all files
    let items = this.db.table.query(
      KeyConditionExpression: "PK = :spaceID AND begins_with(SK, :fileID)",
      ExpressionAttributeValues: {
        ":spaceID": "SPACE#{spaceId}", 
        ":fileID": "FILE_ID"      
      },
    );

    
  }

  pub listenForDBChanges(friends: Friends.FriendsService, notifications: Notifications.NotificationService) {

    // Listen for when the table changes to locked and add messages to queue to be processed
    this.db.table.setStreamConsumer(inflight (record: dynamodb.StreamRecord) => {

      log(Json.stringify(record));

      if(record.eventName == "MODIFY"){

        // Is Wing simulator diff to production? 

        let isLocked = record.dynamodb.NewImage?.tryGet("locked")?.tryGet("BOOL")?.asBool();
        let spaceId = record.dynamodb.NewImage?.tryGet("id")?.tryGet("S")?.asStr();
        // let isLocked = record.dynamodb.NewImage?.tryGet("locked")?.asBool();
        // let spaceId = record.dynamodb.NewImage?.tryGet("id")?.asStr();

        log("IS LOCKED {isLocked!}");
        log("spaceID {spaceId!}");

        if(isLocked == true){

          // Get all the files for the space
          let data = this.db.table.query(
            KeyConditionExpression: "PK = :spaceID AND begins_with(SK, :fileID)",
            ExpressionAttributeValues: {
              ":spaceID": "SPACE#{spaceId!}", 
              ":fileID": "FILE_ID"      
            },
          );

          let files = MutArray<File>[];
          for item in data.Items {
            files.push(File.fromJson(item));
          }

          // No files to send, just skip.
          if(files.length == 0){
            return;
          }

          let freinds = friends.getFriends(spaceId!);

          // No friends in space, just skip.
          if(freinds?.length == 0){
            return;
          }

          // Send email to all friends with download links
          let recipients = MutArray<str>[];
          let var message:str = "";

          for friend in freinds! {
            recipients.push(friend.email);
          }

          // Get 10 minute downloadable links for each code.
          for file in files {
            let url = this.bucket.signedUrl("spaces/{spaceId!}/{file.id}", { 
              action: cloud.BucketSignedUrlAction.DOWNLOAD,
              duration: 10m
            });

            message = message + "Download link: {url}\n";
          }

          notifications.addEmailToQueue(recipients, message);

        }
      }
    }, { startingPosition: "LATEST" });

    // mark files that they have been uploaded and complete
    this.bucket.onCreate(inflight (key: str) => {

      log(key);

      // Split the key
      let parts = key.split("/");
      let spaceId = parts[1];
      let fileId = parts[2];

      this.db.table.update(
        Key: {
          "PK": "SPACE#{spaceId}",
          "SK": "FILE_ID#{fileId}",
        },
        UpdateExpression: "SET #s = :status",
        ExpressionAttributeNames: {
          "#s": "status",
        },
        ExpressionAttributeValues: {
          ":status": "COMPLETE",
        }
      );

    });
  }

   
}