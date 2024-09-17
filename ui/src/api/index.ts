"use client";

// @ts-ignore
const API_URL = window.wing.env.API_URL;

export const createSpace = async () => {
  return fetch(`${API_URL}/spaces`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    }
  }).then((res) => res.json());
}

export const getSpace = async (id: string) => {
  return fetch(`${API_URL}/spaces/${id}`).then((res) => res.json());
}

export const uploadFilesWithPresignedURLs = async (files: { presignedURL: string; file: File }[]) => {
  const uploadPromises = files.map(({ presignedURL, file }) =>
    fetch(presignedURL, {
      body: file,
      method: "PUT",
      headers: {
        "Content-Type": file.type,
        "Content-Disposition": `attachment; filename="${file.name}"`,
      },
    })
  );

  try {
    const results = await Promise.all(uploadPromises);
    return results.map((response, index) => ({
      file: files[index].file.name,
      success: response.ok,
      status: response.status,
    }));
  } catch (error) {
    console.error("Error uploading files:", error);
    throw error;
  }
};

export const lockSpace = async (id: string) => {
  return fetch(`${API_URL}/spaces/${id}/lock`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    }
  }).then((res) => res.json());
}
export const addFriendToSpace = async (id: string, email: string) => {
  return fetch(`${API_URL}/spaces/${id}/friends`, {
    method: "POST",
    body: JSON.stringify({ email }),
    headers: {
      "Content-Type": "application/json",
    }
  }).then((res) => res.json());
}
export const removeFriendFromSpace = async (id: string, email: string) => {
  return fetch(`${API_URL}/spaces/${id}/friends/${email}`, {
    method: "DELETE",
    headers: {
      "Content-Type": "application/json",
    }
  });
}
export const getFriendsBySpaceId = async (id: string) => {
  return fetch(`${API_URL}/spaces/${id}/friends`).then((res) => res.json());
}

export const fetchFriends = async () => {
  return fetch(`${API_URL}/friends`).then((res) => res.json());
};

export const generateUploadURLForSpace = (id: string): Promise<{ url: string }> => {
  return fetch(`${API_URL}/spaces/${id}/upload_url`).then((res) => res.json());
};
