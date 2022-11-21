import { serve, cors } from "./deps.ts"
import { useRouter } from "./router.ts"
import type { IHttpHandler } from "./types.ts";

const handler = useRouter();

const withMiddleware = (handler: IHttpHandler) => {
  return async (request: Request) => {
    const response = await handler(request);

    return cors(request, response, {
      origin: '*'
    });
  }
}

serve(withMiddleware(handler));
