// src/routes/upload.routes.ts
import { Router, Request, Response, NextFunction } from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import crypto from "crypto";
import { requireAuth, requireRole } from "../middlewares/auth.js";
import { Role } from "@prisma/client";

// Thư mục lưu file (tính từ project root)
const UPLOAD_DIR = path.resolve(process.cwd(), "uploads");
// Đảm bảo thư mục tồn tại
fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, UPLOAD_DIR),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname || "").toLowerCase();
    const name = crypto.randomBytes(8).toString("hex") + ext;
    cb(null, name);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (_req, file, cb) => {
    const ok = /image\/(png|jpe?g|webp)/.test(file.mimetype);
    if (!ok) return cb(new Error("Invalid file type"));
    cb(null, true);
  },
});

const r = Router();

/**
 * POST /api/upload
 * Form-Data: image: <file>
 * Chỉ staff/admin được phép.
 * Trả về: { url, filename, size, mimetype }
 */
r.post(
  "/",
  requireAuth,
  requireRole([Role.staff]),
  upload.single("image"),
  (req: Request, res: Response, _next: NextFunction) => {
    if (!req.file) return res.status(400).json({ message: "No file" });

    // URL public: app.ts đã serve static /uploads
    const url = `/uploads/${req.file.filename}`;
    return res.status(201).json({
      url,
      filename: req.file.filename,
      size: req.file.size,
      mimetype: req.file.mimetype,
    });
  }
);

export default r;
