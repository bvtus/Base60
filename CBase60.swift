import Foundation


//Base60 Encoding
public enum CBase60 {

    private static let alphabet: [UInt8] =
        Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZIOabcdefghijkmnopqrstuvwxyz".utf8)

    private static let base = 60

    private static let decodeTable: [Int8] = {
        var table = Array(repeating: Int8(-1), count: 128)
        for i in 0..<alphabet.count {
            table[Int(alphabet[i])] = Int8(i)
        }
        return table
    }()

    // MARK: - Encode
    public static func encode(_ data: Data) -> String {
        let length = data.count
        if length == 0 {
            return "1"   // 和 OC 一样
        }

        var digits = Array(repeating: 0, count: length * 2)
        var digitCount = 0

        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            let input = ptr.bindMemory(to: UInt8.self)
            for b in 0..<length {
                var carry = Int(input[b])
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
        }

        if digitCount == 0 {
            return "1"
        }

        var out = [UInt8]()
        out.reserveCapacity(digitCount)
        for i in stride(from: digitCount - 1, through: 0, by: -1) {
            out.append(alphabet[digits[i]])
        }

        return String(bytes: out, encoding: .ascii)!
    }

    // MARK: - Decode
    public static func decode(_ string: String) -> Data? {
        let chars = Array(string.utf8)
        let length = chars.count
        if length == 0 {
            return Data()
        }

        var bytes = Array(repeating: UInt8(0), count: length)
        var byteCount = 0

        for ch in chars {
            if ch >= 128 { return nil }
            let v = Int(decodeTable[Int(ch)])
            if v < 0 { return nil }

            var carry = v
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

        var result = Data(capacity: byteCount)
        for i in stride(from: byteCount - 1, through: 0, by: -1) {
            result.append(bytes[i])
        }
        return result
    }
    
}
