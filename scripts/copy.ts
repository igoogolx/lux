import * as fs from "fs-extra";
import * as path from "path";

import { THIRD_PARTIES_PATH } from "./constants";
import { getCoreName, getItun2socksName } from "./utils";

export const copyLuxCore = () => {
  const coreName = getCoreName();
  return fs.copy(
    path.join(THIRD_PARTIES_PATH, getItun2socksName()),
    path.join("core", coreName)
  );
};
