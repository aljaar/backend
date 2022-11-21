import { SupabaseClient } from "../deps.ts";

interface ResponseInit {
  headers: Headers,
  status: number
}

export const response = {
  json: (data: Parameters<typeof JSON.stringify>[0], init?: ResponseInit) => {
    const status = init?.status || 200;
    const headers = init?.headers instanceof Headers ? init.headers : new Headers();

    if (!headers.has("Content-Type")) {
      headers.set("Content-Type", "application/json");
    }

    return new Response(
      JSON.stringify(data),
      { headers, status },
    );
  }
}

export const getToken = (request: Request) => {
  const token = request.headers.get('Authorization');

  return token!;
}

export const currentUser = async (supabase: SupabaseClient) => {
  const { data: { user } } = await supabase.auth.getUser();

  return user;
}
