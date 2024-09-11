"use client";

type Space = {
  id: string;
  CreatedAt: string;
}

// @ts-ignore
const API_URL = window.wing.env.API_URL;

export const createSpace = async () => {
  return fetch(`${API_URL}/space`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    }
  }).then((res) => res.json());
}

export const getSpace = async (id: string) => {
  return fetch(`${API_URL}/space/${id}`).then((res) => res.json());
}


export const fetchFriends = async () => {
  return fetch(`${API_URL}/friends`).then((res) => res.json());
};
