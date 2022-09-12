import * as os from "os";
import { getClientName, runScript } from "./utils";

export const buildClient = async (path: string, isDev = false) => {
  const platform = os.platform();
  let buildCmd = "";
  if (platform === "win32") {
    buildCmd = "make:win";
  } else if (platform === "darwin") {
    buildCmd = "make:mac";
  }
  const outName = getClientName();
  await runScript("yarn", ["install"], path);
  const makeScript = isDev ? "make:dev" : buildCmd;
  await runScript(
    "yarn",
    [makeScript, "--config.artifactName", outName],
    path,
    true
  );
};
