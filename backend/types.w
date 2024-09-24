pub struct Space {
  id: str;
  createdAt: str;
  expiresAt: num?;
  locked: bool;
}

pub struct Friend {
  id: str;
  email: str;
  createdAt: str;
}

pub struct File {
  id: str;
  createdAt: str;
  filename: str;
  type: str;
}