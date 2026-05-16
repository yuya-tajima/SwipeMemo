//
//  CreateMemoModel.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/10.
//

import RealmSwift

protocol CreateMemoModelInput {
    func save(text: String) throws -> Void
}

struct CreateMemoModel: CreateMemoModelInput {
    
    func save(text: String) throws -> Void {
        do {
            let realm = try Realm()

            try realm.write {
                let existingMemos = Array(realm.objects(Memo.self).sorted(by: [
                    SortDescriptor(keyPath: "displayOrder", ascending: true),
                    SortDescriptor(keyPath: "date", ascending: false)
                ]))

                for (index, memo) in existingMemos.enumerated() {
                    memo.displayOrder = index + 1
                }

                let memo = Memo()
                memo.text = text
                memo.date = Date()
                memo.displayOrder = 0
                realm.add(memo, update: .modified)
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
            throw StorageError.write("Not enough disk space for creating")
        }
    }
}
