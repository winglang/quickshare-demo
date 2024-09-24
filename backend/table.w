bring cloud;
bring vite;
bring util;
bring dynamodb;
bring "./types.w" as types;

pub class SpaceTable {
  table: dynamodb.Table;
  new() {
    this.table = new dynamodb.Table(
      attributes: [
        { name: "PK", type: "S" },
        { name: "SK", type: "S" },
      ],
      name: "SpacesTable",
      hashKey: "PK",
      rangeKey: "SK",
      timeToLiveAttribute: "expiresAt",
    );
  }

  pub inflight createSpace(space: types.Space) {
      this.table.put(
        Item: {
          "PK": "SPACE#{space.id}",
          "SK": "META#SPACE",
          "id": space.id,
          "createdAt": space.createdAt,
          "locked": false,
        }
    );
  }

  // pub createStream(){
  //   // this.table.
  //   this.table.setStreamConsumer(inflight (record) => {
  //     record.dynamodb.NewImage
  //   });
  // }

  pub inflight addFriend(spaceId: str, friend: types.Friend) {
      this.table.put(
        Item: {
          "PK": "SPACE#{spaceId}",
          "SK": "FRIEND_ID#{friend.id}",
          "id": friend.id,
          "createdAt": friend.createdAt,
          "email": friend.email,
        }
    );
  }

  pub inflight getSpaceById(id: str): types.Space? {
    let data = this.table.query(
      KeyConditionExpression: "PK = :spaceID AND begins_with(SK, :spaceMeta)",
      ExpressionAttributeValues: {
        ":spaceID": "SPACE#{id}", 
        ":spaceMeta": "META#SPACE"      
      },
    );

    if (data.Count == 0) {
      return nil;
    }

    log(Json.stringify(data.Items[0]));

    return types.Space.fromJson(data.Items[0]);

  }

  pub inflight getFriends(id:str): MutArray<types.Friend>? {

    let data = this.table.query(
      KeyConditionExpression: "PK = :spaceID AND begins_with(SK, :friendId)",
      ExpressionAttributeValues: {
        ":spaceID": "SPACE#{id}", 
        ":friendId": "FRIEND_ID"      
      },
    );

    let friends = MutArray<types.Friend>[];

    if (data.Count == 0) {
      return friends;
    }

    for item in data.Items {
      friends.push(types.Friend.fromJson(item));
    }

    return friends;

  }

  pub inflight removeFriendById(spaceId: str, friendId: str): types.Friend? {

    this.table.delete(
      Key: {
        "PK": "SPACE#{spaceId}",
        "SK": "FRIEND_ID#{friendId}",
      }
    );

    return nil;

  }

  pub inflight lockSpace(spaceId: str) {
    this.table.update(
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

  pub inflight addNewFile(spaceId: str, file: types.File) {
    this.table.put(
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

