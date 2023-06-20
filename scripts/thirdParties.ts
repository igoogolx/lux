import * as os from "os";
import * as path from "path";
import { download } from "./downloader";
import { modulesConfig } from "./utils";

export enum ThirdPartyType {
  LuxCore,
}

export const downloadThirdParties = async (types: ThirdPartyType[]) => {
  if (types.includes(ThirdPartyType.LuxCore)) {
    const platform = os.platform();
    if (platform === "win32") {
      const arch = os.arch();
      await download({
        url: modulesConfig.thirdParties.core.win[arch].url,
        outPath: path.join("third_parties", "itun2socks.zip"),
        checksum: modulesConfig.thirdParties.core.win.checksum,
      });
    }
    if (platform === "darwin") {
      await download({
        url: modulesConfig.thirdParties.core.mac.url,
        outPath: path.join("third_parties", "itun2socks.tar.gz"),
        checksum: modulesConfig.thirdParties.core.mac.checksum,
      });
    }
  }
};
