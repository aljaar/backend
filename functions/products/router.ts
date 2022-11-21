import { MethodRouter as useMethod, URLRouter, URLRoutes } from "https://deno.land/x/http_router@2.1.0/mod.ts"
import { useSupabase } from "./config/app.ts";
import { getToken } from "./helpers/index.ts";
import type { IControllerHandler } from "./types.ts";
import type { URLRouteHandlerContext } from "./deps.ts";

import { createProduct } from "./controllers/create.ts";
import { getProducts, getProductById } from "./controllers/read.ts";

const withSupabase = (request: Request, context: URLRouteHandlerContext, handler: IControllerHandler) => {
  const token = getToken(request);
  const supabase = useSupabase(token);

  return handler(request, context, supabase);
}

export const useRouter = () => {
  const routers: URLRoutes = {
    "/products": (request, context: URLRouteHandlerContext) => {
      return useMethod({
        GET: (request: Request) => withSupabase(request, context, getProducts),
        POST: (request: Request) => withSupabase(request, context, createProduct),
      })(request);
    },
    "/products/:id": (request, context: URLRouteHandlerContext) => {
      return useMethod({
        GET: (request: Request) => withSupabase(request, context, getProductById),
      })(request);
    }
  }

  return URLRouter(routers, {
  });
}