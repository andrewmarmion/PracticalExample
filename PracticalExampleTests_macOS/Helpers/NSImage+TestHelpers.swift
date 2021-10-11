import Cocoa

extension NSImage {
    static func makeTestImage() -> NSImage? {
        // Ideally I would prefer to create an image programatically but I am
        // unsure how to do that for the Mac
        NSImage(named: "pixel")
    }
}
