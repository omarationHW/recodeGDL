# Documentación Técnica: Migración Formulario CMultFolio (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+, PostgreSQL 13+
- **Frontend:** Vue.js 3 SPA (Single Page Application)
- **API:** Endpoint único `/api/execute` con patrón eRequest/eResponse
- **Base de datos:** PostgreSQL, lógica de negocio en stored procedures

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list_recaudadoras|search_folios|folio_detail|individual_detail",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "folios": [...],
      "detail": {...},
      ...
    }
  }
  ```

## 3. Controlador Laravel
- **Método principal:** `execute(Request $request)`
- **Acciones soportadas:**
  - `list_recaudadoras`: Lista todas las recaudadoras
  - `search_folios`: Busca folios por módulo, zona y folio inicial (devuelve hasta 100 consecutivos)
  - `folio_detail`: Devuelve el detalle de un folio por id_control
  - `individual_detail`: Devuelve el detalle extendido de un folio (para vista individual)
- **Validación:** Se usa Validator de Laravel para validar los parámetros de entrada.
- **Llamada a SP:** Se usan funciones PostgreSQL para encapsular la lógica SQL.

## 4. Componente Vue.js
- **Página independiente:** `/cmultfolio`
- **Funcionalidad:**
  - Selección de aplicación (Mercados, Aseo, etc.)
  - Selección de recaudadora
  - Ingreso de folio
  - Búsqueda de folios (muestra tabla)
  - Visualización de detalle individual
- **UX:**
  - Breadcrumb de navegación
  - Mensajes de error/carga
  - Tabla responsive

## 5. Stored Procedures PostgreSQL
- **sp_cmultfolio_search:** Busca folios por módulo, zona y folio inicial
- **sp_cmultfolio_detail:** Devuelve detalle de folio por id_control
- **sp_cmultfolio_individual:** Devuelve detalle extendido para vista individual

## 6. Seguridad
- **Autenticación:** Se recomienda JWT o Laravel Sanctum para proteger el endpoint
- **Validación:** Todos los parámetros son validados en backend
- **SQL Injection:** Uso de parámetros en las llamadas a SP

## 7. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones de otros formularios
- Los SP pueden ser versionados y optimizados sin afectar la API

## 8. Pruebas
- Se recomienda usar Postman para pruebas de API
- El frontend puede ser probado con Cypress o Jest

## 9. Despliegue
- **Backend:** Docker o servidor Linux con PHP 8+
- **Frontend:** Docker/nginx o Vercel/Netlify
- **DB:** PostgreSQL 13+ (con los SP instalados)

## 10. Mantenimiento
- Los SP deben ser documentados y versionados
- El controlador Laravel debe ser modular para facilitar el mantenimiento

