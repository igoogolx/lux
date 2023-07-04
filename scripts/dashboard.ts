import { packageInfo, runScript } from "./utils";

export const buildDashboard = async (path: string) => {
  await runScript("yarn", ["install"], path, true);
  const buildScript = `build:ui --env CLIENT_VERSION=${packageInfo.version}`;
  await runScript("yarn", [buildScript], path, true);
};
