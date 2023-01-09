import * as path from "path";
import { packageInfo, runScript } from "./utils";

export async function wingetRelease() {
  const { version } = packageInfo;
  const ulr = `https://github.com/igoogolx/lux/releases/download/v${version}/lux-win32-x64-${version}.exe`;
  await runScript("winget", ["install", "wingetcreate"], ".");
  await runScript(
    "wingetcreate",
    [
      "update",
      "--urls",
      ulr,
      "--out",
      "winget-release",
      "--version",
      version,
      "igoogolx.lux",
    ],
    "."
  );
  await runScript(
    "wingetcreate",
    [
      "submit",
      path.join("winget-release", "manifests", "i", "igoogolx", "lux", version),
    ],
    "."
  );
}

wingetRelease();
