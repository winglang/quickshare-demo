import { PlusIcon, UserGroupIcon, XMarkIcon } from "@heroicons/react/16/solid";
import { useState } from "react";

const validateEmail = (email: string): boolean => {
  const emailInput = document.createElement("input");
  emailInput.type = "email";
  emailInput.value = email;
  return emailInput.checkValidity();
};

// Sub-components
interface FriendsListProps {
  friends: string[];
  addFriend: (friend: string) => void;
  removeFriend: (friend: string) => void;
}

export const FriendsList: React.FC<FriendsListProps> = ({
  friends,
  addFriend,
  removeFriend,
}) => {
  const [newFriend, setNewFriend] = useState<string>("");
  const [emailError, setEmailError] = useState<string>("");

  const handleAddFriend = () => {
    if (newFriend && !friends.includes(newFriend)) {
      if (validateEmail(newFriend)) {
        addFriend(newFriend);
        setNewFriend("");
        setEmailError("");
      } else {
        setEmailError("Please enter a valid email address.");
      }
    }
  };

  return (
    <div className="mb-8">
      <h2 className="text-xl font-semibold mb-4 flex items-center">
        <UserGroupIcon className="h-6 w-6 mr-2 text-indigo-600" />
        Friends List
      </h2>
      <div className="flex flex-col items-start mb-4">
        <div className="flex w-full">
          <input
            type="email"
            value={newFriend}
            onChange={(e) => setNewFriend(e.target.value)}
            onKeyPress={(e: React.KeyboardEvent<HTMLInputElement>) =>
              e.key === "Enter" && handleAddFriend()
            }
            placeholder="Add a friend's email"
            className="flex-grow px-4 py-2 border rounded-l-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
          <button
            onClick={handleAddFriend}
            className="bg-indigo-600 text-white px-4 py-2 rounded-r-md hover:bg-indigo-700 transition duration-300"
          >
            <PlusIcon className="h-5 w-5" />
          </button>
        </div>
        {emailError && (
          <p className="text-red-500 text-sm mt-1">{emailError}</p>
        )}
      </div>
      <ul className="space-y-2">
        {friends.map((friend, index) => (
          <li
            key={index}
            className="flex items-center justify-between bg-gray-100 px-4 py-2 rounded-md"
          >
            <span>{friend}</span>
            <button
              onClick={() => removeFriend(friend)}
              className="text-red-600 hover:text-red-800"
            >
              <XMarkIcon className="h-5 w-5" />
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
};
