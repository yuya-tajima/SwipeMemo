//
//  InputMemoHelper.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/09.
//

protocol InputMemoConstraintsProtocol {
    func isNumberOfCharsCorrent(totalWordCount: Int) -> Bool
    func normalizedTextForSaving(_ text: String) -> String
}

struct InputMemoHelper: InputMemoConstraintsProtocol {
    
    let maxCharactersNumber = 1000
    
    func isNumberOfCharsCorrent(totalWordCount: Int) -> Bool {
        return totalWordCount <= maxCharactersNumber
    }

    func normalizedTextForSaving(_ text: String) -> String {
        var lines = text.components(separatedBy: .newlines)

        while let lastLine = lines.last,
              lastLine.trimmingCharacters(in: .whitespaces).isEmpty {
            lines.removeLast()
        }

        return lines.joined(separator: "\n")
    }
}
