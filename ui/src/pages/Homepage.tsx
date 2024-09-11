import React from "react";
import { ArrowRightIcon } from "@heroicons/react/24/solid";
import { useMutation } from "@tanstack/react-query";
import { createSpace } from "../api";
import FloatingFilesDisplay from "../components/FloatingFiles";

export default function LandingPage() {
  const { isPending, error, data, mutate } = useMutation({
    mutationFn: createSpace,
  });

  const handleCreateSpace = async () => {
    if (isPending) return;
    await mutate();
  };

  if (data) {
    window.location.href = `/space/${data.id}`;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-400 to-indigo-600 flex flex-col items-center justify-center relative overflow-hidden">
      <FloatingFilesDisplay />

      {/* Main Content */}
      <div className="z-10 text-center px-4 sm:px-6 lg:px-8 bg-gradient-to-b from-transparent  to-transparent py-16 rounded-3xl">
        <h1 className="text-5xl sm:text-6xl font-bold text-white mb-4 tracking-tight">
          QuickShare
        </h1>
        <p className="text-2xl sm:text-3xl font-semibold text-indigo-100 mb-2">
          Share files with friends
        </p>
        <p className="text-xl text-indigo-200 mb-8">
          No login, no fuss. Just files.
        </p>
        <button
          onClick={handleCreateSpace}
          className="bg-white text-indigo-600 px-8 py-4 rounded-full text-xl font-semibold hover:bg-indigo-100 transition duration-300 flex items-center justify-center mx-auto group"
        >
          {!isPending && <span>Create Space</span>}
          {isPending && (
            <span className="animate animate-pulse">Creating Space</span>
          )}
          <ArrowRightIcon className="h-6 w-6 ml-2 group-hover:translate-x-1 transition-transform duration-300" />
        </button>
      </div>

      {/* Footer */}
      <footer className="absolute bottom-4 text-indigo-200 text-sm">
        © {new Date().getFullYear()} QuickShare. All rights reserved.
      </footer>
    </div>
  );
}
