import React from "react";
import { useParams, Link } from "react-router-dom";
import { ShareIcon, ClockIcon, CheckCircleIcon } from "@heroicons/react/24/solid";
import confetti from 'canvas-confetti';

import FloatingFilesDisplay from "../components/FloatingFiles";
import { FriendsList } from "../components/FriendsList";
import { FileUpload } from "../components/FileUpload";
import { useSpace, useUpload } from "../hooks/space";
import { useFriends } from "../hooks/friends";

const formatTime = (seconds: number): string => {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`;
};

interface ShareButtonProps {
  onClick: () => void;
  isUploading: boolean;
  disabled: boolean;
}

const ShareButton: React.FC<ShareButtonProps> = ({ onClick, isUploading, disabled }) => (
  <div className="text-center">
    <button
      onClick={onClick}
      disabled={isUploading || disabled}
      className={`bg-green-500 text-white px-6 py-3 rounded-full text-lg font-semibold hover:bg-green-600 transition duration-300 flex items-center justify-center mx-auto ${
        isUploading || disabled ? "opacity-50 cursor-not-allowed" : ""
      }`}
    >
      {isUploading ? (
        <>
          <svg
            className="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              className="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              strokeWidth="4"
            ></circle>
            <path
              className="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ></path>
          </svg>
          Uploading...
        </>
      ) : (
        <>
          <ShareIcon className="h-6 w-6 mr-2" />
          Share with Friends
        </>
      )}
    </button>
  </div>
);

// Main component
const FileSharingPage: React.FC = () => {

  const { id } = useParams<{ id: string }>();

  if (!id) return null;

  const { data, isPending, error, isExpired, remainingTime, lockSpace, sharingSpace } = useSpace(id);
  const { data: friends, isPending: friendsLoading, error: friendsError, addFriendToSpace, removeFriendFromSpace  } = useFriends(id);
  const { uploadFiles, removeFile, files } = useUpload(id);

  const [shareError, setShareError] = React.useState<string | null>(null);

  const shareWithFriends = async () => {
    if (!friends || friends.length === 0) {
      setShareError("Please add at least one friend before sharing.");
      return;
    }
    setShareError(null);
    await lockSpace();
  };

  const removeFriend = async (friendId:string) => {
    await removeFriendFromSpace.mutate(friendId);
  };

  React.useEffect(() => {
    if (data?.locked) {
      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 }
      });
    }
  }, [data?.locked]);

  if (isPending) return null;
  if (error) return <div>Error: {error.message}</div>;

  if (isExpired) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-400 to-indigo-600 py-12 px-4 sm:px-6 lg:px-8 flex flex-col items-center justify-center">
        <div className="max-w-md mx-auto bg-white rounded-xl shadow-2xl overflow-hidden z-10 p-8 text-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">
            This space no longer exists
          </h1>
          <p className="text-gray-600 mb-8">
            Space is only valid for 30 minutes. The sharing space has expired.
            Please create a new space to continue sharing files.
          </p>
          <Link
            to="/"
            className="bg-indigo-600 text-white px-6 py-3 rounded-full text-lg font-semibold hover:bg-indigo-700 transition duration-300 inline-block"
          >
            Create New Space
          </Link>
        </div>
      </div>
    );
  }
  if (data?.locked) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-400 to-indigo-600 py-12 px-4 sm:px-6 lg:px-8 flex flex-col items-center justify-center">
        <div className="max-w-md mx-auto bg-white rounded-xl shadow-2xl overflow-hidden z-10 p-8 text-center">
          <CheckCircleIcon className="h-16 w-16 text-green-500 mx-auto mb-4" />
          <h1 className="text-3xl font-bold text-gray-900 mb-4">
            Success! Files Shared
          </h1>
          <p className="text-gray-600 mb-8">
            Your files have been successfully sent to your friends. They'll be notified shortly.
          </p>
          <p className="text-gray-500 mb-8">
            Want to share more files? You can create a new space anytime.
          </p>
          <Link
            to="/"
            className="bg-indigo-600 text-white px-6 py-3 rounded-full text-lg font-semibold hover:bg-indigo-700 transition duration-300 inline-block"
          >
            Create Another Space
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-400 to-indigo-600 py-12 px-4 sm:px-6 lg:px-8 flex flex-col items-center justify-center relative overflow-hidden">
      <FloatingFilesDisplay />

      <div className="max-w-3xl mx-auto bg-white rounded-xl shadow-2xl overflow-hidden z-10 relative pb-5">
        <div className="p-8 px-6">
          <div className="flex justify-between items-center mb-8">
            <h1 className="text-3xl font-bold text-gray-900">
              Share Files with Friends
            </h1>
            <div className="flex items-center bg-indigo-100 px-3 py-1 rounded-full text-sm ml-4">
              <ClockIcon className="h-4 w-4 text-indigo-600 mr-1" />
              <span className="font-semibold text-indigo-600">
                {formatTime(remainingTime)}
              </span>
            </div>
          </div>

          {friends && 
            <FriendsList
              friends={friends}
              addFriend={(email: string) => addFriendToSpace.mutate(email)}
              removeFriend={(friendId: string) => removeFriendFromSpace.mutate(friendId)}
            />
          }

          <FileUpload
            files={files}
            addFiles={uploadFiles}
            removeFile={removeFile}
          />

          {shareError && (
            <div className="text-red-500 text-center mb-4">{shareError}</div>
          )}

          <ShareButton 
            onClick={shareWithFriends} 
            isUploading={sharingSpace} 
            disabled={!friends || friends.length === 0}
          />

          <div className="text-xs italic absolute bottom-2 right-2 text-gray-300">Channel: {data?.id}</div>
        </div>
      </div>

      <footer className="absolute bottom-4 text-indigo-200 text-sm">
        © {new Date().getFullYear()} QuickShare. All rights reserved.
      </footer>
    </div>
  );
};

export default FileSharingPage;
