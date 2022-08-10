import * as path from "path";
import * as fs from "fs-extra";
import { runScript } from "./utils";

const modules = [
  "https://github.com/igoogolx/lux-dashboard.git",
  "https://github.com/igoogolx/lux-js-sdk.git",
  "https://github.com/igoogolx/lux-client.git",
];

async function cloneGitRepo(url: string, dir: string) {
  await runScript("git", ["clone", url], dir);
}
function getModuleName(url: string) {
  const suffix = url.split("/").pop();
  return suffix.split(".")[0];
}

async function start() {
  try {
    const dir = path.join(process.cwd(), "modules");
    await fs.ensureDir(dir);
    await fs.emptyDir(dir);
    await Promise.all(
      modules.map(async (module) => {
        const name = getModuleName(module);
        console.log(`cloning ${name}`);
        await cloneGitRepo(module, dir);
        console.log(`clone ${name} done!`);
      })
    );
  } catch (e) {
    console.log(e);
  }
}

start();
