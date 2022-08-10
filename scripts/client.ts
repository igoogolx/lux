import { getClientName, runScript } from "./utils";

export const buildClient = async (path: string, isDev = false) => {
  const outName = `${getClientName()}.\${ext}`;
  await runScript("yarn", ["install"], path);
  const makeScript = isDev ? "make:dev" : "make";
  await runScript(
    "yarn",
    [makeScript, "--config.artifactName", outName],
    path,
    true
  );
};
