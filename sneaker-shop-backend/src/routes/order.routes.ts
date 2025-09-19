import { Router } from "express";
import { PrismaClient, Prisma } from "@prisma/client";
import { z } from "zod";
import { AuthReq, requireAuth, requireRole } from "../middlewares/auth.js";


const prisma = new PrismaClient();
const r = Router();

const placeDto = z.object({
  items: z.array(z.object({
    variantSizeId: z.string(),
    quantity: z.number().int().positive(),
    unitPrice: z.number().nonnegative()
  })),
  shipping: z.number().nonnegative().default(0)
});

// User: place order
r.post("/", requireAuth, async (req: AuthReq, res, next) => {
  try {
    const dto = placeDto.parse(req.body);

    const order = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      // check stock
      for (const it of dto.items) {
        const inv = await tx.inventory.findUnique({ where: { variantSizeId: it.variantSizeId } });
        const available = (inv?.qtyOnHand ?? 0) - (inv?.qtyReserved ?? 0);
        if (available < it.quantity) throw { status: 400, message: "Insufficient stock" };
      }

      // reserve
      for (const it of dto.items) {
        await tx.inventory.update({
          where: { variantSizeId: it.variantSizeId },
          data: { qtyReserved: { increment: it.quantity } }
        });
      }

      const subtotal = dto.items.reduce((s, it) => s + it.unitPrice * it.quantity, 0);
      const total = subtotal + dto.shipping;

      const created = await tx.order.create({
        data: {
          userId: req.user?.id,
          subtotal,
          shipping: dto.shipping,
          total,
          items: {
            create: dto.items.map(it => ({
              variantSizeId: it.variantSizeId,
              quantity: it.quantity,
              unitPrice: it.unitPrice
            }))
          }
        },
        include: { items: true }
      });

      return created;
    });

    res.status(201).json(order);
  } catch (e) { next(e); }
});

// Staff/Admin: confirm paid -> deduct stock
r.post("/:orderId/confirm-payment", requireAuth, requireRole(["staff"]), async (req, res, next) => {
  try {
    const id = req.params.orderId;

    await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      const items = await tx.orderItem.findMany({ where: { orderId: id } });

      for (const it of items) {
        await tx.inventory.update({
          where: { variantSizeId: it.variantSizeId },
          data: {
            qtyReserved: { decrement: it.quantity },
            qtyOnHand: { decrement: it.quantity }
          }
        });
      }

      await tx.order.update({ where: { id }, data: { status: "paid" } });
    });

    res.json({ ok: true });
  } catch (e) { next(e); }
});

// User: my orders
r.get("/me", requireAuth, async (req: AuthReq, res, next) => {
  try {
    const orders = await prisma.order.findMany({
      where: { userId: req.user?.id },
      include: { items: { include: { variantSize: { include: { variant: { include: { product: true } } } } } } },
      orderBy: { placedAt: "desc" }
    });
    res.json(orders);
  } catch (e) { next(e); }
});

export default r;
