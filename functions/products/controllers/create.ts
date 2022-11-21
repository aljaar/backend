import { SupabaseClient, URLRouteHandlerContext } from "../deps.ts";
import { currentUser, response } from "../helpers/index.ts";
import { validateProduct } from "../helpers/schema.ts";

export const createProduct = async (request: Request, _context: URLRouteHandlerContext, supabase: SupabaseClient) => {
  const data = await request.json();
  const [ error, product ] = validateProduct(data);

  if (error) return response.json(error);

  const user = await currentUser(supabase);

  // insert
  const { error: supa_error, data: supa_product } = await supabase.from("products")
    .insert({
      user_id: user?.id,
      title: product?.title,
      description: product?.description,
      images: product?.images
    })
    .select()
    .single();

  if (supa_error) return response.json(supa_error);

  // insert tags
  await supabase.from("product_tags").insert(product?.tags.map(tag => ({
    product_id: supa_product.id,
    tag_id: tag
  })));

  return response.json({
    product: supa_product
  });
}