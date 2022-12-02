import * as path from "path";
import * as fs from "fs-extra";
import { runScript } from "./utils";

const modules = [
  {
    repo: "https://github.com/igoogolx/lux-dashboard.git",
    branch: "v0.0.9",
  },
  {
    repo: "https://github.com/igoogolx/lux-js-sdk.git",
    branch: "v0.0.1",
  },
  {
    repo: "https://github.com/igoogolx/lux-client.git",
    branch: "v0.0.6",
  },
];

async function cloneGitRepo(url: string, branch: string, dir: string) {
  await runScript("git", ["clone", "--branch", branch, url], dir);
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
        const name = getModuleName(module.repo);
        console.log(`cloning ${name}`);
        await cloneGitRepo(module.repo, module.branch, dir);
        console.log(`clone ${name} done!`);
      })
    );
  } catch (e) {
    console.log(e);
  }
}

start();
