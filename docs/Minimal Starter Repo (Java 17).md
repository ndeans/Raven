# Minimal Starter Repo: Java 17

This repository provides a clean, production-ready starting point for new Java projects. It is designed to be lightweight while including the essential "Day 1" requirements for enterprise-grade development: logging and testing.

## Overview

The **starter-java** project is a Maven-based scaffold targeting **Java 17 (LTS)**. It eliminates the boilerplate of initial setup, allowing developers to jump straight into business logic.

## Key Features

### 1. Centralized Logging
- **Framework**: SLF4J with Logback backend.
- **Configuration**: Pre-configured `logback.xml` including a timestamped, colorized console appender.
- **Usage**: Standard SLF4J `Logger` pattern implemented in the `App.java` entry point.

### 2. Unit Testing Suite
- **Framework**: JUnit Jupiter (JUnit 5).
- **Configuration**: Integrated via `maven-surefire-plugin`.
- **Placeholder**: Includes `AppTest.java` to verify that the testing infrastructure is functional out of the box.

### 3. Build & Dependency Management
- **Maven**: Standard directory structure.
- **Java 17**: Configured via `maven.compiler.release` in `pom.xml` for strict compliance with the Java 17 LTS baseline.

## Project Structure

```text
starter-java/
├── pom.xml              # Maven configuration with SLF4J, Logback, and JUnit
├── .gitignore           # Standard Java/Maven ignore rules
├── README.md            # Usage instructions
└── src
    ├── main
    │   ├── java         # Source code (Target package: us.deans.example)
    │   └── resources    # Configuration (logback.xml)
    └── test
        └── java         # Test suites (JUnit 5)
```

## Quick Start

### Build
```bash
mvn compile
```

### Test
```bash
mvn test
```

### Run
```bash
mvn exec:java -Dexec.mainClass="us.deans.example.App"
```
