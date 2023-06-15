import { packageInfo, runScript } from "./utils";

export const buildDashboard = async (path: string, isDev = false) => {
  await runScript("yarn", ["install"], path, true);
  const buildScript = `${isDev ? "build:dev" : "build"} --env CLIENT_VERSION=${
    packageInfo.version
  }`;
  await runScript("yarn", [buildScript], path, true);
};
