import * as crypto from "crypto";
import * as fs from "fs";
import * as os from "os";
import * as shell from "shelljs";

export const runScript = (
  command: string,
  args: string[],
  cwd: string,
  ignoreErr = false
) => {
  return new Promise((resolve, reject) => {
    shell.exec(
      `${command} ${args.join(" ")}`,
      { cwd },
      (err, stdout, stderr) => {
        if (err) {
          reject(err);
          return;
        }
        if (!ignoreErr && stderr) {
          reject(stderr);
          return;
        }
        resolve(stdout);
      }
    );
  });
};

export function fileHash(filename: string, algorithm = "sha256") {
  return new Promise((resolve, reject) => {
    const shasum = crypto.createHash(algorithm);
    try {
      const s = fs.createReadStream(filename);
      s.on("data", (data) => {
        shasum.update(data);
      });
      s.on("end", () => {
        const hash = shasum.digest("hex");
        return resolve(hash);
      });
    } catch (error) {
      reject(new Error("calc fail"));
    }
  });
}

const packageInfo = JSON.parse(fs.readFileSync("package.json", "utf8"));
export const getClientName = () =>
  `${packageInfo.name}-${os.platform}-${os.arch()}-${packageInfo.version}`;
