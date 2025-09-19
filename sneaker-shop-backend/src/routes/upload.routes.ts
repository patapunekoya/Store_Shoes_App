import { Router, Request, Response } from "express";
import multer from "multer";
import path from "path";
import crypto from "crypto";
import fs from "fs";

import { requireAuth, requireRole } from "../middlewares/auth.js";
import { Role } from "@prisma/client";

const r = Router();

// Bảo đảm thư mục uploads tồn tại
const uploadDir = path.resolve("uploads");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Cấu hình disk storage
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname || "").toLowerCase();
    const name = crypto.randomBytes(8).toString("hex") + ext;
    cb(null, name);
  },
});

// Lọc file: chỉ cho image png/jpg/jpeg/webp, max 5MB
const fileFilter = (_req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  const ok = /image\/(png|jpe?g|webp)/.test(file.mimetype);
  // KHÔNG ném Error ở đây để tránh TS rắc rối — chỉ từ chối file.
  if (ok) cb(null, true);
  else cb(null, false);
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
});

// Chỉ staff/admin được upload
r.post(
  "/",
  requireAuth,
  requireRole([Role.staff, Role.admin]),
  upload.single("image"),
  (req: Request, res: Response) => {
    // Nếu fileFilter từ chối, req.file sẽ là undefined
    if (!req.file) {
      return res.status(400).json({ message: "Invalid file type or no file provided" });
    }
    // URL tương đối — phía Flutter ghép AppConfig.baseUrl + url
    const url = `/uploads/${req.file.filename}`;
    return res.status(201).json({ url });
  }
);

export default r;
