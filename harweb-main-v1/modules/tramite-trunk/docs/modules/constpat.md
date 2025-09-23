# Documentación Técnica: Migración Formulario constpat (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "eRequest": "nombre_operacion",
    "params": { ... }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true|false,
    "data": [ ... ] | { ... },
    "error": "mensaje de error" | null
  }
  ```

### eRequest soportados:
- `consultarTransmisionPorFolio` (params: { folio })
- `consultarTransmisionesPorFechas` (params: { desde, hasta })
- `contarFoliosPorFechas` (params: { desde, hasta })
- `consultarTransmisionesTotalesPorFecha` (params: { desde, hasta })

## 3. Stored Procedures
- Toda la lógica de consulta se implementa como funciones SQL en PostgreSQL.
- El controlador Laravel ejecuta los SP vía `DB::select`.

## 4. Vue.js
- Página independiente para el formulario constpat.
- Dos secciones principales:
  - Consulta por folio
  - Consulta por rango de fechas (detalle y totales por día)
- Navegación breadcrumb incluida.
- Manejo de errores y validaciones en frontend.

## 5. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej: Sanctum, JWT) en producción.
- Validar y sanear los parámetros recibidos antes de ejecutar los SP.

## 6. Pruebas
- Casos de uso y escenarios de prueba incluidos para QA y UAT.

## 7. Consideraciones
- El frontend espera los datos en el mismo formato que los SP retornan.
- El backend es responsable de mapear errores de BD a mensajes legibles.
- El endpoint es extensible para otros formularios/futuros eRequest.
