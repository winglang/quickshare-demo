bring dynamodb;

pub class Instance {
  pub table: dynamodb.Table;
    new(tableName: str) {
        this.table = new dynamodb.Table(
        attributes: [
          { name: "PK", type: "S" },
          { name: "SK", type: "S" },
        ],
        name: tableName,
        hashKey: "PK",
        rangeKey: "SK",
        timeToLiveAttribute: "expiresAt",
    );
  }
}
