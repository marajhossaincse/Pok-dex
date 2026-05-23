# Pokédex iOS App

A native iOS app built with SwiftUI that lets you browse and explore Pokémon using the free [PokéAPI](https://pokeapi.co). This project was built as a portfolio piece with a strong emphasis on clean architecture, maintainability, and testability.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
- [Folder Structure](#folder-structure)
- [Layer Breakdown](#layer-breakdown)
  - [Core](#core)
  - [Domain](#domain)
  - [Data](#data)
  - [Presentation](#presentation)
- [Dependency Flow](#dependency-flow)
- [Unit Testing Architecture](#unit-testing-architecture)
  - [Testing Philosophy](#testing-philosophy)
  - [Test Folder Structure](#test-folder-structure)
  - [Mocking Strategy](#mocking-strategy)
  - [Test Suite Breakdown](#test-suite-breakdown)
- [Getting Started](#getting-started)

---

## Features

- Browse a paginated list of all Pokémon (1,302+)
- Infinite scroll with automatic load-more as you reach the end of the list
- Error handling with a retry mechanism
- Loading states during initial fetch and pagination
- Navigate to an individual Pokémon detail screen

---

## Tech Stack

| Concern | Choice |
|---|---|
| UI | SwiftUI |
| Networking | URLSession (no third-party libraries) |
| Concurrency | Swift async/await |
| Architecture | Clean MVVM |
| Testing | Swift Testing (`@Test` macro) |
| Dependencies | None — built entirely from scratch |

- **Minimum iOS version:** 16.2
- **Swift version:** 6

---

## Architecture Overview

The app follows a **Clean MVVM** pattern, separating concerns into four distinct layers. Each layer has a strict rule about what it is allowed to know about:

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│              (SwiftUI Views + ViewModels)                │
│        Knows about: Domain models and protocols          │
└────────────────────────┬────────────────────────────────┘
                         │ depends on (protocol only)
┌────────────────────────▼────────────────────────────────┐
│                     Domain Layer                         │
│             (Models + Repository Protocols)              │
│        Knows about: Nothing outside this layer           │
└────────────────────────┬────────────────────────────────┘
                         │ implements
┌────────────────────────▼────────────────────────────────┐
│                      Data Layer                          │
│          (DTOs + Mappers + Repository Impls)             │
│        Knows about: Domain protocols + Core              │
└────────────────────────┬────────────────────────────────┘
                         │ depends on
┌────────────────────────▼────────────────────────────────┐
│                      Core Layer                          │
│           (APIClient + APIEndpoint + APIError)           │
│        Knows about: URLSession and Foundation            │
└─────────────────────────────────────────────────────────┘
```

The key design principle is that **dependencies only point downward**. The Presentation layer never touches DTOs or URLSession. The Domain layer is pure Swift with no framework imports — it could be extracted into its own Swift Package without any changes.

---

## Folder Structure

```
Pok-dex/
│
├── PokeDex/                          # Main app target
│   ├── PokeDexApp.swift              # App entry point (@main)
│   │
│   ├── Core/
│   │   └── Network/
│   │       ├── APIClient.swift       # Protocol + URLSession implementation
│   │       ├── APIEndpoint.swift     # Enum of all API endpoints
│   │       └── APIError.swift        # Typed network error enum
│   │
│   ├── Domain/
│   │   ├── Models/
│   │   │   └── PokemonModel.swift    # Clean domain models (no API coupling)
│   │   └── Repositories/
│   │       └── PokemonRepositoryProtocol.swift  # Repository contract
│   │
│   ├── Data/
│   │   ├── DTOs/
│   │   │   └── PokemonListDTO.swift  # Raw API response structs (Decodable)
│   │   ├── Mappers/
│   │   │   └── PokemonMapper.swift   # Translates DTOs into domain models
│   │   └── Repositories/
│   │       └── PokemonRepository.swift  # Implements the protocol, calls APIClient
│   │
│   └── Presentation/
│       ├── Home/
│       │   ├── HomeView.swift        # SwiftUI list view + row view
│       │   └── HomeViewModel.swift   # Pagination state machine (@MainActor)
│       └── PokemonDetail/
│           └── PokemonDetailView.swift  # Detail screen (expandable)
│
└── PokeDexTests/                     # Unit test target
    ├── Helpers/
    │   ├── MockURLProtocol.swift     # Intercepts URLSession at the protocol level
    │   └── TestFixtures.swift        # Shared JSON data and model factory helpers
    ├── Mocks/
    │   ├── MockAPIClient.swift       # Fake APIClient for repository tests
    │   └── MockPokemonRepository.swift  # Fake repository for ViewModel tests
    ├── Network/
    │   └── APIClientTests.swift      # Tests real APIClient with a fake URLSession
    ├── Mappers/
    │   └── PokemonMapperTests.swift  # Tests DTO-to-model mapping logic
    ├── Repositories/
    │   └── PokemonRepositoryTests.swift  # Tests repository using MockAPIClient
    └── ViewModels/
        └── HomeViewModelTests.swift  # Tests all ViewModel state using MockRepository
```

---

## Layer Breakdown

### Core

**Location:** `PokeDex/Core/Network/`

This layer is the only place in the app where network communication happens. It is intentionally small and generic — it knows nothing about Pokémon.

**`APIError.swift`**
A typed `enum` conforming to `LocalizedError` that describes every failure mode in the network stack:
- `invalidURL` — the endpoint could not construct a valid URL
- `invalidResponse` — the server did not return an HTTP response
- `httpError(statusCode: Int)` — the server returned a non-2xx status code
- `decodingFailed(Error)` — `JSONDecoder` could not parse the response body
- `unknown(Error)` — any other unexpected failure

**`APIEndpoint.swift`**
An `enum` that acts as a catalog of every API endpoint the app can call. Each case carries its parameters and knows how to build its own `URL`. Adding a new API call means adding a new case here — nothing else changes.

```swift
enum APIEndpoint {
    case pokemonList(limit: Int, offset: Int)
    case pokemonDetail(name: String)
}
```

**`APIClient.swift`**
Defines `APIClientProtocol` with a single generic method:

```swift
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}
```

`APIClient` is the real implementation. It takes a `URLSession` in its initialiser (defaulting to `.shared`), which is the hook used by tests to inject a fake session. It validates the HTTP status code and delegates decoding to `JSONDecoder`.

---

### Domain

**Location:** `PokeDex/Domain/`

This is the heart of the app. It contains no `import Foundation`, no `import SwiftUI` — just plain Swift types. This layer defines **what** the app works with and **what it needs**, without caring about **how** those needs are fulfilled.

**`PokemonModel.swift`**
The clean domain representation of a Pokémon. Notice it has an `id` (extracted from the API URL), not just a raw URL string that the rest of the app has to parse.

```swift
struct PokemonModel: Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
}

struct PokemonListModel {
    let pokemons: [PokemonModel]
    let hasMore: Bool   // true when more pages are available
}
```

**`PokemonRepositoryProtocol.swift`**
The contract that the Presentation layer programs against. The ViewModel only ever sees this protocol — it has no idea whether data comes from the network, a local cache, or a mock.

```swift
protocol PokemonRepositoryProtocol {
    func fetchPokemons(limit: Int, offset: Int) async throws -> PokemonListModel
}
```

---

### Data

**Location:** `PokeDex/Data/`

This layer bridges the network and the domain. It knows about both the raw API format (DTOs) and the clean domain models. Its job is to translate between the two.

**`PokemonListDTO.swift`** (DTOs folder)
Data Transfer Objects — structs that directly mirror the JSON structure returned by the API. They exist solely to be decoded from JSON. The rest of the app never sees these.

```swift
struct PokemonListDTO: Decodable {
    let count: Int
    let next: String?       // URL of the next page, nil on the last page
    let previous: String?
    let results: [PokemonDTO]
}
```

**`PokemonMapper.swift`** (Mappers folder)
A stateless `enum` (used as a namespace) with static functions that convert DTOs into domain models. This is where the ID extraction logic lives — the URL `".../pokemon/1/"` becomes the string `"1"`.

```swift
// Input:  PokemonListDTO  (raw API shape)
// Output: PokemonListModel (clean domain shape)
PokemonMapper.toDomain(_ dto: PokemonListDTO) -> PokemonListModel
```

**`PokemonRepository.swift`** (Repositories folder)
The concrete implementation of `PokemonRepositoryProtocol`. It receives an `APIClientProtocol` via its initialiser, calls the right endpoint, and pipes the DTO through the mapper.

```swift
final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient: APIClientProtocol
    // ...
    func fetchPokemons(limit: Int, offset: Int) async throws -> PokemonListModel {
        let dto: PokemonListDTO = try await apiClient.request(.pokemonList(...))
        return PokemonMapper.toDomain(dto)
    }
}
```

---

### Presentation

**Location:** `PokeDex/Presentation/`

Each screen gets its own folder containing a `View` and a `ViewModel`. Views are passive — they render state and forward user actions. All logic lives in the ViewModel.

**`HomeViewModel.swift`**
Marked `@MainActor` so all published state changes happen on the main thread automatically. It manages the pagination state machine:

| Property | Purpose |
|---|---|
| `pokemons` | The accumulated list across all loaded pages |
| `isLoading` | True during the initial page fetch |
| `isLoadingMore` | True while fetching a subsequent page |
| `errorMessage` | Set when a fetch fails, cleared on retry |

`loadInitial()` resets all state and fetches page one. `loadMore()` is guarded — it does nothing if there is no next page or a fetch is already in progress.

**`HomeView.swift`**
Marked `@MainActor` (required in Swift 6 to initialise a `@MainActor` ViewModel from a stored property). Triggers `loadMore()` using `.onAppear` on the last visible row — a simple, dependency-free approach to infinite scroll.

---

## Dependency Flow

This diagram shows exactly what each layer depends on, and which specific types are swapped out in tests:

```
Production                          Tests
─────────────────────────────────────────────────────────────
HomeView
  └── HomeViewModel                 HomeViewModel
        └── PokemonRepositoryProtocol ◄──── MockPokemonRepository
              └── PokemonRepository
                    └── APIClientProtocol ◄──── MockAPIClient
                          └── APIClient
                                └── URLSession ◄──── URLSession(MockURLProtocol)
```

Each arrow is an injection point. In production the real types flow through. In tests, any layer can be replaced with a fake that returns controlled data, without changing any other layer.

---

## Unit Testing Architecture

### Testing Philosophy

Tests are written using **Swift Testing** (`@Test`, `#expect`, `Issue.record`), available from Xcode 16 / Swift 6. Every test is:

- **Isolated** — no shared mutable state between tests
- **Deterministic** — no real network calls; all responses are controlled
- **Focused** — each test verifies exactly one behaviour

Tests are structured to mirror the app's layers. Each layer is tested in isolation using a fake for the layer below it.

---

### Test Folder Structure

```
PokeDexTests/
├── Helpers/          # Infrastructure shared across all tests
├── Mocks/            # Fake implementations of app protocols
├── Network/          # Tests for APIClient
├── Mappers/          # Tests for PokemonMapper
├── Repositories/     # Tests for PokemonRepository
└── ViewModels/       # Tests for HomeViewModel
```

---

### Mocking Strategy

There are three distinct mocking techniques used, each appropriate for a different layer:

#### 1. `MockURLProtocol` — faking the network at the lowest level

Used in: `APIClientTests`

`URLSession` supports custom `URLProtocol` subclasses that intercept every request before it hits the network. `MockURLProtocol` registers a static handler closure that each test sets up to return whatever response it needs.

```swift
// In the test:
MockURLProtocol.requestHandler = { _ in
    let response = HTTPURLResponse(url: ..., statusCode: 200, ...)
    return (response, someJSONData)
}

// In MockURLProtocol:
override func startLoading() {
    let (response, data) = try handler(request)
    client?.urlProtocol(self, didReceive: response, ...)
    client?.urlProtocol(self, didLoad: data)
    client?.urlProtocolDidFinishLoading(self)
}
```

A dedicated `URLSession` is created for each test using `URLSessionConfiguration.ephemeral` with `MockURLProtocol` registered as its protocol class. This means the real `APIClient` code runs — only the network transport is replaced.

#### 2. `MockAPIClient` — faking the HTTP client for repository tests

Used in: `PokemonRepositoryTests`

`MockAPIClient` implements `APIClientProtocol` and exposes a `responseProvider` closure. Each test sets this closure to return whatever DTO it needs (or throw an error). This lets repository tests verify mapping logic without any networking code involved.

```swift
final class MockAPIClient: APIClientProtocol {
    var responseProvider: ((APIEndpoint) throws -> Any) = { _ in fatalError(...) }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let result = try responseProvider(endpoint)
        guard let typed = result as? T else { throw APIError.decodingFailed(...) }
        return typed
    }
}
```

#### 3. `MockPokemonRepository` — faking the data layer for ViewModel tests

Used in: `HomeViewModelTests`

`MockPokemonRepository` implements `PokemonRepositoryProtocol` and exposes two properties: `result` (the domain model to return) and `errorToThrow` (an error to simulate failure). It also records call counts and parameters so tests can assert that the ViewModel called the repository correctly.

```swift
final class MockPokemonRepository: PokemonRepositoryProtocol {
    var result: PokemonListModel = ...
    var errorToThrow: Error?
    private(set) var fetchCallCount = 0
    private(set) var lastFetchOffset: Int?
    private(set) var lastFetchLimit: Int?
}
```

#### `TestFixtures` — shared test data factory

`TestFixtures` is a namespace enum that provides:
- Pre-built `Data` blobs of valid and edge-case JSON (for `APIClientTests`)
- Factory functions like `makePokemonModel(id:name:)` and `makeListModel(hasMore:)` to build domain models in one line (for `RepositoryTests` and `ViewModelTests`)

---

### Test Suite Breakdown

#### `APIClientTests` (4 tests)
Tests the real `APIClient` implementation with a fake `URLSession`.

| Test | What it verifies |
|---|---|
| `decodesValidResponse` | A 200 response with valid JSON is decoded into the expected DTO |
| `throwsOnHTTPError` | A 404 response throws `APIError.httpError(statusCode: 404)` |
| `throwsOnInvalidJSON` | A 200 response with malformed JSON throws `APIError.decodingFailed` |
| `encodesLimitAndOffsetInURL` | The constructed URL contains the correct query parameters |

#### `PokemonMapperTests` (4 tests)
Tests pure mapping logic with no dependencies.

| Test | What it verifies |
|---|---|
| `extractsIDFromURL` | The numeric ID is correctly parsed from the API URL path |
| `hasMoreTrueWhenNextPresent` | `hasMore` is `true` when the `next` field is a non-nil string |
| `hasMoreFalseWhenNextNil` | `hasMore` is `false` when `next` is `null` |
| `mapsAllResultsInOrder` | All results are mapped and their order is preserved |

#### `PokemonRepositoryTests` (3 tests)
Tests the repository's mapping and error-forwarding behaviour using `MockAPIClient`.

| Test | What it verifies |
|---|---|
| `returnsMappedDomainModel` | The DTO returned by the client is correctly transformed into a domain model |
| `hasMoreFalseWhenNoNextURL` | `hasMore` propagates correctly from the DTO to the domain model |
| `propagatesAPIErrors` | Errors thrown by the API client pass through the repository unchanged |

#### `HomeViewModelTests` (8 tests)
Tests the ViewModel's state machine using `MockPokemonRepository`. The entire suite is `@MainActor` to match the ViewModel's actor isolation.

| Test | What it verifies |
|---|---|
| `loadInitialSuccess` | A successful fetch populates `pokemons` and clears loading/error state |
| `loadInitialFailure` | A failed fetch sets `errorMessage` and leaves `pokemons` empty |
| `loadMoreAppends` | A second fetch appends to — rather than replaces — the existing list |
| `loadMoreSkipsWhenNoMore` | `loadMore()` is a no-op when the last page has been reached |
| `loadInitialPassesCorrectPagination` | `loadInitial` always sends `offset: 0` with the configured page size |
| `loadMoreIncrementsOffset` | `loadMore` sends an offset equal to the number of already-loaded items |
| `loadInitialResetsExistingList` | Calling `loadInitial` again completely replaces the previous list |
| `loadMoreErrorPreservesExistingList` | A pagination error does not wipe the items already displayed |

---

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd Pok-dex
   ```

2. **Open in Xcode**
   ```bash
   open PokeDex.xcodeproj
   ```

3. **Run the app**
   Select an iPhone simulator and press `Cmd + R`.

4. **Run the tests**
   Press `Cmd + U` to run the full test suite. All 19 tests should pass with no network activity.

> No package dependencies need to be fetched. The project builds and tests with zero configuration.
