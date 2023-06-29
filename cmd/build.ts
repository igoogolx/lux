import * as path from "path";
import * as fs from "fs-extra";
import * as AdmZip from "adm-zip";
import { CLIENT_PATH, CORE_DIR_NAME, OUT_PATH } from "../scripts/constants";
import { fileHash, getAppName, getArches } from "../scripts/utils";
import {
  CoreType,
  createCoreDir,
  startClient,
  startDashboard,
  startDownload,
} from "../scripts/actions";
import { ThirdPartyType } from "../scripts/thirdParties";

const regexFilter = /^.*\.(dmg|exe)$/;

const CLIENT_SRC_PATH = path.join(CLIENT_PATH, "out");

async function copyInstaller() {
  await fs.copy(CLIENT_SRC_PATH, OUT_PATH, {
    overwrite: true,
    filter: (srcPath) => {
      const stats = fs.statSync(srcPath);
      if (srcPath === CLIENT_SRC_PATH) {
        return true;
      }
      if (stats.isDirectory()) {
        return false; // Include all directories
      }
      return regexFilter.test(srcPath); // Include files that match the regex filter
    },
  });
}

async function copyPortableApp() {
  const appName = getAppName();
  const outName = `${appName}-portable.zip`;
  const zip = new AdmZip();
  await fs.remove(path.join(CLIENT_PATH, "core", "web"));
  zip.addLocalFolder(path.join(CLIENT_PATH, "core"));
  zip.writeZip(path.join(OUT_PATH, outName));
}

async function calculateFileHash() {
  const fileNames = await fs.readdir(OUT_PATH);
  await Promise.all(
    fileNames.map(async (fileName) => {
      const appHash = await fileHash(path.join(OUT_PATH, fileName));
      await fs.writeFile(path.join(OUT_PATH, `${fileName}.sha256`), appHash);
    })
  );
}

export const start = async (isDev = false) => {
  try {
    await fs.remove(OUT_PATH);
    await fs.mkdir(OUT_PATH);
    const arches = getArches();

    await startDashboard(isDev);
    for (let i = 0; i < arches.length; i += 1) {
      process.env.ARCH = arches[i];
      const downloadTypes = [ThirdPartyType.LuxCore];
      await startDownload(downloadTypes, arches[i]);
      console.log("Creating core...");
      const coreTypes = [CoreType.Config, CoreType.LuxCore, CoreType.Dashboard];
      await createCoreDir(coreTypes);
      await fs.move(CORE_DIR_NAME, path.join(CLIENT_PATH, CORE_DIR_NAME), {
        overwrite: true,
      });
      console.log("Create core done!");
      await startClient(arches[i], isDev);
      await copyPortableApp();
      await copyInstaller();
    }
    await calculateFileHash();
    const fileNames = await fs.readdir(OUT_PATH);
    await Promise.all(
      fileNames.map(async (fileName) => {
        if (fileName.endsWith(".sha256")) {
          const basename = path.basename(fileName, ".sha256");
          const outDirName = basename.replace(/\.exe|\.dmg|\.zip/, "");
          const releaseRootDir = path.join(".", OUT_PATH, "release");
          const releaseDir = path.join(releaseRootDir, outDirName);
          await fs.mkdir(releaseDir, { recursive: true });
          await fs.copy(
            path.join(OUT_PATH, fileName),
            path.join(releaseDir, fileName)
          );
          await fs.copy(
            path.join(OUT_PATH, basename),
            path.join(releaseDir, basename)
          );
          const zip = new AdmZip();
          zip.addLocalFolder(releaseDir);
          zip.writeZip(`${releaseDir}.zip`, (err) => {
            if (err) {
              console.log("err", err);
            }
          });
        }
      })
    );
  } catch (e) {
    console.error(e);
  }
};

start();
