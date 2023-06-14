import * as fs from "fs-extra";
import * as path from "path";

import { ITUN2SOCKS_PATH, THIRD_PARTIES_PATH } from "./constants";
import { getCoreName, getItun2socksName } from "./utils";

export const copyLuxCore = () => {
  const coreName = getCoreName();
  return fs.copy(
    path.join(THIRD_PARTIES_PATH, getItun2socksName()),
    path.join("core", coreName)
  );
};

export const copyConfig = () => {
  return fs.copy(
    path.join(ITUN2SOCKS_PATH, "configuration", "assets", "config.json"),
    path.join("core", "config.json")
  );
};
