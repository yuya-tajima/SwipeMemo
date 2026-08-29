//
//  CreateMemoModel.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/10.
//

import RealmSwift

protocol CreateMemoModelInput {
    func save(memoID: ObjectId, text: String, isFavorite: Bool) throws -> Void
}

struct CreateMemoModel: CreateMemoModelInput {
    
    func save(memoID: ObjectId, text: String, isFavorite: Bool) throws -> Void {
        do {
            let realm = try Realm()

            try realm.write {
                if let storedMemo = realm.object(ofType: Memo.self, forPrimaryKey: memoID) {
                    update(
                        memo: storedMemo,
                        text: text,
                        isFavorite: isFavorite,
                        in: realm
                    )
                } else {
                    create(
                        memoID: memoID,
                        text: text,
                        isFavorite: isFavorite,
                        in: realm
                    )
                }
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
            throw StorageError.write("Not enough disk space for creating")
        }
    }

    private func create(memoID: ObjectId, text: String, isFavorite: Bool, in realm: Realm) {
        let existingMemos = Array(MemoOrderingHelper.orderedMemosByDisplayOrder(in: realm))

        for (index, memo) in existingMemos.enumerated() {
            memo.displayOrder = index + 1
        }

        let memo = Memo()
        memo.id = memoID
        memo.text = text
        memo.date = Date()
        memo.displayOrder = 0
        memo.isFavorite = isFavorite
        memo.favoriteDisplayOrder = isFavorite ? MemoOrderingHelper.nextFavoriteDisplayOrder(in: realm) : 0
        realm.add(memo, update: .modified)
    }

    private func update(memo: Memo, text: String, isFavorite: Bool, in realm: Realm) {
        memo.text = text

        guard memo.isFavorite != isFavorite else {
            return
        }

        if isFavorite {
            let favoriteDisplayOrder = MemoOrderingHelper.nextFavoriteDisplayOrder(in: realm)
            memo.isFavorite = true
            memo.favoriteDisplayOrder = favoriteDisplayOrder
        } else {
            memo.isFavorite = false
            memo.favoriteDisplayOrder = 0
            MemoOrderingHelper.normalizeFavoriteDisplayOrder(in: realm)
        }
    }
}
