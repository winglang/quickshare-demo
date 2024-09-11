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
        }
    );
  }

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

    return types.Space.fromJson(data.Items[0]);

  }

  pub inflight getFriendById(spaceId: str, friendId: str): types.Friend? {
    let data = this.table.query(
      KeyConditionExpression: "PK = :spaceID AND begins_with(SK, :spaceMeta)",
      ExpressionAttributeValues: {
        ":spaceID": "SPACE#{spaceId}", 
        ":spaceMeta": "FRIEND_ID#{friendId}"      
      },
    );

    if (data.Count == 0) {
      return nil;
    }

    return types.Friend.fromJson(data.Items[0]);

  }
}

