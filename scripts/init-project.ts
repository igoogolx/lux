import * as path from "path";
import * as fs from "fs-extra";
import { getModuleName, modulesConfig, runScript } from "./utils";

async function cloneGitRepo(url: string, branch: string, dir: string) {
  await runScript("git", ["clone", "--branch", branch, url], dir);
}

async function start() {
  try {
    const dir = path.join(process.cwd(), "modules");
    await fs.ensureDir(dir);
    await fs.emptyDir(dir);
    await Promise.all(
      modulesConfig.projects.map(
        async (module: { repo: string; branch: string }) => {
          const name = getModuleName(module.repo);
          console.log(`cloning ${name}`);
          await cloneGitRepo(module.repo, module.branch, dir);
          console.log(`clone ${name} done!`);
        }
      )
    );
  } catch (e) {
    console.log(e);
  }
}

start();
