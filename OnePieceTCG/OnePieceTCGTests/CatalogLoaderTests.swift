import XCTest
import SwiftData
@testable import OnePieceTCG

final class CatalogLoaderTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = PersistenceController.makeContainer(inMemory: true)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    func testDatasetParsesWithoutError() throws {
        let dataset = try CatalogLoader.loadDataset(resourceName: "OP01", bundle: .main)
        XCTAssertFalse(dataset.cards.isEmpty)
    }

    func testDatasetCardCountMatchesSourceData() throws {
        let dataset = try CatalogLoader.loadDataset(resourceName: "OP01", bundle: .main)
        XCTAssertEqual(dataset.cards.count, 121)
        XCTAssertEqual(dataset.set.code, "OP01")
    }

    func testKnownCardsHaveExpectedFields() throws {
        let dataset = try CatalogLoader.loadDataset(resourceName: "OP01", bundle: .main)
        let cardsByID = Dictionary(uniqueKeysWithValues: dataset.cards.map { ($0.id, $0) })

        let zoro = try XCTUnwrap(cardsByID["OP01-001"])
        XCTAssertEqual(zoro.name, "Roronoa Zoro")
        XCTAssertEqual(zoro.rarity, "L")
        XCTAssertEqual(zoro.type, "Leader")
        XCTAssertEqual(zoro.cost, 5)
        XCTAssertEqual(zoro.power, 5000)

        let luffy = try XCTUnwrap(cardsByID["OP01-003"])
        XCTAssertEqual(luffy.name, "Monkey.D.Luffy")
        XCTAssertEqual(luffy.type, "Leader")
    }

    func testSeedingCatalogInsertsCardsAndSet() throws {
        let insertedCount = try CatalogLoader.seedCatalog(into: context, resourceName: "OP01", bundle: .main)

        XCTAssertEqual(insertedCount, 121)
        let cards = try context.fetch(FetchDescriptor<Card>())
        XCTAssertEqual(cards.count, 121)
        let sets = try context.fetch(FetchDescriptor<CardSet>())
        XCTAssertEqual(sets.map(\.code), ["OP01"])
    }

    func testSeedingCatalogTwiceDoesNotDuplicate() throws {
        try CatalogLoader.seedCatalog(into: context, resourceName: "OP01", bundle: .main)
        let secondRunInsertedCount = try CatalogLoader.seedCatalog(into: context, resourceName: "OP01", bundle: .main)

        XCTAssertEqual(secondRunInsertedCount, 0)
        let cards = try context.fetch(FetchDescriptor<Card>())
        XCTAssertEqual(cards.count, 121)
        let sets = try context.fetch(FetchDescriptor<CardSet>())
        XCTAssertEqual(sets.count, 1)
    }
}
