import axios from "axios";
import * as fs from "fs-extra";
import * as path from "path";
import { getModuleName, modulesConfig } from "../scripts/utils";
import { downloadFile } from "../scripts/downloader";
import { TMP_DIR } from "../scripts/constants";

async function getLatestTag(project: string) {
  const res = await axios.get(
    `https://api.github.com/repos/igoogolx/${project}/tags`
  );
  const tags = res.data as { name: string }[];
  return tags[0].name;
}

function getDownloadUrl(tag: string, name: string) {
  return `https://github.com/igoogolx/itun2socks/releases/download/${tag}/${name}`;
}

function getOsArch(name: string) {
  const items = name
    .replace(/\.zip|\.tar\.gz/, "")
    .replace("amd64", "x64")
    .split("_");
  return `${items[2]}_${items[3]}`;
}

const SUM_FILE_PATH = path.join(TMP_DIR, "checksum.txt");

async function updateItun2socks() {
  const tag = await getLatestTag("itun2socks");

  await downloadFile(
    `https://github.com/igoogolx/itun2socks/releases/download/${tag}/checksums.txt`,
    SUM_FILE_PATH
  );
  const sumContent = (await fs.readFile(SUM_FILE_PATH)).toString();
  const itun2socksReleaseFile: {
    [key: string]: { url: string; checksum: string };
  } = {};
  sumContent
    .split("\n")
    .map((item) => item.trim())
    .filter(Boolean)
    .forEach((releaseLine) => {
      const [value, key] = releaseLine.split(" ").filter(Boolean);
      itun2socksReleaseFile[getOsArch(key)] = {
        url: getDownloadUrl(tag, key),
        checksum: value,
      };
    });

  await fs.remove(TMP_DIR);

  return itun2socksReleaseFile;
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

  newModulesConfig.thirdParties.core = await updateItun2socks();

  await fs.writeFile(
    path.join("scripts", "modules.json"),
    JSON.stringify(newModulesConfig, null, 2)
  );
}

main();
