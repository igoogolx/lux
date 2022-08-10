import { runScript } from "./utils";

export const buildDashboard = async (path: string, isDev = false) => {
  await runScript("yarn", ["install"], path, true);
  const buildScript = isDev ? "build:dev" : "build";
  await runScript("yarn", [buildScript], path);
};
