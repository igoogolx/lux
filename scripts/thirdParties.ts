import * as os from "os";
import { download } from "./downloader";
import { getCoreName, modulesConfig } from "./utils";

export enum ThirdPartyType {
  GeoData,
  LuxCore,
}

export const downloadThirdParties = async (types: ThirdPartyType[]) => {
  if (types.includes(ThirdPartyType.GeoData)) {
    await download({
      url: modulesConfig.thirdParties.geo.url,
      outPath: "third_parties/geoData.tar.gz",
      checksum: modulesConfig.thirdParties.geo.checksum,
    });
  }
  if (types.includes(ThirdPartyType.LuxCore)) {
    const platform = os.platform();
    if (platform === "win32") {
      await download({
        url: modulesConfig.thirdParties.core.win.url,
        outPath: `third_parties/${getCoreName()}`,
        checksum: modulesConfig.thirdParties.core.win.checksum,
      });
    }
    if (platform === "darwin") {
      await download({
        url: modulesConfig.thirdParties.core.mac.url,
        outPath: `third_parties/${getCoreName()}`,
        checksum: modulesConfig.thirdParties.core.mac.checksum,
      });
    }
  }
};
