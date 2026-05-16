//
//  EditMemoModel.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/10.
//

import RealmSwift

protocol EditMemoModelInput {
    func save(memoID: ObjectId, text: String) throws -> Void
    func toggleFavorite(memoID: ObjectId) throws -> Bool
}

struct EditMemoModel: EditMemoModelInput {
    
    func save(memoID: ObjectId, text: String) throws -> Void {
        do {
            let realm = try Realm()
            guard let storedMemo = realm.object(ofType: Memo.self, forPrimaryKey: memoID) else {
                throw StorageError.write("The selected data could not be edited")
            }

            try realm.write {
                storedMemo.text = text
            }
            
        } catch let error as StorageError {
            throw error
        } catch let error as NSError {
            print(error.localizedDescription)
            throw StorageError.write("Not enough disk space for editing")
        }
    }

    func toggleFavorite(memoID: ObjectId) throws -> Bool {
        do {
            let realm = try Realm()
            guard let storedMemo = realm.object(ofType: Memo.self, forPrimaryKey: memoID) else {
                throw StorageError.write("The selected data could not be edited")
            }

            var updatedIsFavorite = storedMemo.isFavorite
            try realm.write {
                updatedIsFavorite = !storedMemo.isFavorite

                if updatedIsFavorite {
                    let favoriteDisplayOrder = MemoOrderingHelper.nextFavoriteDisplayOrder(in: realm)
                    storedMemo.isFavorite = true
                    storedMemo.favoriteDisplayOrder = favoriteDisplayOrder
                } else {
                    storedMemo.isFavorite = false
                    storedMemo.favoriteDisplayOrder = 0
                    MemoOrderingHelper.normalizeFavoriteDisplayOrder(in: realm)
                }
            }

            return updatedIsFavorite

        } catch let error as StorageError {
            throw error
        } catch let error as NSError {
            print(error.localizedDescription)
            throw StorageError.write("Not enough disk space for editing")
        }
    }
}
