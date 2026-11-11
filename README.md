# 🚀 Zenta Developer Kit (`zenta-devkit`)

Plugin integral de desarrollo y buenas prácticas para el monorepo corporativo Zenta (NestJS 11 + Angular 21 + Nx).

Empaqueta de forma unificada **Skills**, **Agentes** y **Hooks de Seguridad** para acelerar el desarrollo full-stack, garantizar la resiliencia del código y proteger credenciales sensibles.

---

## 📦 Componentes Incluidos

### 1. 🧠 Skills
- **`create-vertical-slice`**:
  - Genera vertical slices full-stack completos y desacoplados.
  - Crea contratos tipados en `libs/types`.
  - Registra rutas compartidas en `libs/shared`.
  - Desarrolla módulos backend NestJS con arquitectura de puertos y adaptadores (DTOs validados, Repository Port, Adapter en memoria, Service, Controller).
  - Desarrolla features frontend Angular 21 standalone con Zoneless, Signals, ChangeDetectionStrategy OnPush y Tailwind CSS 4.

### 2. 🤖 Agentes Especializados
- **`zenta-feature-lead`**:
  - **Rol**: Tech Lead Orquestador del monorepo Zenta.
  - **Misión**: Ejecuta el ciclo completo de construcción de features en 3 fases: genera el vertical slice con `create-vertical-slice`, delega inmediatamente la auditoría a `code-review`, y aplica las remediaciones de seguridad antes de verificar con `lint`.
- **`code-review`**:
  - **Rol**: Revisor de Código con Perspectiva Adversarial.
  - **Misión**: Red-teaming de software para código backend y frontend. Detecta over-posting, vulnerabilidades de inyección, referencias compartidas en memoria, condiciones de carrera en Angular Signals y fugas de datos.

### 3. 🛡️ Lifecycle Hooks
- **`protect-secrets`** (`PreToolUse`):
  - Intercepta llamadas a herramientas de archivos (`read_file`, `write_file`, `edit_file`) y ejecución de comandos (`run_command`).
  - Bloquea cualquier intento accidental o malicioso de exponer archivos sensibles como `.env`, `.certs` o `.npmrc`.

---

## 📂 Estructura del Plugin

```text
.agents/plugins/zenta-devkit/
├── plugin.json                    # Manifiesto y metadatos del plugin
├── README.md                      # Documentación de uso
├── hooks.json                     # Declaración de hooks de ciclo de vida
├── hooks/
│   └── protect-secrets.sh         # Script ejecutable de prevención de fuga de credenciales
├── agents/
│   ├── zenta-feature-lead.md      # Agente orquestador Tech Lead
│   └── code-review.md             # Subagente auditor adversarial
└── skills/
    └── create-vertical-slice/
        └── SKILL.md               # Procedimiento y estándares del vertical slice
```

---

## ⚡ Activación y Uso

El plugin es descubierto automáticamente por Antigravity al encontrarse dentro del directorio `.agents/plugins/` del repositorio.

### Ejemplos de Prompts
- `"Usa el agente zenta-feature-lead para implementar la feature de Clientes"`
- `"Revisa adversarialmente los cambios con el agente code-review"`
- `"Crea un vertical slice completo para la gestión de productos"`
