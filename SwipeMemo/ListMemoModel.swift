//
//  ListMemoModel.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/09.
//

import RealmSwift

protocol ListMemoModelInput {
    func delete(memo: Memo) throws -> Void
    func fetchAll() throws -> [Memo]
    func updateDisplayOrder(memos: [Memo], isFavorite: Bool) throws -> Void
}

struct ListMemoModel: ListMemoModelInput {

    func fetchAll () throws -> [Memo] {
        do {
            let realm = try Realm()
            return Array(MemoOrderingHelper.orderedFavoriteMemos(in: realm)) +
                Array(MemoOrderingHelper.orderedRegularMemos(in: realm))
        } catch let error as NSError {
            print(error.localizedDescription)
            throw StorageError.read("The memo list could not be loaded")
        }
    }
    
    func delete(memo: Memo) throws -> Void {
        do {
            guard !memo.isInvalidated else {
                throw StorageError.write("The selected data could not be deleted")
            }

            let memoID = memo.id
            let realm = try Realm()
            guard let storedMemo = realm.object(ofType: Memo.self, forPrimaryKey: memoID) else {
                throw StorageError.write("The selected data could not be deleted")
            }

            try realm.write {
                realm.delete(storedMemo)
                MemoOrderingHelper.normalizeDisplayOrder(in: realm)
                MemoOrderingHelper.normalizeFavoriteDisplayOrder(in: realm)
            }

        } catch let error as StorageError {
            throw error
        } catch let error as NSError {
            print(error.localizedDescription)
            throw StorageError.write("The selected data could not be deleted")
        }
    }

    func updateDisplayOrder(memos: [Memo], isFavorite: Bool) throws -> Void {
        do {
            guard memos.allSatisfy({ !$0.isInvalidated && $0.isFavorite == isFavorite }) else {
                throw StorageError.write("The memo order could not be saved")
            }

            let realm = try Realm()
            let memoIDs = memos.map { $0.id }
            let uniqueMemoIDs = Set(memoIDs.map { $0.stringValue })
            let expectedMemoCount = realm.objects(Memo.self).filter("isFavorite == %@", isFavorite).count

            guard memoIDs.count == uniqueMemoIDs.count,
                  memoIDs.count == expectedMemoCount else {
                throw StorageError.write("The memo order could not be saved")
            }

            try realm.write {
                MemoOrderingHelper.normalizeDisplayOrder(in: realm)
                let favoriteDisplayOrders = Set(
                    realm.objects(Memo.self)
                        .filter("isFavorite == true")
                        .map { $0.displayOrder }
                )
                let availableDisplayOrders = (0..<realm.objects(Memo.self).count).filter {
                    !favoriteDisplayOrders.contains($0)
                }

                guard isFavorite || availableDisplayOrders.count == memoIDs.count else {
                    throw StorageError.write("The memo order could not be saved")
                }

                for (index, memoID) in memoIDs.enumerated() {
                    guard let memo = realm.object(ofType: Memo.self, forPrimaryKey: memoID),
                          memo.isFavorite == isFavorite else {
                        throw StorageError.write("The memo order could not be saved")
                    }

                    if isFavorite {
                        memo.favoriteDisplayOrder = index
                    } else {
                        memo.displayOrder = availableDisplayOrders[index]
                    }
                }
            }

        } catch let error as StorageError {
            throw error
        } catch let error as NSError {
            print(error.localizedDescription)
            throw StorageError.write("The memo order could not be saved")
        }
    }
}
