bring dynamodb;
bring cloud;
bring "../db/db.w" as Database;

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
}

pub class SpaceModel {
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
    let url = this.bucket.signedUrl(spaceId, { 
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
          "status": "PENDING",
        }
    );
  }
   
}


