# Contributing Guidelines: Smart Student Planner

Thank you for contributing to the **Smart Student Planner** academic project!

---

## 1. Code Style & Standards

- Adhere to the official [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.
- Use strong typing: avoid `dynamic` where explicit types (`Task`, `int`, `String`) can be declared.
- Keep widgets modular and reusable under `lib/widgets/`.
- Ensure all SQLite queries in `DatabaseHelper` use parameterized arguments (`?` placeholders) to prevent SQL injection.

---

## 2. Commit Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` A new feature for the user or module.
- `fix:` A bug fix.
- `docs:` Documentation changes only.
- `test:` Adding or updating tests.
- `refactor:` Code change that neither fixes a bug nor adds a feature.
- `chore:` Changes to the build process, dependencies, or configuration.

**Example**:
```text
feat(tasks): add priority filter chips to tasks screen
fix(timetable): validate that end time is later than start time
```

---

## 3. Pull Request & Verification Checklist

Before submitting changes:
1. Run `flutter analyze` to verify zero warnings or lint errors.
2. Run `flutter test` to ensure all automated unit and widget tests pass.
3. Verify that changes maintain 100% offline functionality without external API calls.

