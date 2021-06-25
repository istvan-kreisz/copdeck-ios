import { nodeAPI } from "@istvankreisz/copdeck-scraper";
import { APIConfig } from "@istvankreisz/copdeck-scraper/dist/types";

const config: APIConfig = {
  currency: { code: "GBP", symbol: "£" },
  isLoggingEnabled: true,
  proxies: [
    // {
    // 	host: '144.91.97.235',
    // 	port: 80,
    // 	protocol: 'http',
    // },
    // {
    // 	host: '157.100.53.109',
    // 	port: 999,
    // 	protocol: 'http',
    // },
    // {
    // 	host: '139.9.133.196',
    // 	port: 808,
    // 	protocol: 'http',
    // },
    // {
    // 	host: '217.79.181.109',
    // 	port: 443,
    // 	protocol: 'http',
    // },
  ],
  exchangeRates: { usd: 1.2125, gbp: 0.8571, chf: 1.0883, nok: 10.0828 },
  feeCalculation: {
    countryName: "Austria",
    stockx: {
      sellerLevel: 1,
      taxes: 0,
    },
    goat: {
      commissionPercentage: 9.5,
      cashOutFee: 0.029,
      taxes: 0,
    },
  },
};

const test = async () => {
  nodeAPI
    .getExchangeRates(config)
    .then((result) => {
      console.log(result);
    })
    .catch((err) => {
      console.log(err);
    });
};

export { test };

// export class Analyzer {
//   static analyze(phrase) {
//     return phrase;
//   }
// }
