import * as os from "os";
import { getInstallerName, runScript } from "./utils";

export const buildClient = async (path: string, isDev = false) => {
  const platform = os.platform();
  let buildForOs = "";
  if (platform === "win32") {
    buildForOs = "--win";
  } else if (platform === "darwin") {
    buildForOs = "--mac";
  }
  const outName = getInstallerName();
  await runScript("yarn", ["install"], path);
  const makeScript = isDev ? "make:dev" : "make";
  await runScript(
    "yarn",
    [makeScript, "--config.artifactName", outName, buildForOs],
    path,
    true
  );
};
