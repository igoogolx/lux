import * as path from "path";
import * as os from "os";

export const MODULES_PATH = path.join(process.cwd(), "modules");
export const DASHBOARD_PATH = path.join(MODULES_PATH, "lux-dashboard");
export const CLIENT_PATH = path.join(MODULES_PATH, "lux-client");
export const THIRD_PARTIES_PATH = path.join(process.cwd(), "third_parties");
export const CORE_DIR_NAME = "core";
export const EXTRA_CORE_DIR_NAME = "extra-core";
