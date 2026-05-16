//
//  Memo.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/05.
//

import RealmSwift

class Memo: Object {

    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var text = ""
    
    @Persisted var date = Date()

    @Persisted var displayOrder = 0
}
