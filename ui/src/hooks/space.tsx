import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { generateUploadURLForSpace, getSpace, lockSpace as lockSpaceAPI, uploadFilesWithPresignedURL, uploadFile } from "../api";
import { useCallback, useEffect, useRef, useState } from "react";

interface SpaceData {
  id: string;
  createdAt: string;
  locked: boolean;
}

const TOTAL_DURATION = 1800; // Assuming this is defined elsewhere

export const useUpload = (id: string) => {
  const [files, setFiles] = useState<File[]>([]);

  const { isPending, error, data, mutate } = useMutation({
    // mutationFn: uploadFilesWithPresignedURLs,
  });

  const uploadFiles = async (newFiles: File[]) => {
    for (const file of newFiles) {
      const { url } = await generateUploadURLForSpace(id, file);
      await uploadFile(url, file);
    }
    setFiles([...files, ...newFiles]);
  };

  const removeFile = (file: File) => {
    setFiles(files.filter((f) => f !== file));
  };

  return {
    isPending,
    error,
    data,
    uploadFiles,
    removeFile,
    files
  };
};

export const useSpace = (id: string) => {
  const [remainingTime, setRemainingTime] = useState<number>(0);
  const [isExpired, setIsExpired] = useState<boolean>(false);
  const timerRef = useRef<any | null>(null);
  const queryClient = useQueryClient();

  const startTimer = useCallback((initialTime: number) => {
    if (timerRef.current) clearInterval(timerRef.current);

    setRemainingTime(initialTime);
    setIsExpired(initialTime <= 0);

    if (initialTime > 0) {
      timerRef.current = setInterval(() => {
        setRemainingTime((prevTime) => {
          if (prevTime <= 1) {
            if (timerRef.current) clearInterval(timerRef.current);
            setIsExpired(true);
            return 0;
          }
          return prevTime - 1;
        });
      }, 1000);
    }
  }, []);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, []);

  const { data, isPending, error } = useQuery<SpaceData, Error>({
    queryKey: ["space", id],
    queryFn: async () => {
      if (!id) throw new Error("No space ID provided");
      const data = await getSpace(id);

      const creationDate = new Date(data.createdAt);
      const elapsedTime = Math.floor(
        (new Date().getTime() - creationDate.getTime()) / 1000
      );
      const initialRemainingTime = Math.max(TOTAL_DURATION - elapsedTime, 0);

      startTimer(initialRemainingTime);
      return data;
    },
    staleTime: Infinity,
    refetchOnWindowFocus: false,
  });

  const { mutate: lockSpace, isPending: sharingSpace, error: sharingError } = useMutation({
    mutationFn: () => lockSpaceAPI(id),
    onSuccess: () => {
      queryClient.invalidateQueries(["space", id]);
    }
  });

  return {
    data,
    isPending,
    error,
    isExpired,
    remainingTime,
    lockSpace,
    sharingSpace,
    sharingError
  };
};
