import { Router } from "express";
import { PrismaClient } from "@prisma/client";
import { z } from "zod";
import { requireAuth, requireRole } from "../middlewares/auth.js";
import { Role } from "@prisma/client";

const prisma = new PrismaClient();
const r = Router();

const createDto = z.object({
  name: z.string().min(1),
  slug: z.string().min(1),
  brandId: z.string().uuid().optional().nullable(),
  basePrice: z.number().nonnegative(),
  description: z.string().optional().nullable(),
  variants: z.array(
    z.object({
      color: z.string().optional().nullable(),
      images: z.array(z.string()).default([]),
      sizes: z.array(
        z.object({
          sizeUS: z.number().optional().nullable(),
          sizeEU: z.number().int().optional().nullable(),
          sizeCM: z.number().optional().nullable(),
          sku: z.string().optional().nullable(),
          price: z.number().nonnegative().optional().nullable(),
          qtyOnHand: z.number().int().nonnegative().default(0),
        })
      ).min(1)
    })
  ).min(1)
});

// List
r.get("/", async (req, res, next) => {
  try {
    const items = await prisma.product.findMany({
      where: { isActive: true },
      include: {
        variants: { include: { sizes: true } },
        brand: true,
        category: true
      },
      orderBy: { createdAt: "desc" }
    });
    res.json(items);
  } catch (e) { next(e); }
});

// Create
r.post("/", requireAuth, requireRole([Role.staff, Role.admin]), async (req, res, next) => {
  try {
    const dto = createDto.parse(req.body);

    const product = await prisma.product.create({
      data: {
        name: dto.name,
        slug: dto.slug,
        brandId: dto.brandId ?? undefined,
        basePrice: dto.basePrice,
        description: dto.description ?? undefined,
        variants: {
          create: dto.variants.map(v => ({
            color: v.color ?? undefined,
            images: v.images as any, // JSON
            sizes: {
              create: v.sizes.map(s => ({
                sizeUS: s.sizeUS ?? undefined,
                sizeEU: s.sizeEU ?? undefined,
                sizeCM: s.sizeCM ?? undefined,
                sku: s.sku ?? undefined,
                price: s.price ?? undefined,
                inventory: { create: { qtyOnHand: s.qtyOnHand ?? 0 } }
              }))
            }
          }))
        }
      },
      include: {
        variants: { include: { sizes: { include: { inventory: true } } } }
      }
    });

    res.status(201).json(product);
  } catch (e) {
    // log rõ để dễ thấy lỗi
    console.error("Create product error:", e);
    next(e);
  }
});
// Delete
r.delete("/:id", requireAuth, requireRole([Role.staff, Role.admin]), async (req, res, next) => {
  try {
    const id = req.params.id;
    // Cascade đã set trong schema; nếu chưa, xoá theo thứ tự
    await prisma.product.delete({ where: { id } });
    res.json({ ok: true });
  } catch (e) { next(e); }
});

export default r;
