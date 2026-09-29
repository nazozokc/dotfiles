/**
 * {{_expr_:expand('%:t:r')}}
 * {{_input_:author}}
 * created: {{_expr_:strftime('%Y-%m-%d')}}
 */

import { Router, Request, Response } from "express";

const router = Router();

router.get("/", async (req: Request, res: Response) => {
  res.json({ ok: true });
  {{_cursor_}}
});

export default router;
