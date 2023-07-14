import { getInstallerName, runScript, packageInfo, capitalized } from "./utils";

export const buildClient = async (
  path: string,
  arch: string,
  isDev = false
) => {
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
      `--${arch}`,
      "--config.extraMetadata.name",
      capitalized(packageInfo.name),
    ],
    path,
    true
  );
};
