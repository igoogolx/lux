import * as fs from "fs-extra";
import { buildClient } from "./client";
import { downloadThirdParties, ThirdPartyType } from "./thirdParties";
import { copyDefaultConfig, copyLuxCore } from "./copy";
import { CLIENT_PATH, CORE_DIR_NAME, THIRD_PARTIES_PATH } from "./constants";

export enum CoreType {
  Config,
  LuxCore,
}

export const createCoreDir = async (types: CoreType[]) => {
  try {
    await fs.remove(CORE_DIR_NAME);
    if (types.includes(CoreType.Config)) {
      await copyDefaultConfig();
    }

    if (types.includes(CoreType.LuxCore)) {
      await copyLuxCore();
    }
  } finally {
    await fs.remove(THIRD_PARTIES_PATH);
  }
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
