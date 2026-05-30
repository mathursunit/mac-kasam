import Foundation
import GRDB

struct VaultEntry: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var title: String
    var username: String
    var encryptedPassword: Data
    var url: String?
    var matchWindowTitle: String?
    
    func getPassword() -> String? {
        return try? CryptoHelper.shared.decrypt(data: encryptedPassword)
    }
}

class VaultManager {
    static let shared = VaultManager()
    var dbQueue: DatabaseQueue!
    
    func setupDatabase() throws {
        let appSupportUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupportUrl.appendingPathComponent("MacKasam")
        if !FileManager.default.fileExists(atPath: appDir.path) {
            try FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true, attributes: nil)
        }
        let dbUrl = appDir.appendingPathComponent("vault.sqlite")
        
        dbQueue = try DatabaseQueue(path: dbUrl.path)
        
        try dbQueue.write { db in
            try db.create(table: "vaultEntry", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("username", .text).notNull()
                t.column("encryptedPassword", .blob).notNull()
                t.column("url", .text)
                t.column("matchWindowTitle", .text)
            }
        }
    }
    
    func addEntry(title: String, username: String, passwordRaw: String, url: String?, matchWindowTitle: String?) throws {
        let encryptedPass = try CryptoHelper.shared.encrypt(string: passwordRaw)
        var entry = VaultEntry(title: title, username: username, encryptedPassword: encryptedPass, url: url, matchWindowTitle: matchWindowTitle)
        try dbQueue.write { db in
            try entry.insert(db)
        }
    }
    
    func fetchAll() throws -> [VaultEntry] {
        return try dbQueue.read { db in
            try VaultEntry.fetchAll(db)
        }
    }
    
    func findMatches(for windowTitle: String) throws -> [VaultEntry] {
        return try dbQueue.read { db in
            // Simple partial match using LIKE
            try VaultEntry.filter(Column("matchWindowTitle").like("%\(windowTitle)%")).fetchAll(db)
        }
    }
}
