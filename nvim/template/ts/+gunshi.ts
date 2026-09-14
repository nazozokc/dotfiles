/**
 * {{_file_name_}}
 * {{_author_}} <{{_email_}}>
 * created: {{_date_}}
 */

import { cli } from "gunshi";

await cli(process.argv.slice(2), {
  name: "{{_file_name_}}",
  run: async (ctx) => {
    {{_cursor_}}
  },
});
