---
description: Run tests for a specific Java class using Maven
allowed-tools: Bash(./mvnw*), Bash(mvn*), Bash(chmod*), Read(*), Glob(*), Grep(*)
---

# Test Single Java Class

Run tests for a specific class using Maven Surefire plugin. Takes a class name as argument.

## Usage

Specify the class name when invoking this command:

```
/test-class UserServiceTest
```

## Command Template

```bash
./mvnw -Dtest=$class_name test -B
```

Where `$class_name` is the test class (e.g., `UserServiceTest`, `UserControllerTest`).

## Process

1. **Get Class Name**
   - User provides class name as argument
   - Or search for relevant test class

2. **Find Test Class (if needed)**

   ```bash
   find src/test -name "*Test.java" | head -10
   ```

3. **Run Test**

   ```bash
   ./mvnw -Dtest=ClassName test -B
   ```

4. **Analyze Results**
   - If pass: Report success with test count
   - If fail: Analyze failures and suggest fixes

## Examples

### Run Single Test Class

```bash
./mvnw -Dtest=UserServiceTest test -B
```

### Run Multiple Test Classes

```bash
./mvnw -Dtest=UserServiceTest,OrderServiceTest test -B
```

### Run Single Test Method

```bash
./mvnw -Dtest=UserServiceTest#testCreateUser test -B
```

### Run Tests Matching Pattern

```bash
# All tests in *Service* classes
./mvnw -Dtest="*Service*" test -B

# All tests starting with "testCreate"
./mvnw -Dtest="*#testCreate*" test -B
```

### Run Tests in Specific Package

```bash
./mvnw -Dtest="com.example.service.*Test" test -B
```

## Output Format

Successful run:

```
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

Failed run:

```
[ERROR] Tests run: 5, Failures: 1, Errors: 0, Skipped: 0
[ERROR] UserServiceTest.testCreateUser:45 expected:<Active> but was:<Pending>
```

## Web Environment Notes

**CRITICAL**: Always use `-B` flag:

```bash
# GOOD - batch mode
./mvnw -Dtest=MyTest test -B

# BAD - interactive
./mvnw -Dtest=MyTest test
```

For quieter output:

```bash
./mvnw -Dtest=MyTest test -B -q
```

## Troubleshooting

### Test Class Not Found

```bash
# List all test classes
find src/test -name "*Test.java" -exec basename {} .java \;

# Check class exists
ls src/test/java/com/example/**/UserServiceTest.java
```

### Tests Timing Out

```bash
# Set timeout (seconds)
./mvnw -Dtest=MyTest test -B -Dsurefire.timeout=120
```

### Dependencies Not Resolved

```bash
# Resolve dependencies first
./mvnw dependency:resolve -B && ./mvnw -Dtest=MyTest test -B
```

### Spring Context Fails to Load

```bash
# Run with debug output
./mvnw -Dtest=MyTest test -B -X 2>&1 | grep -A5 "BeanCreationException"
```

## Integration Tests

For integration tests (using Failsafe plugin):

```bash
# Run single integration test
./mvnw -Dit.test=UserControllerIT verify -B

# Skip unit tests, run only integration
./mvnw -DskipTests -Dit.test=UserControllerIT verify -B
```
