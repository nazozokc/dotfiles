/**
 * {{_expr_:expand('%:t:r')}}
 * {{_input_:author}}
 * created: {{_expr_:strftime('%Y-%m-%d')}}
 */

import { Request, Response } from "express";

export async function {{_name_}}(req: Request, res: Response) {
  res.json({ ok: true });
  {{_cursor_}}
}
