/**
 * {{_file_name_}}
 * {{_author_}} <{{_email_}}>
 * created: {{_date_}}
 */

import { Router, Request, Response } from "express";

const router = Router();

router.get("/", async (req: Request, res: Response) => {
  res.json({ ok: true });
  {{_cursor_}}
});

export default router;
