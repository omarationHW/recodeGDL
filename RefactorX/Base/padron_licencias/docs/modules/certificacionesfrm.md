# Documentación Técnica: Módulo de Certificaciones

## Descripción General
Este módulo permite la gestión de certificaciones de licencias y anuncios, incluyendo:
- Alta de certificaciones
- Modificación
- Cancelación
- Búsqueda avanzada
- Listado e impresión

La arquitectura sigue el patrón eRequest/eResponse con un endpoint único `/api/execute` que recibe la acción y los parámetros. Toda la lógica de negocio relevante se implementa en stored procedures de PostgreSQL.

## Estructura de la Solución

### Backend (Laravel)
- **Controlador:** `CertificacionesController`
- **Endpoint:** `/api/execute` (POST)
- **Acciones soportadas:**
  - `certificaciones.list` — Listado por tipo
  - `certificaciones.create` — Alta
  - `certificaciones.update` — Modificación
  - `certificaciones.cancel` — Cancelación
  - `certificaciones.print` — Datos para impresión
  - `certificaciones.search` — Búsqueda avanzada
  - `certificaciones.listado` — Listado para impresión
- **Validaciones:** Se realizan en el controlador antes de llamar a los SP.
- **Transacciones:** Usadas en operaciones críticas (alta).

### Frontend (Vue.js)
- **Componente:** `CertificacionesPage.vue`
- **Rutas:** Página independiente `/certificaciones`
- **Funcionalidad:**
  - Listado principal
  - Formulario de alta/modificación
  - Cancelación con motivo
  - Impresión (muestra JSON, puede integrarse con PDF)
  - Búsqueda avanzada
- **UX:** No usa tabs, cada formulario es una página completa.

### Base de Datos (PostgreSQL)
- **Stored Procedures:**
  - Listado, alta, modificación, cancelación, búsqueda, impresión
- **Tablas involucradas:**
  - `certificaciones`, `parametros_lic`, `licencias`, `pagos`

### API Unificada
- **Patrón:** eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Formato:**
  ```json
  {
    "action": "certificaciones.create",
    "params": { ... }
  }
  ```

## Seguridad
- El usuario autenticado se utiliza para registrar el capturista.
- Validaciones de entrada en backend y frontend.

## Manejo de Errores
- Errores de validación devuelven HTTP 422.
- Errores de base de datos devuelven HTTP 500.
- Mensajes claros para el usuario final.

## Integración
- El frontend se comunica con el backend usando Axios y el endpoint `/api/execute`.
- Los stored procedures encapsulan la lógica SQL y pueden ser reutilizados por otros módulos.

## Extensibilidad
- Se pueden agregar nuevos tipos de certificaciones o ampliar la lógica de impresión sin romper la API.

# Diagrama de Flujo (Resumen)

1. Usuario accede a la página de certificaciones
2. Se muestra listado (consulta a `/api/execute` con `certificaciones.list`)
3. Usuario puede:
   - Crear nueva certificación (formulario)
   - Modificar una existente
   - Cancelar (con motivo)
   - Imprimir (consulta a `/api/execute` con `certificaciones.print`)
   - Buscar/listar por filtros avanzados

# Notas de Migración
- Los triggers de folio y lógica de folio se migran a stored procedures.
- El concepto de "vigente" se mantiene como campo de estado ('V' = vigente, 'C' = cancelada).
- Los reportes pueden ser implementados como generación de PDF en backend o frontend.

# Pruebas y Validación
- Se recomienda usar Postman para probar el endpoint `/api/execute` con diferentes acciones y parámetros.
- El frontend debe manejar correctamente los estados de carga, error y éxito.
