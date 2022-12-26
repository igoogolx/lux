import * as fs from "fs-extra";
import * as path from "path";

import { THIRD_PARTIES_PATH } from "./constants";
import { getCoreName } from "./utils";

export const copyGeoData = () =>
  fs.copy(
    path.join(THIRD_PARTIES_PATH, "geoData"),
    path.join("core", "geoData")
  );

export const copyDefaultConfig = () =>
  fs.copy(
    path.join(process.cwd(), "default-config", "config.json"),
    path.join("core", "config.json")
  );

export const copyLuxCore = () => {
  const coreName = getCoreName();
  return fs.copy(
    path.join(THIRD_PARTIES_PATH, coreName),
    path.join("core", coreName)
  );
};
