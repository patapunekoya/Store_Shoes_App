import jwt from "jsonwebtoken";
const secret = process.env.JWT_SECRET || "dev";
export function signJwt(payload: any, expiresIn = "7d") {
  return jwt.sign(payload, secret, { expiresIn });
}
export function verifyJwt(token: string) {
  return jwt.verify(token, secret);
}
