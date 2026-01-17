# Java / Spring Boot Development Profile

> **Language Profile**: Java 17+ with Maven/Gradle, Spring Boot, JUnit 5

This profile provides Claude Code with Java-specific conventions, commands, and skills optimized for both CLI and web environments.

## Critical Web Rules

**IMPORTANT**: When running in Claude Code Web (headless/ephemeral environment), you MUST follow these rules to prevent hanging or log flooding:

### Batch Mode for Maven (MANDATORY)

```bash
# ALWAYS use -B flag for batch mode
./mvnw clean install -B        # GOOD
./mvnw test -B                  # GOOD
mvn compile -B                  # GOOD

# NEVER use Maven without -B in headless
mvn clean install               # BAD - may prompt for input
./mvnw test                     # BAD - verbose interactive output
```

The `-B` (batch) flag:

- Disables interactive input
- Reduces log verbosity
- Prevents color codes that waste tokens
- Makes output machine-readable

### No Daemon for Gradle (MANDATORY)

```bash
# ALWAYS use --no-daemon for headless
./gradlew build --no-daemon -q  # GOOD
gradle test --no-daemon         # GOOD

# NEVER leave daemon running in ephemeral environment
./gradlew build                 # BAD - starts daemon that may hang
```

The `--no-daemon` flag:

- Prevents background process that outlives session
- Avoids port conflicts on restart
- Ensures clean exit

### Quiet Mode for Log Reduction

```bash
# Maven quiet mode
./mvnw test -B -q              # Minimal output

# Gradle quiet mode
./gradlew test --no-daemon -q  # Minimal output

# Show only errors and summary
./mvnw test -B 2>&1 | grep -E "(BUILD|Tests run|FAILURE|ERROR)"
```

## Project Structure

Standard Maven/Gradle project layout:

```
my-project/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/
│   │   │       ├── Application.java
│   │   │       ├── controller/
│   │   │       ├── service/
│   │   │       ├── repository/
│   │   │       └── model/
│   │   └── resources/
│   │       ├── application.yml
│   │       └── static/
│   └── test/
│       └── java/
│           └── com/example/
│               └── *Test.java
├── pom.xml                    # Maven
├── build.gradle               # Gradle (alternative)
├── mvnw / mvnw.cmd            # Maven wrapper
├── gradlew / gradlew.bat      # Gradle wrapper
├── .claude/
│   ├── settings.json
│   ├── commands/
│   └── skills/
└── CLAUDE.md
```

## Build / Run / Test Commands

### Maven Commands

```bash
# Clean and build (skip tests for speed)
./mvnw clean package -DskipTests -B

# Build with tests
./mvnw clean verify -B

# Run tests only
./mvnw test -B

# Run single test class
./mvnw -Dtest=UserServiceTest test -B

# Run single test method
./mvnw -Dtest=UserServiceTest#testCreateUser test -B

# Run Spring Boot application
./mvnw spring-boot:run -B

# Check dependencies
./mvnw dependency:tree -B

# Update dependencies
./mvnw versions:display-dependency-updates -B
```

### Gradle Commands

```bash
# Build (skip tests)
./gradlew build -x test --no-daemon -q

# Build with tests
./gradlew build --no-daemon

# Run tests only
./gradlew test --no-daemon

# Run single test class
./gradlew test --tests "UserServiceTest" --no-daemon

# Run Spring Boot application
./gradlew bootRun --no-daemon

# Check dependencies
./gradlew dependencies --no-daemon
```

## Slash Commands

This profile includes the following commands:

| Command       | Description                          |
| ------------- | ------------------------------------ |
| `/build`      | Clean build with Maven (skips tests) |
| `/test-class` | Run tests for a specific class       |

## Skills

| Skill         | Description                                 |
| ------------- | ------------------------------------------- |
| `create-test` | Analyze a class and scaffold a JUnit 5 test |

## Code Conventions

### Package Structure

```
com.example.myapp/
├── MyAppApplication.java      # Main class
├── config/                    # Configuration classes
├── controller/                # REST controllers
├── service/                   # Business logic
├── repository/                # Data access
├── model/                     # Domain models / entities
├── dto/                       # Data transfer objects
└── exception/                 # Custom exceptions
```

### Controller Pattern

```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
        return userService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<UserDto> createUser(@Valid @RequestBody CreateUserRequest request) {
        UserDto created = userService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
}
```

### Service Pattern

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    public Optional<UserDto> findById(Long id) {
        return userRepository.findById(id)
            .map(this::toDto);
    }

    @Transactional
    public UserDto create(CreateUserRequest request) {
        User user = new User();
        user.setName(request.name());
        user.setEmail(request.email());
        return toDto(userRepository.save(user));
    }

    private UserDto toDto(User user) {
        return new UserDto(user.getId(), user.getName(), user.getEmail());
    }
}
```

### Repository Pattern

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    @Query("SELECT u FROM User u WHERE u.status = :status")
    List<User> findByStatus(@Param("status") UserStatus status);
}
```

## Testing Conventions

### JUnit 5 Test Structure

```java
@SpringBootTest
class UserServiceTest {

    @Autowired
    private UserService userService;

    @MockBean
    private UserRepository userRepository;

    @Test
    @DisplayName("findById returns user when exists")
    void findById_WhenUserExists_ReturnsUser() {
        // Given
        User user = new User(1L, "Test User", "test@example.com");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        // When
        Optional<UserDto> result = userService.findById(1L);

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().name()).isEqualTo("Test User");
    }

    @Test
    @DisplayName("findById returns empty when user not found")
    void findById_WhenUserNotFound_ReturnsEmpty() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        // When
        Optional<UserDto> result = userService.findById(1L);

        // Then
        assertThat(result).isEmpty();
    }
}
```

### Integration Test

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
class UserControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void createUser_WithValidInput_ReturnsCreated() throws Exception {
        CreateUserRequest request = new CreateUserRequest("Test", "test@example.com");

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("Test"));
    }
}
```

### Test Naming Convention

```java
// Method pattern: methodName_condition_expectedResult
void findById_WhenUserExists_ReturnsUser()
void create_WithInvalidEmail_ThrowsValidationException()
void delete_WhenNotFound_ThrowsNotFoundException()
```

## Dependency Management

### pom.xml Best Practices

```xml
<properties>
    <java.version>17</java.version>
    <spring-boot.version>3.2.0</spring-boot.version>
</properties>

<dependencies>
    <!-- Spring Boot Starters -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>

    <!-- Test Dependencies -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## GitHub Actions Integration

This profile includes a GitHub Action workflow (`.github/workflows/claude-java.yml`) for automated CI with Claude Code in headless mode using Temurin JDK 17.

## Troubleshooting

### Maven Wrapper Not Executable

```bash
chmod +x mvnw
```

### Tests Hanging

```bash
# Add timeout
./mvnw test -B -Dsurefire.timeout=60
```

### Memory Issues

```bash
# Increase heap
export MAVEN_OPTS="-Xmx1024m"
./mvnw test -B
```

### Port Already in Use

```bash
# Find and kill process
lsof -i :8080 | awk 'NR>1 {print $2}' | xargs kill -9

# Or use different port
./mvnw spring-boot:run -Dspring-boot.run.arguments=--server.port=8081 -B
```

## Usage

To use this profile:

1. Copy the contents of `profiles/java/` to your project root
2. Adjust `CLAUDE.md` for your specific project
3. Ensure Maven wrapper is present (`mvnw`, `mvnw.cmd`)
4. Run `/build` to verify setup

```bash
# From the claude-code repo
cp -r profiles/java/* /path/to/your/project/
```
