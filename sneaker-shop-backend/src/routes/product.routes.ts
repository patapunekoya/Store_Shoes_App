import { Router } from "express";
import { PrismaClient } from "@prisma/client";
import { z } from "zod";
import { requireAuth, requireRole } from "../middlewares/auth.js";


const prisma = new PrismaClient();
const r = Router();

// Public: list products
r.get("/", async (req, res, next) => {
  try {
    const { q, brandId, categoryId } = req.query;
    const products = await prisma.product.findMany({
      where: {
        isActive: true,
        name: q ? { contains: String(q), mode: "insensitive" } : undefined,
        brandId: brandId ? String(brandId) : undefined,
        categoryId: categoryId ? String(categoryId) : undefined
      },
      include: {
        variants: { include: { sizes: { include: { inventory: true } } } },
        brand: true, category: true
      },
      orderBy: { createdAt: "desc" }
    });
    res.json(products);
  } catch (e) { next(e); }
});

// Admin/Staff: create product
const productDto = z.object({
  name: z.string().min(2),
  slug: z.string().min(2),
  brandId: z.string().optional(),
  categoryId: z.string().optional(),
  basePrice: z.number().nonnegative(),
  description: z.string().optional(),
  isActive: z.boolean().optional(),
  variants: z.array(z.object({
    color: z.string().optional(),
    images: z.array(z.string()).optional(),
    sizes: z.array(z.object({
      sizeUS: z.number().optional(),
      sizeEU: z.number().int().optional(),
      sizeCM: z.number().optional(),
      sku: z.string().optional(),
      price: z.number().optional(),
      qtyOnHand: z.number().int().nonnegative().default(0)
    })).default([])
  })).default([])
});

r.post("/", requireAuth, requireRole(["staff"]), async (req, res, next) => {
  try {
    const dto = productDto.parse(req.body);
    const created = await prisma.product.create({
      data: {
        name: dto.name,
        slug: dto.slug,
        brandId: dto.brandId,
        categoryId: dto.categoryId,
        basePrice: dto.basePrice,
        description: dto.description,
        isActive: dto.isActive ?? true,
        variants: {
          create: dto.variants.map(v => ({
            color: v.color,
            images: (v.images ?? []) as any,
            sizes: {
              create: v.sizes.map(s => ({
                sizeUS: s.sizeUS,
                sizeEU: s.sizeEU,
                sizeCM: s.sizeCM,
                sku: s.sku,
                price: s.price,
                inventory: { create: { qtyOnHand: s.qtyOnHand ?? 0 } }
              }))
            }
          }))
        }
      },
      include: { variants: { include: { sizes: { include: { inventory: true } } } } }
    });
    res.status(201).json(created);
  } catch (e) { next(e); }
});

// Admin/Staff: update product basic fields
r.put("/:id", requireAuth, requireRole(["staff"]), async (req, res, next) => {
  try {
    const id = req.params.id;
    const { name, slug, basePrice, description, isActive } = req.body;
    const updated = await prisma.product.update({
      where: { id },
      data: { name, slug, basePrice, description, isActive }
    });
    res.json(updated);
  } catch (e) { next(e); }
});

// Admin/Staff: delete product
r.delete("/:id", requireAuth, requireRole(["staff"]), async (req, res, next) => {
  try {
    await prisma.product.delete({ where: { id: req.params.id } });
    res.status(204).send();
  } catch (e) { next(e); }
});

export default r;
