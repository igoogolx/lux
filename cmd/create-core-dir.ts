import { downloadThirdParties, ThirdPartyType } from "../scripts/thirdParties";
import { CoreType, createCoreDir } from "../scripts/actions";

async function main() {
  await downloadThirdParties([ThirdPartyType.GeoData]);
  await createCoreDir([CoreType.Config, CoreType.Dashboard, CoreType.GeoData]);
}

main();
