/**
 * {{_expr_:expand('%:t:r')}}
 * {{_input_:author}}
 * created: {{_expr_:strftime('%Y-%m-%d')}}
 */

import { cli } from "gunshi";

await cli(process.argv.slice(2), {
  name: "{{_expr_:expand('%:t:r')}}",
  run: async (ctx) => {
    {{_cursor_}}
  },
});
