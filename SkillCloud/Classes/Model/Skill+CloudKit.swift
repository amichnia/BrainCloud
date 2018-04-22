//
// Copyright (c) 2017 amichnia. All rights reserved.
//

import Foundation
import PromiseKit
import CloudKit

// MARK: - CKRecordMappable
extension Skill: CKRecordMappable {
    // MARK: - Static Keys
    struct CKKey {
        static let Name = "name"
        static let Experience = "experienceValue"
        static let Thumbnail = "thumbnail"
        static let Description = "desc"
        static let Image = "image"
    }

    func performMappingWith(_ record: CKRecord) -> Self? {
        guard let
              title = record.object(forKey: CKKey.Name) as? String,
              let expValue = record.object(forKey: CKKey.Experience) as? Int,
              let experience = Skill.Experience(rawValue: expValue),
              let thumbnail = record.imageForKey(CKKey.Thumbnail) ?? self.thumbnail
                else {
            return nil
        }

        let description = record.object(forKey: CKKey.Description) as? String

        self.title = title
        self.thumbnail = thumbnail
        self.experience = experience
        self.skillDescription = description
        self.recordName = record.recordID.recordName
        self.modified = record.modificationDate
        self.recordChangeTag = record.recordChangeTag

        self.offline = false

        let img = record.imageForKey(CKKey.Image)
        if img == nil && self.image == nil {
            shouldRefetchImage = true
        }

        self.image = img ?? self.image ?? thumbnail

        return self
    }
}

extension Skill {
    func fetchImage(from databaseType: DatabaseType) -> Promise<Void> {
        let container = CKContainer.default()
        let database = databaseType == .public ? container.publicCloudDatabase : container.privateCloudDatabase

        guard self.shouldRefetchImage else {
            return Promise<Void>(value: ())
        }

        return Promise<Void>(resolvers: { (success, failure) in
            guard let recordID = self.recordID else {
                failure(CommonError.notEnoughData)
                return
            }

            database.fetch(withRecordID: recordID, completionHandler: { (record, error) in
                if let _ = record, let image = record?.imageForKey(CKKey.Image) {
                    self.image = image
                    self.shouldRefetchImage = false
                    success()
                } else if let error = error {
                    failure(error)
                } else {
                    failure(CommonError.operationFailed)
                }
            })
        })
    }
}

// MARK: - CKRecordConvertible
extension Skill: CKRecordConvertible {
    func recordRepresentation() -> CKRecord? {
        let record = CKRecord(recordConvertible: self)

        record.setObject(self.title as CKRecordValue?, forKey: CKKey.Name)
        record.setObject(self.experience.rawValue as CKRecordValue?, forKey: CKKey.Experience)
        record.setObject(self.skillDescription as CKRecordValue?, forKey: CKKey.Description)

        if let thumbnail = try? CKAsset.assetWithImage(self.thumbnail) {
            record.setObject(thumbnail, forKey: CKKey.Thumbnail)
        } else {
            return nil
        }

        if let image = try? CKAsset.assetWithImage(self.image) {
            record.setObject(image, forKey: CKKey.Image)
        } else {
            return nil
        }

        self.createdRecord = record    // ??? For clearup data

        return record
    }
}

// MARK: - CKRecordSyncable
extension Skill: CKRecordSyncable {
    func clearTemporaryData() {
        (self.createdRecord?.object(forKey: CKKey.Thumbnail) as? CKAsset)?.clearTemporaryData()
        (self.createdRecord?.object(forKey: CKKey.Image) as? CKAsset)?.clearTemporaryData()
    }
}
