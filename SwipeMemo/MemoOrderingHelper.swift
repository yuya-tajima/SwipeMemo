//
//  MemoOrderingHelper.swift
//  SwipeMemo
//

import RealmSwift

enum MemoOrderingHelper {

    static func orderedMemosByDisplayOrder(in realm: Realm) -> Results<Memo> {
        return realm.objects(Memo.self).sorted(by: [
            SortDescriptor(keyPath: "displayOrder", ascending: true),
            SortDescriptor(keyPath: "date", ascending: false)
        ])
    }

    static func orderedFavoriteMemos(in realm: Realm) -> Results<Memo> {
        return realm.objects(Memo.self).filter("isFavorite == true").sorted(by: [
            SortDescriptor(keyPath: "favoriteDisplayOrder", ascending: true),
            SortDescriptor(keyPath: "date", ascending: false)
        ])
    }

    static func orderedRegularMemos(in realm: Realm) -> Results<Memo> {
        return realm.objects(Memo.self).filter("isFavorite == false").sorted(by: [
            SortDescriptor(keyPath: "displayOrder", ascending: true),
            SortDescriptor(keyPath: "date", ascending: false)
        ])
    }

    static func normalizeDisplayOrder(in realm: Realm) {
        let memos = Array(orderedMemosByDisplayOrder(in: realm))
        for (index, memo) in memos.enumerated() {
            memo.displayOrder = index
        }
    }

    static func normalizeFavoriteDisplayOrder(in realm: Realm) {
        let memos = Array(orderedFavoriteMemos(in: realm))
        for (index, memo) in memos.enumerated() {
            memo.favoriteDisplayOrder = index
        }
    }

    static func nextFavoriteDisplayOrder(in realm: Realm) -> Int {
        normalizeFavoriteDisplayOrder(in: realm)
        return realm.objects(Memo.self).filter("isFavorite == true").count
    }
}
