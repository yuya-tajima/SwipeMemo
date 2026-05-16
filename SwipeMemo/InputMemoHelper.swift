//
//  InputMemoHelper.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/09.
//

protocol InputMemoConstraintsProtocol {
    func isNumberOfCharsCorrent(totalWordCount: Int) -> Bool
}

struct InputMemoHelper: InputMemoConstraintsProtocol {
    
    let maxCharactersNumber = 1000
    
    func isNumberOfCharsCorrent(totalWordCount: Int) -> Bool {
        return totalWordCount <= maxCharactersNumber
    }
}
