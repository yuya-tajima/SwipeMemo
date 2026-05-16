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
    func updateDisplayOrder(memos: [Memo]) throws -> Void
}

struct ListMemoModel: ListMemoModelInput {

    private func orderedMemos(in realm: Realm) -> Results<Memo> {
        return realm.objects(Memo.self).sorted(by: [
            SortDescriptor(keyPath: "displayOrder", ascending: true),
            SortDescriptor(keyPath: "date", ascending: false)
        ])
    }

    private func normalizeDisplayOrder(in realm: Realm) {
        let memos = Array(orderedMemos(in: realm))
        for (index, memo) in memos.enumerated() {
            memo.displayOrder = index
        }
    }
    
    func fetchAll () throws -> [Memo] {
        do {
            let realm = try Realm()
            let results = orderedMemos(in: realm)
            return Array(results)
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
                normalizeDisplayOrder(in: realm)
            }

        } catch let error as StorageError {
            throw error
        } catch let error as NSError {
            print(error.localizedDescription)
            throw StorageError.write("The selected data could not be deleted")
        }
    }

    func updateDisplayOrder(memos: [Memo]) throws -> Void {
        do {
            guard memos.allSatisfy({ !$0.isInvalidated }) else {
                throw StorageError.write("The memo order could not be saved")
            }

            let realm = try Realm()
            let memoIDs = memos.map { $0.id }
            let uniqueMemoIDs = Set(memoIDs.map { $0.stringValue })

            guard memoIDs.count == uniqueMemoIDs.count,
                  memoIDs.count == realm.objects(Memo.self).count else {
                throw StorageError.write("The memo order could not be saved")
            }

            try realm.write {
                for (index, memoID) in memoIDs.enumerated() {
                    guard let memo = realm.object(ofType: Memo.self, forPrimaryKey: memoID) else {
                        throw StorageError.write("The memo order could not be saved")
                    }

                    memo.displayOrder = index
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
