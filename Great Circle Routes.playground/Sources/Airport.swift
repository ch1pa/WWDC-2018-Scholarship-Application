import Foundation

// Airport structure serves as the object containing relevent airport information.

public class Airport {
    public let code: String
    public let coordinates: String
    public let name: String
    public let country: String
    public init(code: String, coordinates: String, name: String, country: String) {
        self.code = code;
        self.coordinates = coordinates
        self.name = name
        self.country = country
    }
}
