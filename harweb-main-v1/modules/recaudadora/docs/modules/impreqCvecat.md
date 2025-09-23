# Documentación Técnica: Migración Formulario impreqCvecat (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo corresponde a la migración del formulario de impresión y asignación de requerimientos de predial (impreqCvecat) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos). Toda la lógica de negocio y SQL se encapsula en stored procedures y funciones PostgreSQL. La comunicación entre frontend y backend se realiza mediante un endpoint único `/api/execute` usando el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel 10+, controlador `ImpreqCvecatController`.
- **Frontend:** Vue.js 3+, componente de página independiente `ImpreqCvecatPage.vue`.
- **Base de Datos:** PostgreSQL 13+, con stored procedures y funciones para lógica de negocio.
- **API:** Endpoint único `/api/execute` que recibe un objeto `eRequest` con la acción y parámetros, y responde con `eResponse`.

## Flujo de Trabajo
1. El usuario ingresa los parámetros de búsqueda (recaudadora, rango de folios, fecha) y ejecuta la búsqueda.
2. El frontend envía la petición a `/api/execute` con `action: 'listar'` y los parámetros.
3. El backend ejecuta la función correspondiente y retorna los requerimientos encontrados.
4. El usuario puede seleccionar folios y ejecutar acciones de asignación, impresión o generación de reporte PDF.
5. Cada acción se traduce en una llamada a `/api/execute` con el `action` adecuado.

## Seguridad
- Todas las acciones requieren autenticación JWT (Laravel Sanctum/Passport recomendado).
- El usuario autenticado se pasa como parámetro en cada acción que lo requiera.
- Validaciones de entrada y permisos se realizan en el backend.

## Stored Procedures
Toda la lógica de asignación, impresión, cálculo de máximos y listados de ejecutores se implementa en funciones y procedimientos almacenados en PostgreSQL. Esto permite mantener la lógica cerca de los datos y facilita la migración de reglas de negocio.

## API eRequest/eResponse
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listar",
      "params": { "recaud": 1, "folioini": 100, "foliofin": 200, "fecha": "2024-06-01" }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "data": [ ... ]
    }
  }
  ```

## Frontend
- Cada formulario es una página Vue.js independiente, sin tabs.
- El usuario puede navegar entre páginas usando rutas y breadcrumbs.
- El componente maneja loading, errores y muestra los resultados en tablas.
- Acciones como asignar, imprimir y generar reporte PDF se ejecutan sobre los folios seleccionados.

## Consideraciones de Migración
- Los procedimientos almacenados encapsulan toda la lógica de negocio que antes estaba en Delphi.
- El frontend es reactivo y desacoplado, solo consume la API.
- El endpoint único permite fácil integración y mantenimiento.

# Endpoints y Acciones
- `/api/execute` con `action: listar` → Listar requerimientos
- `/api/execute` con `action: filtrar` → Filtrar control de requerimientos
- `/api/execute` con `action: asignar` → Asignar requerimientos a ejecutor
- `/api/execute` con `action: imprimir` → Marcar requerimientos como impresos
- `/api/execute` con `action: ejecutores` → Listar ejecutores disponibles
- `/api/execute` con `action: max_impresiones` → Calcular máximo de impresiones
- `/api/execute` con `action: reporte` → Generar reporte PDF (dummy)

# Validaciones y Errores
- Todos los parámetros son validados en backend.
- Errores se retornan en `eResponse.error`.
- El frontend muestra los errores al usuario.

# Pruebas y Casos de Uso
Ver sección de casos de uso y casos de prueba.
