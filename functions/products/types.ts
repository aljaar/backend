import { SupabaseClient, URLRouteHandlerContext } from "./deps.ts";

export interface IHttpHandler {
  (request: Request): Promise<Response> | Response;
}

export interface IControllerHandler {
  (request: Request, context: URLRouteHandlerContext, supabase: SupabaseClient): Promise<Response> | Response;
}