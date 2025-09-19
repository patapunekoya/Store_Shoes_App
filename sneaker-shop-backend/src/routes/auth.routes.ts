import { Router } from "express";
import { PrismaClient, Role } from "@prisma/client";
import { z } from "zod";
import { hashPassword, comparePassword } from "../utils/hash.js";
import { signJwt } from "../utils/jwt.js";


const prisma = new PrismaClient();
const r = Router();

const registerDto = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  fullName: z.string().optional()
});

r.post("/register", async (req, res, next) => {
  try {
    const dto = registerDto.parse(req.body);
    const exists = await prisma.user.findUnique({ where: { email: dto.email } });
    if (exists) return res.status(409).json({ error: "Email already used" });
    const user = await prisma.user.create({
      data: {
        email: dto.email,
        password: await hashPassword(dto.password),
        fullName: dto.fullName
      },
      select: { id: true, email: true, role: true, fullName: true }
    });
    const token = signJwt({ id: user.id, role: user.role });
    res.json({ user, token });
  } catch (e) { next(e); }
});

const loginDto = z.object({ email: z.string().email(), password: z.string().min(6) });

r.post("/login", async (req, res, next) => {
  try {
    const dto = loginDto.parse(req.body);
    const user = await prisma.user.findUnique({ where: { email: dto.email } });
    if (!user) return res.status(401).json({ error: "Invalid credentials" });
    const ok = await comparePassword(dto.password, user.password);
    if (!ok) return res.status(401).json({ error: "Invalid credentials" });
    const token = signJwt({ id: user.id, role: user.role });
    res.json({ user: { id: user.id, email: user.email, role: user.role, fullName: user.fullName }, token });
  } catch (e) { next(e); }
});

export default r;
