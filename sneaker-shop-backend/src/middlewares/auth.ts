import { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { Role } from "@prisma/client"; // <- lấy enum Role từ Prisma

export interface AuthReq extends Request {
  user?: { id: string; role: Role };
}

export function requireAuth(req: AuthReq, res: Response, next: NextFunction) {
  const h = req.headers.authorization;
  if (!h?.startsWith("Bearer ")) return res.status(401).json({ error: "Unauthorized" });
  const token = h.slice(7);
  try {
    const data = jwt.verify(token, process.env.JWT_SECRET || "dev") as any;
    req.user = { id: data.id, role: data.role as Role };
    next();
  } catch {
    return res.status(401).json({ error: "Invalid token" });
  }
}

export function requireRole(roles: Role[]) {
  return (req: AuthReq, res: Response, next: NextFunction) => {
    if (!req.user) return res.status(401).json({ error: "Unauthorized" });
    // admin luôn vượt quyền
    if (req.user.role === Role.admin || roles.includes(req.user.role)) return next();
    return res.status(403).json({ error: "Forbidden" });
  };
}
