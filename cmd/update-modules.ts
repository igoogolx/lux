import axios from "axios";
import * as fs from "fs-extra";
import * as path from "path";
import { getModuleName, modulesConfig } from "../scripts/utils";

async function getLatestTag(project: string) {
  const res = await axios.get(
    `https://api.github.com/repos/igoogolx/${project}/tags`
  );
  const tags = res.data as { name: string }[];
  return tags[0].name;
}

async function main() {
  const newModulesConfig = JSON.parse(JSON.stringify(modulesConfig));
  await Promise.all(
    modulesConfig.projects.map(
      async (project: { repo: string; tag: string }, index: number) => {
        const name = getModuleName(project.repo);
        newModulesConfig.projects[index].branch = await getLatestTag(name);
      }
    )
  );
  await fs.writeFile(
    path.join("scripts", "modules.json"),
    JSON.stringify(newModulesConfig, null, 2)
  );
}

main();
