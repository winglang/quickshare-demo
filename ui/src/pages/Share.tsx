import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import {
  ShareIcon,
  ClockIcon,
} from "@heroicons/react/24/solid";

import { getSpace } from "../api";
import FloatingFilesDisplay from "../components/FloatingFiles";
import { FriendsList } from "../components/FriendsList";
import { FileUpload } from "../components/FileUpload";

// Constants
const TOTAL_DURATION = 30 * 60; // 30 minutes in seconds

// Types
interface SpaceData {
  createdAt: string;
  // Add other properties as needed
}

// Utility functions
const mockUploadFiles = async (files: File[]): Promise<string[]> => {
  await new Promise((resolve) => setTimeout(resolve, 1500));
  return files.map((file) => `https://fake-cloud-storage.com/${file.name}`);
};

const formatTime = (seconds: number): string => {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`;
};

interface ShareButtonProps {
  onClick: () => void;
  isUploading: boolean;
}

const ShareButton: React.FC<ShareButtonProps> = ({ onClick, isUploading }) => (
  <div className="text-center">
    <button
      onClick={onClick}
      disabled={isUploading}
      className={`bg-green-500 text-white px-6 py-3 rounded-full text-lg font-semibold hover:bg-green-600 transition duration-300 flex items-center justify-center mx-auto ${
        isUploading ? "opacity-50 cursor-not-allowed" : ""
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
  const [friends, setFriends] = useState<string[]>([]);
  const [files, setFiles] = useState<File[]>([]);
  const [isUploading, setIsUploading] = useState<boolean>(false);
  const [uploadedUrls, setUploadedUrls] = useState<string[]>([]);
  const [remainingTime, setRemainingTime] = useState<number>(0);
  const [isExpired, setIsExpired] = useState<boolean>(false);

  const { id } = useParams<{ id: string }>();

  const { data, isPending, error } = useQuery<SpaceData, Error>({
    queryKey: ["space"],
    queryFn: async () => {
      if (!id) throw new Error("No space ID provided");
      const data = await getSpace(id);
      const creationDate = new Date(data.createdAt);
      const elapsedTime = Math.floor(
        (new Date().getTime() - creationDate.getTime()) / 1000
      );
      const initialRemainingTime = Math.max(TOTAL_DURATION - elapsedTime, 0);

      setRemainingTime(initialRemainingTime);
      setIsExpired(initialRemainingTime <= 0);
      return data;
    },
  });

  useEffect(() => {
    if (remainingTime <= 0) return;

    const timer = setInterval(() => {
      setRemainingTime((prevTime) => {
        if (prevTime <= 1) {
          clearInterval(timer);
          setIsExpired(true);
          return 0;
        }
        return prevTime - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [remainingTime]);

  // Make a request to the server to add the user to thepage
  const addFriend = (friend: string) => setFriends([...friends, friend]);
  const removeFriend = (friend: string) => setFriends(friends.filter((f) => f !== friend));
  const addFiles = (newFiles: File[]) => setFiles([...files, ...newFiles]);
  const removeFile = (file: File) => setFiles(files.filter((f) => f !== file));

  const shareWithFriends = async () => {
    if (files.length === 0 || friends.length === 0) {
      alert("Please select files and add friends before sharing.");
      return;
    }

    setIsUploading(true);
    try {
      const urls = await mockUploadFiles(files);
      setUploadedUrls(urls);
      alert(`Files uploaded successfully! Shared with ${friends.join(", ")}`);
    } catch (error) {
      alert("Error uploading files. Please try again.");
    } finally {
      setIsUploading(false);
    }
  };

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
          <a
            href="/"
            className="bg-indigo-600 text-white px-6 py-3 rounded-full text-lg font-semibold hover:bg-indigo-700 transition duration-300"
          >
            Create New Space
          </a>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-400 to-indigo-600 py-12 px-4 sm:px-6 lg:px-8 flex flex-col items-center justify-center relative overflow-hidden">
      <FloatingFilesDisplay />

      <div className="max-w-3xl mx-auto bg-white rounded-xl shadow-2xl overflow-hidden z-10">
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

          <FriendsList
            friends={friends}
            addFriend={addFriend}
            removeFriend={removeFriend}
          />

          <FileUpload
            files={files}
            addFiles={addFiles}
            removeFile={removeFile}
          />

          <ShareButton onClick={shareWithFriends} isUploading={isUploading} />

          {uploadedUrls.length > 0 && (
            <div className="mt-8">
              <h3 className="text-lg font-semibold mb-2">Uploaded Files:</h3>
              <ul className="list-disc pl-5">
                {uploadedUrls.map((url, index) => (
                  <li key={index}>
                    <a
                      href={url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-blue-600 hover:underline"
                    >
                      {url}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </div>

      <footer className="absolute bottom-4 text-indigo-200 text-sm">
        © {new Date().getFullYear()} QuickShare. All rights reserved.
      </footer>
    </div>
  );
};

export default FileSharingPage;
