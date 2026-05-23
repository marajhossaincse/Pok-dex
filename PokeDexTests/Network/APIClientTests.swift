import Testing
import Foundation
@testable import PokeDex

@Suite("APIClient")
struct APIClientTests {
    private func makeClient() -> APIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return APIClient(session: URLSession(configuration: config))
    }

    private func makeHTTPResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://pokeapi.co")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    @Test("Decodes valid JSON response into expected DTO")
    func decodesValidResponse() async throws {
        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse(url: URL(string: "https://pokeapi.co")!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
             TestFixtures.pokemonListPage1)
        }

        let result: PokemonListDTO = try await makeClient().request(.pokemonList(limit: 20, offset: 0))

        #expect(result.results.count == 2)
        #expect(result.results[0].name == "bulbasaur")
        #expect(result.next != nil)
    }

    @Test("Throws httpError when server returns 404")
    func throwsOnHTTPError() async {
        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse(url: URL(string: "https://pokeapi.co")!, statusCode: 404, httpVersion: nil, headerFields: nil)!,
             Data())
        }

        do {
            let _: PokemonListDTO = try await makeClient().request(.pokemonList(limit: 20, offset: 0))
            Issue.record("Expected error to be thrown")
        } catch let error as APIError {
            guard case .httpError(let code) = error else {
                Issue.record("Wrong APIError case: \(error)")
                return
            }
            #expect(code == 404)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Throws decodingFailed when response body is malformed JSON")
    func throwsOnInvalidJSON() async {
        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse(url: URL(string: "https://pokeapi.co")!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
             Data("not json".utf8))
        }

        do {
            let _: PokemonListDTO = try await makeClient().request(.pokemonList(limit: 20, offset: 0))
            Issue.record("Expected error to be thrown")
        } catch let error as APIError {
            guard case .decodingFailed = error else {
                Issue.record("Wrong APIError case: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Encodes limit and offset into the request URL")
    func encodesLimitAndOffsetInURL() async throws {
        var capturedURL: URL?
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    TestFixtures.pokemonListPage1)
        }

        let _: PokemonListDTO = try await makeClient().request(.pokemonList(limit: 20, offset: 40))

        let urlString = capturedURL?.absoluteString ?? ""
        #expect(urlString.contains("limit=20"))
        #expect(urlString.contains("offset=40"))
    }
}
