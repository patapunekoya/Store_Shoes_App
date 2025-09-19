import express from "express";
import cors from "cors";
import path from "path";
import uploadRouter from "./routes/upload.routes.js";
import productRouter from "./routes/product.routes.js";
import authRouter from "./routes/auth.routes.js";
import orderRouter from "./routes/order.routes.js";
import userRouter from "./routes/user.routes.js";
import { errorHandler } from "./middlewares/error.js";

export const app = express();

app.use(cors());
app.use(express.json());

// ⬇️ phục vụ file tĩnh
app.use("/uploads", express.static(path.resolve("uploads")));

app.get("/health", (_req, res) => res.json({ ok: true }));

// ⬇️ CHÚ Ý: baseUrl của Flutter là /api, nên cần /api/... ở đây
app.use("/api/upload", uploadRouter);
app.use("/api/products", productRouter);
app.use("/api/auth", authRouter);
app.use("/api/orders", orderRouter);
app.use("/api/users", userRouter);

// Error handler cuối cùng
app.use(errorHandler);
