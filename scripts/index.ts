import * as fs from "fs-extra";
import * as path from "path";
import {
  CoreType,
  createCoreDir,
  startClient,
  startDashboard,
  startDownload,
} from "./actions";
import { CLIENT_PATH, CORE_DIR_NAME } from "./constants";
import { fileHash, getClientName } from "./utils";
import { ThirdPartyType } from "./thirdParties";

export const start = async (isDev = false) => {
  try {
    await startDashboard(isDev);
    await startDownload([ThirdPartyType.Wintun, ThirdPartyType.GeoData]);
    console.log("Creating core...");
    await createCoreDir([
      CoreType.Wintun,
      CoreType.GeoData,
      CoreType.Dashboard,
      CoreType.Config,
    ]);
    await fs.move(CORE_DIR_NAME, path.join(CLIENT_PATH, CORE_DIR_NAME), {
      overwrite: true,
    });
    console.log("Create core done!");
    await startClient(isDev);
    const outDir = path.join(CLIENT_PATH, "out");
    const appName = `${getClientName()}.exe`;
    const appPath = path.join(outDir, appName);
    await fs.copy(appPath, path.join("out", appName), {
      overwrite: true,
    });
    const appHash = await fileHash(path.join("out", appName));
    await fs.writeFile(path.join("out", `${appName}.sha256`), appHash);
  } catch (e) {
    console.error(e);
  }
};
