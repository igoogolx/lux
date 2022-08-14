import * as fs from "fs-extra";
import * as path from "path";

import { THIRD_PARTIES_PATH } from "./constants";

export const copyGeoData = () =>
  fs.copy(
    path.join(THIRD_PARTIES_PATH, "geoData"),
    path.join("core", "geoData")
  );

export const copyWintun = () =>
  fs.copy(
    path.join(THIRD_PARTIES_PATH, "wintun", "bin", "amd64", "wintun.dll"),
    path.join("core", "wintun.dll")
  );

export const copyDefaultConfig = () =>
  fs.copy(
    path.join(process.cwd(), "default-config", "config.json"),
    path.join("core", "config.json")
  );

export const copyLuxCore = () =>
  fs.copy(
    path.join(THIRD_PARTIES_PATH, "lux-core.exe"),
    path.join("core", "lux-core.exe")
  );
