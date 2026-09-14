/**
 * {{_file_name_}}
 * {{_author_}} <{{_email_}}>
 * created: {{_date_}}
 */

import { Request, Response } from "express";

export async function {{_file_name_}}(req: Request, res: Response) {
  res.json({ ok: true });
  {{_cursor_}}
}

