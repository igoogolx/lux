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
      url: "https://github.com/igoogolx/lux-geo-data/releases/download/v0.0.4/geoData.tar.gz",
      outPath: "third_parties/geoData.tar.gz",
      checksum:
        "3ea42d9fea2615726b7f7d61c187621564b4a0d653adf890292ed37c1f601c78",
    });
  }
  if (types.includes(ThirdPartyType.LuxCore)) {
    const platform = os.platform();
    if (platform === "win32") {
      await download({
        url: "https://github.com/igoogolx/lux-core/releases/download/v0.0.6/lux-core-windows-latest-v0.0.6.exe",
        outPath: `third_parties/${getCoreName()}`,
        checksum:
          "8f30bfddf5a3a32b6c8fd8118312f0d587646ff2879e9e9de202168d3e291e13",
      });
    }
    if (platform === "darwin") {
      await download({
        url: "https://github.com/igoogolx/lux-core/releases/download/v0.0.6/lux-core-macos-latest-v0.0.6",
        outPath: `third_parties/${getCoreName()}`,
        checksum:
          "452505c481cb0c9f7b3cf2c348462b6b11afb5fa2dc56c63cf3737786361e43a",
      });
    }
  }
};
