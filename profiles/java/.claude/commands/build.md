---
description: Clean build with Maven in batch mode (skips tests for speed)
allowed-tools: Bash(./mvnw*), Bash(mvn*), Bash(chmod*), Read(*), Glob(*)
---

# Java Build Command

Clean and package the project using Maven wrapper in batch mode. Skips tests for faster feedback during development.

## Command

```bash
./mvnw clean package -DskipTests -B
```

## Flags Explained

- `clean`: Remove previous build artifacts
- `package`: Compile, run unit tests (skipped), create JAR/WAR
- `-DskipTests`: Skip test execution (faster builds)
- `-B`: Batch mode (REQUIRED for headless/web environments)

## Process

1. **Verify Maven Wrapper**

   ```bash
   test -x ./mvnw || chmod +x mvnw
   ```

2. **Run Build**

   ```bash
   ./mvnw clean package -DskipTests -B
   ```

3. **Check Build Result**
   - Look for `BUILD SUCCESS` in output
   - JAR file created in `target/` directory

4. **If Build Fails**:
   - Analyze the error output
   - Common issues:
     - Compilation errors (fix syntax)
     - Dependency resolution (check `pom.xml`)
     - Plugin errors (update versions)
   - Fix and re-run

## Build Variants

### Full Build with Tests

```bash
./mvnw clean verify -B
```

### Quick Compile Only

```bash
./mvnw compile -B
```

### Build Specific Module (Multi-Module)

```bash
./mvnw clean package -pl module-name -am -DskipTests -B
```

### Build with Specific Profile

```bash
./mvnw clean package -DskipTests -B -Pproduction
```

## Output Location

After successful build:

```
target/
├── classes/                    # Compiled classes
├── generated-sources/          # Generated code
├── my-app-1.0.0.jar           # Application JAR
├── my-app-1.0.0.jar.original  # Before repackaging
└── maven-status/              # Build metadata
```

## Web Environment Notes

**CRITICAL**: Always use `-B` flag in headless environments:

- Disables interactive prompts
- Reduces verbose output (saves tokens)
- Ensures consistent behavior

```bash
# GOOD - headless compatible
./mvnw clean package -DskipTests -B

# BAD - may hang or flood logs
./mvnw clean package -DskipTests
```

## Troubleshooting

### Maven Wrapper Not Found

```bash
# Generate wrapper
mvn wrapper:wrapper

# Or use system Maven with batch mode
mvn clean package -DskipTests -B
```

### Out of Memory

```bash
export MAVEN_OPTS="-Xmx2048m -XX:MaxMetaspaceSize=512m"
./mvnw clean package -DskipTests -B
```

### Dependency Download Failed

```bash
# Clear cache and retry
rm -rf ~/.m2/repository
./mvnw clean package -DskipTests -B -U
```

### Plugin Version Conflicts

```bash
# Check effective POM
./mvnw help:effective-pom -B | head -200
```
