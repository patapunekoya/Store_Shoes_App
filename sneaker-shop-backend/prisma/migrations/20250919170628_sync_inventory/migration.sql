/*
  Warnings:

  - You are about to drop the column `createdAt` on the `Brand` table. All the data in the column will be lost.
  - You are about to drop the column `slug` on the `Brand` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `Brand` table. All the data in the column will be lost.
  - You are about to drop the column `createdAt` on the `Category` table. All the data in the column will be lost.
  - You are about to drop the column `slug` on the `Category` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `Category` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `Order` table. All the data in the column will be lost.
  - You are about to drop the column `productId` on the `OrderItem` table. All the data in the column will be lost.
  - You are about to drop the column `variantId` on the `OrderItem` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `Product` table. All the data in the column will be lost.
  - You are about to drop the column `createdAt` on the `ProductVariant` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `ProductVariant` table. All the data in the column will be lost.
  - The `images` column on the `ProductVariant` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - You are about to drop the column `updatedAt` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `createdAt` on the `VariantSize` table. All the data in the column will be lost.
  - You are about to drop the column `qtyOnHand` on the `VariantSize` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `VariantSize` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "public"."OrderItem" DROP CONSTRAINT "OrderItem_orderId_fkey";

-- DropForeignKey
ALTER TABLE "public"."OrderItem" DROP CONSTRAINT "OrderItem_productId_fkey";

-- DropForeignKey
ALTER TABLE "public"."OrderItem" DROP CONSTRAINT "OrderItem_variantId_fkey";

-- DropForeignKey
ALTER TABLE "public"."ProductVariant" DROP CONSTRAINT "ProductVariant_productId_fkey";

-- DropForeignKey
ALTER TABLE "public"."VariantSize" DROP CONSTRAINT "VariantSize_variantId_fkey";

-- DropIndex
DROP INDEX "public"."Brand_slug_key";

-- DropIndex
DROP INDEX "public"."Category_slug_key";

-- DropIndex
DROP INDEX "public"."OrderItem_orderId_idx";

-- DropIndex
DROP INDEX "public"."OrderItem_productId_idx";

-- DropIndex
DROP INDEX "public"."OrderItem_variantId_idx";

-- DropIndex
DROP INDEX "public"."OrderItem_variantSizeId_idx";

-- DropIndex
DROP INDEX "public"."ProductVariant_productId_idx";

-- DropIndex
DROP INDEX "public"."VariantSize_variantId_idx";

-- AlterTable
ALTER TABLE "public"."Brand" DROP COLUMN "createdAt",
DROP COLUMN "slug",
DROP COLUMN "updatedAt";

-- AlterTable
ALTER TABLE "public"."Category" DROP COLUMN "createdAt",
DROP COLUMN "slug",
DROP COLUMN "updatedAt";

-- AlterTable
ALTER TABLE "public"."Order" DROP COLUMN "updatedAt",
ALTER COLUMN "subtotal" SET DATA TYPE DECIMAL(65,30),
ALTER COLUMN "shipping" SET DATA TYPE DECIMAL(65,30),
ALTER COLUMN "total" SET DATA TYPE DECIMAL(65,30);

-- AlterTable
ALTER TABLE "public"."OrderItem" DROP COLUMN "productId",
DROP COLUMN "variantId",
ALTER COLUMN "quantity" DROP DEFAULT,
ALTER COLUMN "unitPrice" SET DATA TYPE DECIMAL(65,30);

-- AlterTable
ALTER TABLE "public"."Product" DROP COLUMN "updatedAt",
ALTER COLUMN "basePrice" SET DATA TYPE DECIMAL(65,30);

-- AlterTable
ALTER TABLE "public"."ProductVariant" DROP COLUMN "createdAt",
DROP COLUMN "updatedAt",
DROP COLUMN "images",
ADD COLUMN     "images" JSONB NOT NULL DEFAULT '[]';

-- AlterTable
ALTER TABLE "public"."User" DROP COLUMN "updatedAt";

-- AlterTable
ALTER TABLE "public"."VariantSize" DROP COLUMN "createdAt",
DROP COLUMN "qtyOnHand",
DROP COLUMN "updatedAt",
ALTER COLUMN "price" SET DATA TYPE DECIMAL(65,30);

-- CreateTable
CREATE TABLE "public"."Inventory" (
    "variantSizeId" TEXT NOT NULL,
    "qtyOnHand" INTEGER NOT NULL DEFAULT 0,
    "qtyReserved" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "Inventory_pkey" PRIMARY KEY ("variantSizeId")
);

-- AddForeignKey
ALTER TABLE "public"."ProductVariant" ADD CONSTRAINT "ProductVariant_productId_fkey" FOREIGN KEY ("productId") REFERENCES "public"."Product"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."VariantSize" ADD CONSTRAINT "VariantSize_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "public"."ProductVariant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Inventory" ADD CONSTRAINT "Inventory_variantSizeId_fkey" FOREIGN KEY ("variantSizeId") REFERENCES "public"."VariantSize"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."OrderItem" ADD CONSTRAINT "OrderItem_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "public"."Order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
