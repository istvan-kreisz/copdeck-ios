//
//  Scraper.swift
//  SneakersnShit
//
//  Created by István Kreisz on 2/15/21.
//

import Foundation
import WebKit
import Kanna

enum Site: Int {
    case stockX, klekt, restocks
}

class Scraper: NSObject {
    override init() {
        super.init()

        scrape(urlString: "https://www.klekt.com/new/api/product/view/53234", on: .klekt)
//        scrape(urlString: "https://www.klekt.com/new/api/product/view/53234", on: .klekt)
//        scrape(urlString: "https://stockx.com/nike-air-force-1-07-qs-love-letter", on: .stockX)
    }

    private func scrape(urlString: String, on site: Site) {
        if site == .klekt {
            guard let url = URL(string: urlString), !urlString.isEmpty else { return }
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                do {
                    let result = try JSONDecoder().decode(KlektResult.self, from: data)
                    print(result.data.inventory[0])
                } catch let error as NSError {
                    print(error)
                }
            }
            task.resume()
        } else {
            let webView = WKWebView(frame: CGRect.zero)
            UIApplication.shared.windows.first?.addSubview(webView)
            webView.navigationDelegate = self

            let url = URL(string: "https://stockx.com/nike-air-force-1-07-qs-love-letter")!
            let request = URLRequest(url: url)
            webView.tag = site.rawValue
            webView.load(request)
        }
    }
}

extension Scraper: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let site = Site(rawValue: webView.tag) else { return }
        switch site {
        case .stockX:
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
                if let htmlString = html as? String {
                    if let doc = try? HTML(html: htmlString, encoding: .utf8) {
                        for script in doc.xpath("//script") {
                            if script["type"] == "application/ld+json" {
                                if let content = script.content {
                                    let data = content.data(using: .utf8)!
                                    do {
                                        let result = try JSONDecoder().decode(StockXResult.self, from: data)
                                        print(result.offers.offers)
                                    } catch let error as NSError {
                                        print(error)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        case .klekt:
            break
        case .restocks:
            break
        }
    }
}
