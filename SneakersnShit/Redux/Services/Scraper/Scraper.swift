//
//  Scraper.swift
//  SneakersnShit
//
//  Created by István Kreisz on 2/15/21.
//

import Foundation
import WebKit
import Kanna

class Scraper: NSObject {
    let webView: WKWebView

    override init() {
        webView = WKWebView(frame: CGRect.zero)
        super.init()
        UIApplication.shared.windows.first?.addSubview(webView)
        webView.navigationDelegate = self

        let url = URL(string: "https://stockx.com/nike-air-force-1-07-qs-love-letter")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension Scraper: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
    }
}
