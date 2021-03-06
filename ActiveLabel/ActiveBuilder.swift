//
//  ActiveBuilder.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 04/09/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

typealias ActiveFilterPredicate = ((String) -> Bool)

struct ActiveBuilder {

    static func createURLElements(from text: String, range: NSRange, maximumLength: Int?) -> ([ElementTuple], String) {
        let type = ActiveType.url
        var text = text
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 2 {
            let word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            guard let maxLength = maximumLength, word.count > maxLength else {
                let range = maximumLength == nil ? match.range : (text as NSString).range(of: word)
                let element = ActiveElement.create(with: type, text: word)
                elements.append((range, element, type))
                continue
            }

            let trimmedWord = word.trim(to: maxLength)
            text = text.replacingOccurrences(of: word, with: trimmedWord)

            let newRange = (text as NSString).range(of: trimmedWord)
            let element = ActiveElement.url(original: word, trimmed: trimmedWord)
            elements.append((newRange, element, type))
        }
        return (elements, text)
    }

    static func createElements(from text: String, for type: ActiveType, range: NSRange, minLength: Int = 2, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > minLength {
            let word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }

    static func createElementsIgnoringFirstCharacter(from text: String, for type: ActiveType, maximumLength: Int? = nil, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 1 {
            let range = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            var word = nsstring.substring(with: range)
            if word.hasPrefix("@") {
                word.remove(at: word.startIndex)
            }
            else if word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }

            if word.isURL() {
                continue
            }

            if let maxLength = maximumLength, word.count > maxLength {
                continue
            }

            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }

    static func createHashtagElements(from text: String, for type: ActiveType, hashtags: [String], maximumLength: Int?, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for (key, match) in matches.enumerated() where match.range.length > 1 {
            var word = nsstring.substring(with: match.range).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            let urlElements = RegexParser.getElements(from: text, with: ActiveType.url.pattern, range: range).map {
                nsstring.substring(with: $0.range).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
            .map { $0.contains(word) }
            .filter { $0 }

            if urlElements.indices.contains(key) {
                continue
            }

            if word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }

            if word.isURL() {
                continue
            }

            if let maxLength = maximumLength, word.count > maxLength {
                continue
            }

            if filterPredicate?(word) ?? true {
                if let index = hashtags.firstIndex(of: word) {
                    let text = hashtags[index]
                    let element = ActiveElement.create(with: type, text: text)
                    elements.append((match.range, element, type))
                } else {
                    var text: String {
                        var pool: String = ""
                        var result: String = ""
                        for character in word {
                            pool += character.description
                            if let index = hashtags.firstIndex(of: pool) {
                                result = hashtags[index]
                            } else {
                                continue
                            }
                        }
                        return result
                    }
                    if !text.isEmpty {
                        let element = ActiveElement.create(with: type, text: text)
                        let range = NSRange(location: match.range.location, length: match.range.length - word[text.endIndex...].count)
                        elements.append((range, element, type))
                    }
                }
            }
        }

        return elements
    }
}

private extension String {
    func isURL() -> Bool {
        return hasPrefix("https") || hasPrefix("http")
    }
}
