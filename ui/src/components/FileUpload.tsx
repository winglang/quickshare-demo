import { CloudArrowUpIcon, XMarkIcon } from "@heroicons/react/16/solid";

interface FileUploadProps {
  files: File[];
  addFiles: (newFiles: File[]) => void;
  removeFile: (file: File) => void;
}

export const FileUpload: React.FC<FileUploadProps> = ({ files, addFiles, removeFile }) => (
  <div className="mb-8">
    <h2 className="text-xl font-semibold mb-4 flex items-center">
      <CloudArrowUpIcon className="h-6 w-6 mr-2 text-indigo-600" />
      Upload Files
    </h2>
    <div className="border-2 border-dashed border-gray-300 rounded-md p-8 text-center">
      <input
        type="file"
        onChange={(e) => e.target.files && addFiles(Array.from(e.target.files))}
        multiple
        className="hidden"
        id="file-upload"
      />
      <label
        htmlFor="file-upload"
        className="cursor-pointer bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 transition duration-300"
      >
        Select Files
      </label>
      
    </div>
    <div className="mt-4 grid grid-cols-2 gap-4">
      {files.map((file, index) => (
        <div key={index} className="relative bg-gray-100 p-4 rounded-md">
          
          <div className="flex items-center justify-between mb-2">
            <span className="font-medium truncate">{file.name}</span>
            <button onClick={() => removeFile(file)} className="text-red-600 hover:text-red-800">
              <XMarkIcon className="h-5 w-5" />
              
            </button>
          </div>
          <div className="w-full h-6   flex items-center justify-center bg-gray-200 rounded-md">
              <span className="text-gray-500">{file.type}</span>
            </div>
          {/* {file.type.startsWith("image/") ? (
            <img
              src={URL.createObjectURL(file)}
              alt={file.name}
              className="w-full h-32 object-cover rounded-md"
            />
          ) : (
            <div className="w-full h-32 flex items-center justify-center bg-gray-200 rounded-md">
              <span className="text-gray-500">{file.type}</span>
            </div>
          )} */}
        </div>
      ))}
    </div>
  </div>
);
