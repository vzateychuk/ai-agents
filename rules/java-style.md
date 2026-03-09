---
description: Java code style — prefer Apache Commons when available
globs: "**/*.java"
alwaysApply: false
---

# Java style

When developing in Java and **Apache Commons** (e.g. `org.apache.commons.lang3.StringUtils`) is available in the project, prefer Commons utilities over manual checks:

- **Blank strings:** use `StringUtils.isBlank(sort)` instead of `sort == null || sort.isBlank()`.
- Prefer other `StringUtils` / `ObjectUtils` helpers where they make the intent clearer and avoid null/edge-case bugs.

Apply this in both main and test code when the dependency is on the classpath.

## Lombok Usage Guidelines

- **Loggers**: Use `@Slf4j` on classes (controllers, services) instead of manual `LoggerFactory`. Call `log.info/debug/warn/error`.
- **DI & constructors**: Prefer `@RequiredArgsConstructor` with `final` fields for dependency injection. Avoid manual constructors and `@Autowired` on constructors.
- **POJO/DTO/entities**:
  - Use `@Getter`/`@Setter` for simple data classes.
  - Use `@Data` when equals/hashCode/toString are needed; be careful in JPA entities (configure `@EqualsAndHashCode` and `@ToString` if necessary, excluding lazy fields).
  - For JPA entities, add `@NoArgsConstructor` (at least protected) for JPA compatibility.
- **MapStruct**: Mappers remain interfaces with `@Mapper(componentModel = "spring")`; Lombok integration is already included (`lombok-mapstruct-binding`).
- **AI/Codegen policy**: When generating new code, always add the corresponding Lombok annotations; do not write manual getters/setters/loggers.