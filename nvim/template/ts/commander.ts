/**
 * {{_file_name_}}
 * {{_author_}} <{{_email_}}>
 * created: {{_date_}}
 */

import { Command } from "commander";

const program = new Command();

program
  .name("{{_file_name_}}")
  .description("CLI description here")
  .version("0.0.1");

program.parse(process.argv);

{{_cursor_}}
