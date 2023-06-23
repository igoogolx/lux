import * as os from "os";
import * as path from "path";
import { download } from "./downloader";
import { modulesConfig } from "./utils";

export enum ThirdPartyType {
  LuxCore,
}

export const downloadThirdParties = async (
  types: ThirdPartyType[],
  arch: string
) => {
  if (types.includes(ThirdPartyType.LuxCore)) {
    const platform = os.platform();
    if (platform === "win32") {
      await download({
        url: modulesConfig.thirdParties.core[`windows_${arch}`].url,
        outPath: path.join("third_parties", "itun2socks.zip"),
        checksum: modulesConfig.thirdParties.core[`windows_${arch}`].checksum,
      });
    }
    if (platform === "darwin") {
      await download({
        url: modulesConfig.thirdParties.core[`darwin_${arch}`].url,
        outPath: path.join("third_parties", "itun2socks.tar.gz"),
        checksum: modulesConfig.thirdParties.core[`darwin_${arch}`].checksum,
      });
    }
  }
};
