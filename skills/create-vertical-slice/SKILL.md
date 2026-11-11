---
name: create-vertical-slice
description: Genera un vertical slice completo (Full-Stack) en el monorepo Zenta (NestJS + Angular 21 + Nx), incluyendo tipos en libs/types, rutas compartidas en libs/shared, módulo NestJS con arquitectura de puertos y adaptadores en apps/api y feature Angular 21 standalone con Signals, Zoneless y Tailwind CSS 4 en apps/web.
---

# Zenta Vertical Slice Generator

Usa este workflow cuando el usuario pida agregar una nueva funcionalidad, entidad, módulo o recurso al monorepo (por ejemplo: "Crea la feature de Productos", "Implementa el módulo de Tareas / Kanban", "Genera un vertical slice de Clientes").

---

## Arquitectura y Convenciones del Repositorio

El proyecto es un monorepo Nx con pnpm. Toda nueva funcionalidad debe respetar estrictamente el desacoplamiento entre capas y la arquitectura corporativa de Zenta.

### 1. Capa de Dominio y Contratos (`libs/types/src/lib/`)
En `libs/types/src/lib/auth.types.ts` (o creando un archivo específico exportado en `libs/types/src/index.ts`):
- Definir la entidad con su modelo de datos:
  ```typescript
  export interface <Entity> {
    id: string;
    // campos específicos (ej. name, description, status, etc.)
    createdAt: string;
  }

  export type Create<Entity> = Omit<<Entity>, 'id' | 'createdAt'>;

  export interface <Entity>Page {
    items: <Entity>[];
    total: number;
    page: number;
    pageSize: number;
  }
  ```

### 2. Capa de Rutas Compartidas (`libs/shared/src/lib/routes.ts`)
Actualizar los objetos constantes `APP_ROUTES` y `API_ROUTES`:
- En `APP_ROUTES`: agregar la ruta de navegación (ej. `<ENTITIES>: '/<entities>'`).
- En `API_ROUTES`: agregar la ruta base del endpoint REST (ej. `<ENTITIES>: '/api/v1/zenta/<entities>'`).

### 3. Backend NestJS (`apps/api/src/modules/<feature>/`)
Estructurar el módulo siguiendo el patrón de puertos y adaptadores visto en `modules/generics`:

1. **DTOs (`dto/<feature>.dto.ts`)**:
   - `List<Entity>QueryDto`: con paginación (`page = 1`, `pageSize = 10`) usando decoradores `@Transform` de `class-transformer` y validaciones `@IsInt`, `@Min`, `@Max` de `class-validator`.
   - `Create<Entity>Dto`: validaciones `@IsString`, `@MinLength`, etc.
2. **Puerto del Repositorio (`<feature>.repository.ts`)**:
   - Definir el token de inyección: `export const <ENTITIES>_REPOSITORY = Symbol('<ENTITIES>_REPOSITORY');`
   - Definir la interfaz:
     ```typescript
     export interface <Entity>Repository {
       list(page: number, pageSize: number): Promise<{ items: <Entity>[]; total: number }>;
       create(input: Create<Entity>): Promise<<Entity>>;
     }
     ```
3. **Adaptador In-Memory (`in-memory-<feature>.repository.ts`)**:
   - Clase `@Injectable()` que implemente `<Entity>Repository` usando una estructura en memoria (`Map` o `Array`), para permitir desarrollo local sin dependencias de base de datos externa.
4. **Servicio (`<feature>.service.ts`)**:
   - Inyectar el repositorio mediante `@Inject(<ENTITIES>_REPOSITORY) private readonly repository: <Entity>Repository`.
   - Métodos `list(query)` y `create(dto)`.
5. **Controlador (`<feature>.controller.ts`)**:
   - `@ApiTags('<entities>')` para documentación Swagger.
   - `@Controller('<entities>')` (el prefijo global `/api/v1/zenta` ya lo aplica NestJS en `main.ts`).
   - Métodos `@Get()` y `@Post()`.
6. **Módulo (`<feature>.module.ts`)**:
   ```typescript
   @Module({
     controllers: [<Entities>Controller],
     providers: [
       InMemory<Entity>Repository,
       { provide: <ENTITIES>_REPOSITORY, useExisting: InMemory<Entity>Repository },
       <Entities>Service,
     ],
   })
   export class <Entities>Module {}
   ```
7. **Registro en `apps/api/src/app/app.module.ts`**:
   - Importar `<Entities>Module` en la lista `imports` del módulo raíz.

### 4. Frontend Angular 21 (`apps/web/src/app/features/<feature>/`)
Construir la vista y lógica con las últimas prácticas de Angular 21:

1. **Componente (`<feature>.component.ts`)**:
   - `standalone: true`.
   - `changeDetection: ChangeDetectionStrategy.OnPush`.
   - **Zoneless & Signals**:
     - `readonly records = signal<<Entity>[]>([]);`
     - `readonly loading = signal(true);`
     - `readonly saving = signal(false);`
     - `readonly error = signal<string | null>(null);`
   - Formulario reactivo tipado con `FormGroup` y validadores nativos.
   - Inyección con `inject(HttpClient)`.
   - Consumo de `API_ROUTES.<ENTITIES>` tipado con `<<Entity>Page>`.
2. **Plantilla (`<feature>.component.html`)**:
   - Usar Tailwind CSS 4 con el diseño del template (tarjetas con borde suave, botones con acento Zenta, formulario y tabla/lista responsiva).
   - Manejo de estados de carga (`@if (loading())`), error (`@if (error())`) y lista vacía (`@empty`).
3. **Ruta en `apps/web/src/app/app.routes.ts`**:
   - Agregar como ruta hija bajo `DashboardLayoutComponent` con carga perezosa (`loadComponent`):
     ```typescript
     {
       path: segment(APP_ROUTES.<ENTITIES>),
       loadComponent: () =>
         import('./features/<feature>/<feature>.component').then(
           (m) => m.<Entities>Component,
         ),
     },
     ```
4. **Navegación en el Sidebar (`apps/web/src/app/shared/components/sidebar/sidebar.component.ts`)**:
   - Agregar el item a `readonly navItems` con su `label`, `path: APP_ROUTES.<ENTITIES>` y un ícono SVG descriptivo.

---

## Verificación de Calidad

Una vez generados los archivos, verificar que no existan errores de compilación ni de tipado ejecutando:
```bash
pnpm nx run-many -t lint
```

Reporta al usuario las rutas de los archivos creados y los endpoints disponibles para probar en Swagger (`https://localhost:3000/api/v1/zenta/docs`) y en la aplicación web (`https://localhost:4200/<entities>`).
