import * as fs from "fs-extra";
import * as path from "path";
import * as os from "os";
import * as AdmZip from "adm-zip";
import {
  CoreType,
  createCoreDir,
  startClient,
  startDashboard,
  startDownload,
} from "./actions";
import { CLIENT_PATH, CORE_DIR_NAME } from "./constants";
import { fileHash, getAppName, getInstallerName } from "./utils";
import { ThirdPartyType } from "./thirdParties";

async function copyInstaller() {
  const outDir = path.join(CLIENT_PATH, "out");
  const appName = getInstallerName();
  const appPath = path.join(outDir, appName);
  await fs.copy(appPath, path.join("out", appName), {
    overwrite: true,
  });
  const appHash = await fileHash(path.join("out", appName));
  await fs.writeFile(path.join("out", `${appName}.sha256`), appHash);
}

async function copyPortableApp() {
  const appName = getAppName();
  const outName = `${appName}-portable.zip`;
  const zip = new AdmZip();
  zip.addLocalFolder(path.join(CLIENT_PATH, "core"));
  zip.writeZip(path.join("out", outName));
  const appHash = await fileHash(path.join("out", outName));
  await fs.writeFile(path.join("out", `${outName}.sha256`), appHash);
}

export const start = async (isDev = false) => {
  try {
    const platform = os.platform();
    await startDashboard(isDev);
    const downloadTypes = [ThirdPartyType.GeoData, ThirdPartyType.LuxCore];
    const coreTypes = [
      CoreType.GeoData,
      CoreType.Dashboard,
      CoreType.Config,
      CoreType.LuxCore,
    ];
    if (platform === "win32") {
      downloadTypes.push(ThirdPartyType.Wintun);
      coreTypes.push(CoreType.Wintun);
    }
    await startDownload(downloadTypes);
    console.log("Creating core...");
    await createCoreDir(coreTypes);
    await fs.move(CORE_DIR_NAME, path.join(CLIENT_PATH, CORE_DIR_NAME), {
      overwrite: true,
    });
    console.log("Create core done!");
    await startClient(isDev);
    await copyInstaller();
    await copyPortableApp();
  } catch (e) {
    console.error(e);
  }
};
