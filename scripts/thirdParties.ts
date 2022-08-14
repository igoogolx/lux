import { download } from "./downloader";

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
      url: "https://github.com/igoogolx/lux-geo-data/releases/download/v0.0.1/geoData.tar.gz",
      outPath: "third_parties/geoData.tar.gz",
      checksum:
        "81113cea22b0899e26bd4742933d9bbbc65bcebaebf787796d0512666c343dd5",
    });
  }
  if (types.includes(ThirdPartyType.LuxCore)) {
    await download({
      url: "https://github.com/igoogolx/lux-core/releases/download/v0.0.1/lux-core-windows-latest-v0.0.1.exe",
      outPath: "third_parties/lux-core.exe",
      checksum:
        "7df1f5cdb32f5311ffc3e415e93dbb72f965261f5e796ff1df2bca5341cd9738",
    });
  }
};
