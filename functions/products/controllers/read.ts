import { currentUser, response } from "../helpers/index.ts";
import { SupabaseClient, URLRouteHandlerContext } from "../deps.ts";

interface ProductTags {
  tags: {
    id: string,
    name: string
  }
}

export const getProducts = async (_request: Request, _context: URLRouteHandlerContext, supabase: SupabaseClient) => {
  const { data: products, error } = await supabase.from("products").select("*");
  if (error) throw error;

  console.log(await currentUser(supabase))

  return response.json({
    products
  });
}

export const getProductById = async (_request: Request, context: URLRouteHandlerContext, supabase: SupabaseClient) => {
  const id = context.params.id;
  const { data: product, error } = await supabase.from("products")
    .select(`
      *, 
      product_tags!inner (
        tags (
          id, name
        )
      )
    `)
    .eq("id", id)
    .limit(1)
    .single();

  if (error) throw error;

  product.tags = (product.product_tags as ProductTags[]).map(tag => tag.tags)

  delete product.product_tags;

  return response.json({
    product
  });
}