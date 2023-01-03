import axios from "axios";
import * as fs from "fs-extra";
import * as path from "path";
import { getModuleName, modulesConfig } from "./utils";
import { download } from "./downloader";

async function getLatestTag(project: string) {
  const res = await axios.get(
    `https://api.github.com/repos/igoogolx/${project}/tags`
  );
  const tags = res.data as { name: string }[];
  return tags[0].name;
}

async function readHash(url: string): Promise<string> {
  const tmpPath = "tmp";
  await download({ url, outPath: tmpPath });
  const content = fs.readFileSync(tmpPath);
  fs.removeSync(tmpPath);
  return content.toString().trim().split(" ")[0];
}

async function getLatestRelease(project: string) {
  const res = await axios.get(
    `https://api.github.com/repos/igoogolx/${project}/releases`
  );
  const tags = res.data as {
    assets: { name: string; browser_download_url: string }[];
  }[];
  return tags[0];
}

async function updateCore() {
  const { assets } = await getLatestRelease("lux-core");
  const coreConfig = {
    win: { url: "", checksum: "" },
    mac: { url: "", checksum: "" },
  };
  await Promise.all(
    assets.map(async (asset) => {
      let type: keyof typeof coreConfig = "win";
      if (asset.name.startsWith("lux-core-windows")) {
        type = "win";
      } else {
        type = "mac";
      }
      if (asset.name.endsWith(".sha256")) {
        coreConfig[type].checksum = await readHash(asset.browser_download_url);
      } else {
        coreConfig[type].url = asset.browser_download_url;
      }
    })
  );
  return coreConfig;
}

async function main() {
  const newModulesConfig = JSON.parse(JSON.stringify(modulesConfig));
  newModulesConfig.thirdParties.core = await updateCore();
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
