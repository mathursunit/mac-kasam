import Foundation
import CryptoKit

class CryptoHelper {
    static let shared = CryptoHelper()
    
    private var masterKey: SymmetricKey?
    private let salt = "MacKasamSalt123".data(using: .utf8)!
    
    func unlockVault(password: String) {
        let inputKeyMaterial = SymmetricKey(data: password.data(using: .utf8)!)
        masterKey = HKDF<SHA256>.deriveKey(inputKeyMaterial: inputKeyMaterial, salt: salt, info: Data(), outputByteCount: 32)
    }
    
    func isUnlocked() -> Bool {
        return masterKey != nil
    }
    
    func encrypt(string: String) throws -> Data {
        guard let masterKey = masterKey else { throw NSError(domain: "CryptoHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Vault is locked"]) }
        let data = string.data(using: .utf8)!
        let sealedBox = try AES.GCM.seal(data, using: masterKey)
        return sealedBox.combined!
    }
    
    func decrypt(data: Data) throws -> String {
        guard let masterKey = masterKey else { throw NSError(domain: "CryptoHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Vault is locked"]) }
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: masterKey)
        return String(data: decryptedData, encoding: .utf8)!
    }
}
