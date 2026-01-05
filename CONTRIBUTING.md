# Contributing to Ethiopian Exit Exam Prep

Thank you for considering contributing to this project! This document provides guidelines for contributing.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on what is best for the community
- Show empathy towards others

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- Clear and descriptive title
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable
- Device and OS information
- App version

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- Clear and descriptive title
- Detailed description of the proposed functionality
- Why this enhancement would be useful
- Possible implementation approach

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Make your changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation as needed
4. **Test your changes**
   ```bash
   flutter analyze
   flutter test
   flutter build apk --debug
   ```
5. **Commit your changes**
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
6. **Push to the branch**
   ```bash
   git push origin feature/AmazingFeature
   ```
7. **Open a Pull Request**

### Coding Standards

#### Dart/Flutter
- Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for issues
- Prefer `const` constructors when possible
- Use single quotes for strings
- Maximum line length: 80 characters (flexible)
- Document public APIs

#### Python (Flask Server)
- Follow [PEP 8](https://pep8.org/)
- Use type hints where appropriate
- Document functions with docstrings
- Maximum line length: 88 characters (Black formatter)

#### File Organization
```
lib/
├── models/         # Data models
├── services/       # Business logic
├── repositories/   # Data layer (if needed)
├── screens/        # UI screens
├── widgets/        # Reusable widgets
└── utils/          # Helper functions
```

#### Naming Conventions
- Classes: `PascalCase`
- Files: `snake_case.dart`
- Variables/Functions: `camelCase`
- Constants: `camelCase` or `UPPER_CASE`
- Private members: `_leadingUnderscore`

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat(auth): add password reset functionality

fix(upload): handle large file uploads correctly

docs(readme): update installation instructions

refactor(services): simplify file service logic
```

### Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Test on multiple devices/emulators
- Verify both Android and iOS (if applicable)
- Test offline functionality
- Test different user roles

### Documentation

Update documentation for:
- New features
- Changed behavior
- API changes
- Configuration changes
- Security considerations

Files to update:
- `README.md` - User-facing documentation
- `REQUIREMENTS.md` - Specification updates
- `CHANGELOG.md` - Track changes
- Code comments - Explain complex logic
- `SECURITY.md` - Security implications
- `DEPLOYMENT.md` - Deployment changes

### Security

- Never commit credentials or secrets
- Use environment variables for configuration
- Follow OWASP guidelines
- Report security issues privately
- Keep dependencies updated

### Development Workflow

1. **Setup**
   ```bash
   git clone <your-fork>
   cd exit--2
   flutter pub get
   ```

2. **Create Branch**
   ```bash
   git checkout -b feature/my-feature
   ```

3. **Develop**
   - Make changes
   - Test frequently
   - Commit often with good messages

4. **Before PR**
   ```bash
   flutter analyze
   flutter test
   flutter format .
   ```

5. **Submit PR**
   - Reference related issues
   - Describe changes
   - Include screenshots for UI changes
   - Request review

### Review Process

- All PRs require review before merging
- Address reviewer feedback promptly
- Keep PRs focused and reasonably sized
- Update PR based on feedback
- Squash commits before merge if requested

### Getting Help

- Create an issue for questions
- Join discussions
- Review existing documentation
- Check closed issues for similar problems

## Project Structure

```
exit--2/
├── android/           # Android native code
├── lib/              # Flutter application
│   ├── models/       # Data models
│   ├── services/     # Business logic
│   ├── screens/      # UI screens
│   ├── widgets/      # Reusable widgets
│   └── main.dart     # Entry point
├── server/           # Flask backend
├── docs/             # Additional documentation
└── test/             # Tests
```

## Recognition

Contributors will be acknowledged in:
- CONTRIBUTORS.md file
- Release notes
- Project README

Thank you for contributing! 🎉

---

For questions or clarifications, please create an issue or reach out to maintainers.
