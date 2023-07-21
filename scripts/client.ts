import { getInstallerName, runScript, packageInfo, capitalized } from "./utils";

export const buildClient = async (path: string, arch: string) => {
  const outName = getInstallerName();
  await runScript("yarn", ["install"], path, true);
  await runScript(
    "yarn",
    ["build", `CLIENT_VERSION=${packageInfo.version}`],
    path,
    true
  );
  await runScript(
    "yarn",
    [
      "electron-builder",
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
