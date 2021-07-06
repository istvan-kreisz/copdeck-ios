import { appAPI } from "@istvankreisz/copdeck-scraper-app";
import { APIConfig, Item } from "@istvankreisz/copdeck-scraper-app/dist/types";

// @ts-ignore
const nat = native

export var api = {
    getExchangeRates: async function(config: APIConfig) {
        const rates = await appAPI.getExchangeRates(config)
        nat.setExchangeRates(rates)
    },
	searchItems: async function(searchTerm: string, apiConfig: APIConfig) {
        const items = await appAPI.searchItems(searchTerm, apiConfig)
        nat.setItems(items)
    },
    getItemPrices: async function(item: Item, apiConfig: APIConfig) {
        const refreshedItem = await appAPI.getItemPrices(item, apiConfig)
        nat.setItem(refreshedItem)
    }
}

// todo: readd useragents

