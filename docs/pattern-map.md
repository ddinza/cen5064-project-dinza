# Creational Pattern Map

1. **Factory Method:** No genuine fit, because the application does not rely on subclasses deciding which single product to instantiate for core workflows.
2. **Abstract Factory:** No genuine fit, because the application does not require creating families of related matching objects (like cross-platform UI components).
3. **Builder:** Genuine home for constructing a complex `Catch` object step-by-step, since a logged catch has required data (species, length) and multiple optional data points (weight, specific tide state, photos).
4. **Prototype:** No genuine fit, because users log unique, individual catches rather than copying a saved example and modifying it.
5. **Singleton:** Genuine home for `CatchManager`, guaranteeing exactly one instance manages `UserDefaults` read/write access for the whole app to prevent data inconsistency[cite: 18].

**Selection:** I am implementing the **Singleton** pattern for `CatchManager`.
