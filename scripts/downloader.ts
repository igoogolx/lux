import * as path from "path";
import * as fs from "fs";
import * as fsExtra from "fs-extra";
import { pipeline } from "stream/promises";
import axios from "axios";
import * as decompress from "decompress";
import { fileHash } from "./utils";

const COMPRESSED_NAMES = [".zip", ".tar.gz"];

export const downloadFile = async (url: string, outPath: string) => {
  try {
    const request = await axios.get(url, {
      responseType: "stream",
    });
    await fsExtra.ensureDir(path.dirname(outPath));
    await pipeline(request.data, fs.createWriteStream(outPath));
  } catch (error) {
    console.error("download pipeline failed", error);
  }
};

export const download = async (option: {
  url: string;
  outPath: string;
  checksum?: string;
}) => {
  const { url, outPath, checksum } = option;
  await downloadFile(url, outPath);
  const hash = await fileHash(outPath);
  if (checksum) {
    if (hash !== checksum) {
      throw new Error("checksum is not matched");
    }
  }
  const ext = COMPRESSED_NAMES.find((name) => outPath.endsWith(name));
  if (COMPRESSED_NAMES.includes(ext)) {
    await decompress(outPath, path.dirname(outPath));
  }
};
