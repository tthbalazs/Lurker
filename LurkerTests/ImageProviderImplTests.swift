//
@testable import Lurker

import XCTest

final class ImageProviderImplTests: XCTestCase {
    func testReturnsNoImageForNonExsistentURL() async {
        let sut = ImageProviderImpl()
        let url = URL(string: "https://foo")!
        
        let result = await sut.loadImage(for: url)
        XCTAssertNil(result)
    }
    
    func testReturnsImageForExistingURL() async {
        let url = URL(string: "https://foo")!
        let expected = UIImage(systemName: "photo")!
        
        let sut = ImageProviderImpl(cache: [
            url: expected
        ])
        
        let got = await sut.loadImage(for: url)
        XCTAssertEqual(expected, got)
    }
    
    func testReturnsImageFromDataLoader() async {
        let url = URL(string: "https://foo")!
        let expected = UIImage(systemName: "photo")!
        
        let sut = ImageProviderImpl(
            cache: [
                url: expected
            ],
            dataLoader: { url in
                return (expected.pngData()!, URLResponse())
            }
        )
        
        let got = await sut.loadImage(for: url)
        XCTAssertEqual(expected, got)
    }
}
