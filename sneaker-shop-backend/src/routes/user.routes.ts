import { Router } from "express";
import { PrismaClient, Role } from "@prisma/client";
import { requireAuth, requireRole } from "../middlewares/auth.js";
import { z } from "zod";


const prisma = new PrismaClient();
const r = Router();

// Admin: list users
r.get("/", requireAuth, requireRole(["admin"]), async (_req, res, next) => {
  try {
    const users = await prisma.user.findMany({
      select: { id: true, email: true, fullName: true, role: true, isActive: true, createdAt: true }
    });
    res.json(users);
  } catch (e) { next(e); }
});

// Admin: set role
r.post("/:id/role", requireAuth, requireRole(["admin"]), async (req, res, next) => {
  try {
    const { role } = req.body as { role: Role };
    const updated = await prisma.user.update({ where: { id: req.params.id }, data: { role } });
    res.json({ id: updated.id, role: updated.role });
  } catch (e) { next(e); }
});

export default r;
