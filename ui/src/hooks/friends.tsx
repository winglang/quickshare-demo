import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { addFriendToSpace as addFriendToSpaceAPI, getFriendsBySpaceId, removeFriendFromSpace as removeFriendFromSpaceAPI } from "../api";

export interface Friend {
  id: string;
  createdAt: string;
  email: string;
}

export const useFriends = (id: string) => {
  const queryClient = useQueryClient();

  // Fetch the data
  const { data, isPending, error } = useQuery<Friend[], Error>({
    queryKey: ["space-friends"],
    queryFn: async () => {
      console.log("FETCH THE FRIENDS");
      if (!id) throw new Error("No space ID provided");
      const data = await getFriendsBySpaceId(id);
      console.log("FETCH MAN");
      return data;
    },
  });

  const addFriendToSpace = useMutation({
    mutationKey: ["add-friend"],
    mutationFn: async (email: string) => {
      if (!id) throw new Error("No space ID provided");
      return addFriendToSpaceAPI(id, email);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["space-friends"] });
    },
  });

  const removeFriendFromSpace = useMutation({
    mutationKey: ["remove-friend"],
    mutationFn: async (friendId: string) => {
      if (!id) throw new Error("No space ID provided");
      let data = await removeFriendFromSpaceAPI(id, friendId);
      await queryClient.invalidateQueries({ queryKey: ["space-friends"] });
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["space-friends"] });
    },
  });

  return {
    data,
    isPending,
    error,
    addFriendToSpace,
    removeFriendFromSpace,
  };
};
