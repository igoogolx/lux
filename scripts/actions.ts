import * as path from "path";
import * as fs from "fs-extra";
import { buildDashboard } from "./dashboard";
import { buildClient } from "./client";
import { downloadThirdParties, ThirdPartyType } from "./thirdParties";
import { copyDefaultConfig, copyGeoData, copyWintun } from "./copy";
import {
  CLIENT_PATH,
  CORE_DIR_NAME,
  DASHBOARD_PATH,
  EXTRA_CORE_DIR_NAME,
  THIRD_PARTIES_PATH,
} from "./constants";

export enum CoreType {
  Dashboard,
  GeoData,
  Wintun,
  Config,
}

export const createCoreDir = async (types: CoreType[]) => {
  try {
    await fs.remove(CORE_DIR_NAME);
    await fs.ensureDir(EXTRA_CORE_DIR_NAME);
    await fs.copy(EXTRA_CORE_DIR_NAME, CORE_DIR_NAME);
    if (types.includes(CoreType.Dashboard))
      await fs.copy(
        path.join(DASHBOARD_PATH, "dist"),
        path.join(CORE_DIR_NAME, "web", "dist")
      );
    if (types.includes(CoreType.GeoData)) {
      await copyGeoData();
    }
    if (types.includes(CoreType.Wintun)) {
      await copyWintun();
    }
    if (types.includes(CoreType.Config)) {
      await copyDefaultConfig();
    }
  } finally {
    await fs.remove(THIRD_PARTIES_PATH);
  }
};

export const startDashboard = async (isDev = false) => {
  console.log("Building dashboard...");
  await buildDashboard(DASHBOARD_PATH, isDev);
  console.log("Build dashboard done!");
};

export const startDownload = async (types: ThirdPartyType[]) => {
  console.log("Downloading third parties...");
  await downloadThirdParties(types);
  console.log("Download third parties done!");
};

export const startClient = async (isDev = false) => {
  console.log("Building client...");
  await buildClient(CLIENT_PATH, isDev);
  console.log("Build client done!");
};
