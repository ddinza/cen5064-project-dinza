# HookIt

<!-- CI badge: after Session 4, replace ORG/REPO and the workflow filename, then uncomment:
![CI](https://github.com/ORG/REPO/actions/workflows/ci.yml/badge.svg)
-->

**Student:** Dionny Dinza · **Course:** CEN 5064 Software Design, Fall 2026 · **Partner:** [@lfriera92]

## Project (approval paragraph — write this by Sun Aug 30)

 HookIt is a native iOS application designed for recreational anglers to digitally log their catches while automatically ensuring compliance with local fishing regulations. To maintain a strict scope and clear architectural tiers, the system focuses on four core features: (1) an AI Fish Identification tool—the single permitted external API integration—that analyzes an uploaded photo to identify the species; (2) a Catch Logger where users record their harvest details (species, length, date); (3) a Static Regulations Database built directly into the app containing regional size limits and open seasons, eliminating the need for live weather or tide APIs; and (4) a Compliance Engine (Domain Rule) that automatically cross-references every logged catch against the static database to instantly warn the user if a fish is undersized or out of season.

## How to run

These instructions will run the web application locally. It is designed to work on both Windows and Mac environments.

   **Clone the repository:**
   ```bash
   git clone [https://github.com/ddinza/HookIt.git](https://github.com/ddinza/HookIt.git)
   cd HookIt
   
Create and activate a virtual environment:

Windows:

Bash
python -m venv venv
venv\Scripts\activate
Mac:

Bash
python3 -m venv venv
source venv/bin/activate
Install dependencies:

Bash
pip install -r requirements.txt
Add the API Key:
Create a .env file in the main folder.
(Note for my reviewer: I will message you the temporary GEMINI_API_KEY to paste into this file during review days).

Run the app:

Bash
python app.py
View it:
Open your browser to http://localhost:5000

```

## Architecture

### Tier breakdown (Session 2 studio)

| Tier | Responsibilities in THIS system |Example Classes/Modules|
|------|--------------------------------|----------------------------|
| Presentation | Displays the user interface, shows logged catches, collects input for new catches, and alerts the user of regulation violations. |CatchLogView, AddCatchForm, CameraCaptureView|
| Service | Orchestrates app workflows, such as handling a new catch photo, calling the AI vision integration for identification, requesting a regulation check, and saving the log. |CatchService, IdentificationService|
| Domain | Defines core fishing entities and enforces the main business rule: validating whether a logged catch violates the static size or season limits for that specific species. |Catch, FishSpecies, RegulationValidator|
| Data | Handles the storage and retrieval of user catch history as well as loading the static dataset of fishing regulations. |CatchStore (interface), SwiftDataCatchStore, StaticRegulationStore|

### C4 — Context & Container (Session 3 studio)

```mermaid
%% Replace this placeholder with YOUR system's context diagram.
flowchart TB
    user([User]) -->|uses| system[Your System]
    system -->|stores data in| db[(Database)]
```

```mermaid
%% Container view: your containers should match the tier table above.
flowchart TB
    subgraph YourSystem [Your System]
        ui[Web UI / CLI<br/>Presentation] --> api[Application / Service]
        api --> domain[Domain Model]
        domain --> db[(Database<br/>Data tier)]
    end
```

### UML — Class & Sequence (Session 3 studio)

```mermaid
%% Class diagram: your 3–4 core domain classes.
classDiagram
    class ExampleEntity {
        -id: Long
        -name: String
        +doSomething()
    }
```

```mermaid
%% Sequence diagram: ONE core use case, end to end.
sequenceDiagram
    actor U as User
    participant UI
    participant S as Service
    participant D as Data
    U->>UI: action
    UI->>S: request
    S->>D: save/load
    D-->>S: result
    S-->>UI: response
    UI-->>U: confirmation
```

## Architecture Decision Records

Decisions live in [`docs/adr/`](docs/adr/). Start with ADR-001 in Session 4.

| # | Decision | Status |
|---|----------|--------|
| [001](docs/adr/adr-001.md) | [What I am building and why] | [proposed] |

## Weekly log (optional but recommended)

A one-line note per week keeps your commit story readable:

- Week 1 (Aug 24): repo created, three ideas drafted
- Week 2 (Aug 31): ...
