import axios from "axios";
import * as fs from "fs-extra";
import * as path from "path";
import { getModuleName, modulesConfig } from "./utils";

async function getLatestTag(project: string) {
  const res = await axios.get(
    `https://api.github.com/repos/igoogolx/${project}/tags`
  );
  const tags = res.data as { name: string }[];
  return tags.pop().name;
}

async function main() {
  const newModulesConfig = JSON.parse(JSON.stringify(modulesConfig));
  await Promise.all(
    modulesConfig.projects.map(
      async (project: { repo: string; tag: string }, index: number) => {
        const name = getModuleName(project.repo);
        newModulesConfig.projects[index].tag = await getLatestTag(name);
      }
    )
  );
  await fs.writeFile(
    path.join("scripts", "modules.json"),
    JSON.stringify(modulesConfig, null, 2)
  );
}

main();
