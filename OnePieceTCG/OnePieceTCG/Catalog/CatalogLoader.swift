import Foundation
import SwiftData

/// Decodable shape of the bundled catalog JSON (see `OP01.json`).
struct CatalogCardDTO: Decodable {
    let id: String
    let name: String
    let cardNumber: String
    let rarity: String
    let cost: Int?
    let power: Int?
    let attribute: String?
    let type: String?
    let imageURL: String?
}

struct CatalogSetDTO: Decodable {
    let code: String
    let name: String
}

struct CatalogDataset: Decodable {
    let set: CatalogSetDTO
    let cards: [CatalogCardDTO]
}

enum CatalogLoaderError: Error {
    case resourceNotFound(String)
}

/// Parses a bundled catalog JSON resource and seeds the local `Card`/`CardSet`
/// catalog. Seeding is idempotent: cards already present (matched by `id`)
/// are left untouched, so running it again never creates duplicates.
enum CatalogLoader {
    static func loadDataset(resourceName: String, bundle: Bundle) throws -> CatalogDataset {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw CatalogLoaderError.resourceNotFound(resourceName)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(CatalogDataset.self, from: data)
    }

    @discardableResult
    static func seedCatalog(
        into context: ModelContext,
        resourceName: String = "OP01",
        bundle: Bundle = .main
    ) throws -> Int {
        let dataset = try loadDataset(resourceName: resourceName, bundle: bundle)

        let existingSetCodes = Set(try context.fetch(FetchDescriptor<CardSet>()).map(\.code))
        if !existingSetCodes.contains(dataset.set.code) {
            context.insert(CardSet(code: dataset.set.code, name: dataset.set.name))
        }

        let existingCardIDs = Set(try context.fetch(FetchDescriptor<Card>()).map(\.id))
        let newCards = dataset.cards.filter { !existingCardIDs.contains($0.id) }
        for dto in newCards {
            context.insert(
                Card(
                    id: dto.id,
                    name: dto.name,
                    setCode: dataset.set.code,
                    cardNumber: dto.cardNumber,
                    rarity: dto.rarity,
                    cost: dto.cost,
                    power: dto.power,
                    attribute: dto.attribute,
                    type: dto.type,
                    imageURL: dto.imageURL
                )
            )
        }

        if !newCards.isEmpty || !existingSetCodes.contains(dataset.set.code) {
            try context.save()
        }
        return newCards.count
    }
}
