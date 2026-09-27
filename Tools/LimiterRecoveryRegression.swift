import CoreAudio
import Foundation

@main enum LimiterRecoveryRegression {
    static func main() {
        let rate = 48000.0
        let release = BoostLimiter.release(sampleRate: rate)
        var failures = 0
        func check(_ condition: Bool, _ message: String) {
            print("\(condition ? "PASS" : "FAIL"): \(message)")
            if !condition { failures += 1 }
        }
        for sampleRate in [44100.0, 48000.0, 96000.0] {
            let release = BoostLimiter.release(sampleRate: sampleRate)
            let count = Int(sampleRate * 2)
            // A full-scale boosted peak followed by still-hot, quieter audio.
            let input: [Float] = [Float](repeating: 2, count: 1024) + [Float](repeating: 1.05, count: count)
            var interleaved = input
            let limiter = BoostLookaheadLimiter(channels: 1)
            interleaved.withUnsafeMutableBufferPointer {
                _ = limiter.process($0.baseAddress!, frames: $0.count, channels: 1, release: release)
            }
            check(interleaved.last! > 0.93, "interleaved recovers after peak at \(sampleRate) Hz")
            check(interleaved.allSatisfy { $0.isFinite && abs($0) <= BoostLimiter.ceiling + 0.0001 }, "interleaved stays within ceiling")
            var left = input
            var right = input.map { $0 * 0.5 }
            let list = AudioBufferList.allocate(maximumBuffers: 2)
            defer { free(list.unsafeMutablePointer) }
            left.withUnsafeMutableBufferPointer { l in
                right.withUnsafeMutableBufferPointer { r in
                    list[0] = AudioBuffer(mNumberChannels: 1, mDataByteSize: UInt32(l.count * 4), mData: l.baseAddress)
                    list[1] = AudioBuffer(mNumberChannels: 1, mDataByteSize: UInt32(r.count * 4), mData: r.baseAddress)
                    let limiter = BoostLookaheadBufferListLimiter(channelCapacity: 2)
                    check(limiter.process(list, frames: l.count, release: release), "planar buffer layout accepted")
                }
            }
            check(left.last! > 0.93, "planar recovers after peak at \(sampleRate) Hz")
            check(zip(left, right).allSatisfy { abs($0 * 0.5 - $1) < 0.00001 }, "stereo image remains linked")
            check(left.allSatisfy { $0.isFinite && abs($0) <= BoostLimiter.ceiling + 0.0001 }, "planar stays within ceiling")
        }
        var silence = [Float](repeating: 0, count: 2048)
        silence.withUnsafeMutableBufferPointer {
            _ = BoostLookaheadLimiter(channels: 1).process($0.baseAddress!, frames: $0.count, channels: 1, release: release)
        }
        check(silence.allSatisfy { $0 == 0 }, "silence stays silent")
        exit(failures == 0 ? 0 : 1)
    }
}
