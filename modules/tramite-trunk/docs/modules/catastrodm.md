# Documentación Técnica - Migración CatastroDM Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL 13+, lógica de negocio crítica en stored procedures.
- **Patrón API**: eRequest/eResponse, todas las operaciones pasan por `/api/execute`.

## API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ eRequest: { action: string, params: object } }`
- **Salida**: `{ eResponse: { success: bool, data: any, message: string, errors: array } }`
- **Acciones soportadas**: CRUD, procesos, reportes, ejecución de SPs, etc.

## Ejemplo de llamada
```js
POST /api/execute
{
  "eRequest": {
    "action": "getCatastroByCuenta",
    "params": { "cvecuenta": 12345 }
  }
}
```

## Seguridad
- Autenticación JWT o Laravel Sanctum.
- Validación de usuario en cada request.
- Validación de parámetros en backend.

## Frontend (Vue.js)
- Cada formulario es una página Vue independiente.
- Navegación SPA, breadcrumbs para contexto.
- Uso de Axios para llamadas a `/api/execute`.
- Componentes modales para acciones como exentar o modificar propietario.
- Manejo de loading, error y success states.

## Backend (Laravel)
- Controlador centralizado (`CatastroController`) con método `execute`.
- Validación de parámetros con Laravel Validator.
- Llamadas a stored procedures vía DB::select/DB::statement.
- Logging de errores y auditoría.

## Stored Procedures
- Toda la lógica de negocio crítica (exentar, recalcular, etc.) se implementa como SP en PostgreSQL.
- CRUD simples pueden ser funciones SQL.
- SPs deben ser idempotentes y seguros.

## Migración de lógica Delphi
- Cada método/procedimiento relevante se mapea a un SP o endpoint.
- Los eventos de UI (AfterPost, OnChange, etc.) se traducen a acciones de frontend o triggers de backend.
- Los cálculos de campos se implementan en SP o en el frontend según corresponda.

## Pruebas y QA
- Casos de uso y pruebas automatizadas para cada flujo crítico.
- Validación de integridad de datos antes/después de cada operación.

## Consideraciones
- No usar tabs en frontend, cada formulario es una página.
- Navegación clara y breadcrumbs.
- API desacoplada, frontend y backend pueden evolucionar por separado.

