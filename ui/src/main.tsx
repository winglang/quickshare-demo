import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createBrowserRouter, RouterProvider, RouteObject } from "react-router-dom";
import Homepage from "./pages/Homepage";
import Space from "./pages/Space";
import "./index.css";

const routes: RouteObject[] = [
  {
    path: "/",
    element: <Homepage />,
  },
  {
    path: "/space/:id",
    element: <Space />,
  },
];

const router = createBrowserRouter(routes);
const queryClient = new QueryClient();

const Root: React.FC = () => (
  <RouterProvider router={router} />
);

const rootElement = document.getElementById("root");
if (rootElement) {
  createRoot(rootElement).render(
    <StrictMode>
      <QueryClientProvider client={queryClient}>
        <Root />
      </QueryClientProvider>
    </StrictMode>
  );
} else {
  console.error("Failed to find the root element");
}
