import { Router } from "express";
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
const r = Router();

r.get("/brands", async (_req, res, next) => {
  try {
    const items = await prisma.brand.findMany({ select: { id: true, name: true } });
    res.json(items);
  } catch (e) { next(e); }
});

r.get("/categories", async (_req, res, next) => {
  try {
    const items = await prisma.category.findMany({ select: { id: true, name: true } });
    res.json(items);
  } catch (e) { next(e); }
});

export default r;
