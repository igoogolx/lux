import * as os from "os";
import { download } from "./downloader";
import { getCoreName } from "./utils";

export enum ThirdPartyType {
  Wintun,
  GeoData,
  LuxCore,
}

export const downloadThirdParties = async (types: ThirdPartyType[]) => {
  if (types.includes(ThirdPartyType.Wintun)) {
    await download({
      url: "https://www.wintun.net/builds/wintun-0.14.1.zip",
      outPath: "third_parties/wintun.zip",
      checksum:
        "07c256185d6ee3652e09fa55c0b673e2624b565e02c4b9091c79ca7d2f24ef51",
    });
  }
  if (types.includes(ThirdPartyType.GeoData)) {
    await download({
      url: "https://github.com/igoogolx/lux-geo-data/releases/download/v0.0.2/geoData.tar.gz",
      outPath: "third_parties/geoData.tar.gz",
      checksum:
        "cf1104003e4a4bf108822449dfbba8df9c1d9ea1c16e37554655ee2ae89dff6c",
    });
  }
  if (types.includes(ThirdPartyType.LuxCore)) {
    const platform = os.platform();
    if (platform === "win32") {
      await download({
        url: "https://github.com/igoogolx/lux-core/releases/download/v0.0.2/lux-core-windows-latest-v0.0.3.exe",
        outPath: `third_parties/${getCoreName()}`,
        checksum:
          "2f05bdcf7505d3227be9dc3ad40a0c0c8540e6db718b93130b6e035e620fcfc1",
      });
    }
    if (platform === "darwin") {
      await download({
        url: "https://github.com/igoogolx/lux-core/releases/download/v0.0.2/lux-core-macos-latest-v0.0.2",
        outPath: `third_parties/${getCoreName()}`,
        checksum:
          "f36c054509c033563e8d1a7bfae926e9055f286bce90d6df4a06dd71e8262ac2",
      });
    }
  }
};
