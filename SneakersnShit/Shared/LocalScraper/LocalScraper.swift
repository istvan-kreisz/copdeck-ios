//
//  LocalScraper.swift
//  SneakersnShit
//
//  Created by István Kreisz on 6/26/21.
//

import UIKit
import JavaScriptCore

class LocalScraper: NSObject {
    static let shared = LocalScraper()
    private let vm = JSVirtualMachine()
    private let context: JSContext

    private override init() {
        let jsCode = """
         function randomNumber(min, max) {
             min = Math.ceil(min);
             max = Math.floor(max);
             //The maximum is inclusive and the minimum is inclusive
             return Math.floor(Math.random() * (max - min + 1)) + min;
         }

         function analyze(sentence) {
             return randomNumber(-5, 5);
         }
         """
        context = JSContext(virtualMachine: vm)
        context.evaluateScript(jsCode)
    }

    func analyze(_ sentence: String, completion: @escaping (_ score: Int) -> Void) {
        // Run this asynchronously in the background
        DispatchQueue.global(qos: .userInitiated).async {
            var score = 0
            if let result = self.context.objectForKeyedSubscript("analyze").call(withArguments: [sentence]) {
                score = Int(result.toInt32())
            }
            DispatchQueue.main.async {
                completion(score)
            }
        }
    }
}
