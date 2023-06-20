import { getInstallerName, runScript, packageInfo } from "./utils";

export const buildClient = async (
  path: string,
  arch: string,
  isDev = false
) => {
  const buildForOs = "";
  const outName = getInstallerName();
  await runScript("yarn", ["install"], path);
  const makeScript = isDev ? "make:dev" : "make";
  await runScript(
    "yarn",
    [
      makeScript,
      "--config.artifactName",
      outName,
      "--config.extraMetadata.version",
      packageInfo.version,
      buildForOs,
      `--${arch}`,
    ],
    path,
    true
  );
};
