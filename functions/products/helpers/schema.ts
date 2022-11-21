import { Schema, Type, string, array, number } from "../deps.ts";

const ProductSchema = Schema({
  title: string,
  description: string,
  images: array.of(string).min(1),
  tags: array.of(number).min(1)
})

export type TProduct = Type<typeof ProductSchema>;
export const validateProduct = ProductSchema.destruct();
