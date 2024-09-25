bring dynamodb;
bring "../db/db.w" as Database;


pub struct Friend {
  id: str;
  email: str;
  createdAt: str;
}


pub class FriendModel {
    db: Database.Instance;
    new(db: Database.Instance) {
        this.db = db;
        nodeof(this).icon = "user-group";
        nodeof(this).color = "orange";
    }

    pub inflight getFriends(id:str): MutArray<Friend>? {

        let data = this.db.table.query(
        KeyConditionExpression: "PK = :spaceID AND begins_with(SK, :friendId)",
        ExpressionAttributeValues: {
            ":spaceID": "SPACE#{id}", 
            ":friendId": "FRIEND_ID"      
        },
        );

        let friends = MutArray<Friend>[];

        if (data.Count == 0) {
            return friends;
        }

        for item in data.Items {
            friends.push(Friend.fromJson(item));
        }

        return friends;

  }

  pub inflight addFriend(spaceId: str, friend: Friend) {
      this.db.table.put(
        Item: {
          "PK": "SPACE#{spaceId}",
          "SK": "FRIEND_ID#{friend.id}",
          "id": friend.id,
          "createdAt": friend.createdAt,
          "email": friend.email,
        }
    );
  }

  pub inflight removeFriendById(spaceId: str, friendId: str): Friend? {

    this.db.table.delete(
      Key: {
        "PK": "SPACE#{spaceId}",
        "SK": "FRIEND_ID#{friendId}",
      }
    );

    return nil;

  }
   
}


