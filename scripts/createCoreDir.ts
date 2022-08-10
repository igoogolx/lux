import { CoreType, createCoreDir } from "./actions";
import { downloadThirdParties, ThirdPartyType } from "./thirdParties";

async function main() {
  await downloadThirdParties([ThirdPartyType.GeoData, ThirdPartyType.Wintun]);
  await createCoreDir([
    CoreType.Config,
    CoreType.Wintun,
    CoreType.Dashboard,
    CoreType.GeoData,
  ]);
}

main();
