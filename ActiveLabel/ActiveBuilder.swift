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

    static func createElementsIgnoringFirstCharacter(from text: String, for type: ActiveType, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
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

            if word.hasPrefix("https") || word.hasPrefix("http") {
                continue
            }

            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }

    static func createHashtagElements(from text: String, for type: ActiveType, hashtags: [String], range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 1 {
            var word = nsstring.substring(with: match.range).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            if word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }

            if word.hasPrefix("https") || word.hasPrefix("http") {
                continue
            }

            if filterPredicate?(word) ?? true {
                if let index = hashtags.firstIndex(of: word) {
                    let text = hashtags[index]
                    let element = ActiveElement.create(with: type, text: text)
                    elements.append((match.range, element, type))
                } else {
                    var string: String = ""
                    var words: [String] = []
                    for character in word {
                        string += character.description
                        if let index = hashtags.firstIndex(of: string) {
                            words.append(hashtags[index])
                        } else {
                            continue
                        }
                    }
                    if !words.isEmpty, let word = words.last, let index = hashtags.firstIndex(of: word) {
                        let text = hashtags[index]
                        let element = ActiveElement.create(with: type, text: text)
                        elements.append((match.range, element, type))
                    }
                }
            }
        }

        return elements
    }
}
