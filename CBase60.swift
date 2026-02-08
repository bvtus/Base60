import Foundation


//Base60编码
public enum CBase60 {

    // MARK: - Alphabet
    private static let alphabet = Array(
        "123456789ABCDEFGHJKLMNPQRSTUVWXYZIOabcdefghijkmnopqrstuvwxyz"
    )

    private static let base = 60

    // Decode lookup table (ASCII 0–127)
    private static let decodeTable: [Int8] = {
        var table = Array(repeating: Int8(-1), count: 128)
        for (i, c) in alphabet.enumerated() {
            let v = Int8(i)
            let ascii = Int(c.asciiValue!)
            table[ascii] = v
        }
        return table
    }()

    // MARK: - Encode (Data → Base60 String)
    public static func encode(_ data: Data) -> String {
        guard !data.isEmpty else { return "" }

        var digits = [Int](repeating: 0, count: data.count * 2)
        var digitCount = 1

        for byte in data {
            var carry = Int(byte)
            var i = 0
            while i < digitCount {
                carry += digits[i] << 8
                digits[i] = carry % base
                carry /= base
                i += 1
            }
            while carry > 0 {
                digits[digitCount] = carry % base
                digitCount += 1
                carry /= base
            }
        }
        
        // Preserve leading zeros
        var result = ""
        for byte in data where byte == 0 {
            result.append(alphabet[0])
        }

        // Convert digits to characters
        for i in stride(from: digitCount - 1, through: 0, by: -1) {
            result.append(alphabet[digits[i]])
        }

        return result
    }

    // MARK: - Decode (Base60 String → Data)
    public static func decode(_ string: String) -> Data? {
        guard !string.isEmpty else { return Data() }

        var bytes = [UInt8](repeating: 0, count: string.count)
        var byteCount = 1

        for c in string {
            guard let ascii = c.asciiValue, ascii < 128 else { return nil }
            let value = Int(decodeTable[Int(ascii)])
            if value < 0 { return nil }

            var carry = value
            var i = 0
            while i < byteCount {
                carry += Int(bytes[i]) * base
                bytes[i] = UInt8(carry & 0xff)
                carry >>= 8
                i += 1
            }
            while carry > 0 {
                bytes[byteCount] = UInt8(carry & 0xff)
                byteCount += 1
                carry >>= 8
            }
        }
        var result = Data()
        result.reserveCapacity(byteCount)

        for i in stride(from: byteCount - 1, through: 0, by: -1) {
            result.append(bytes[i])
        }
        return result
    }
    
    
}
