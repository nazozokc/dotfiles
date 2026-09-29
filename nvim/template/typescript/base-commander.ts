/**
 * {{_expr_:expand('%:t:r')}}
 * {{_input_:author}}
 * created: {{_expr_:strftime('%Y-%m-%d')}}
 */

import { Command } from "commander";

const program = new Command();

program
  .name("{{_expr_:expand('%:t:r')}}")
  .description("CLI description here")
  .version("0.0.1");

program.parse(process.argv);

{{_cursor_}}
