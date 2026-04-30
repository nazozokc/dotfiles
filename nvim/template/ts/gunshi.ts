import { cli } from "gunshi";

await cli(process.argv.slice(2), {
  name: "git-summary",
  run: async (ctx) => {
    console.log("hello");
  },
});
