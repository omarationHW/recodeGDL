# Documentación Técnica: Migración de consultaLicenciafrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), PostgreSQL 13+, API RESTful
- **Frontend**: Vue.js 3 SPA (Single Page Application)
- **Base de datos**: PostgreSQL, lógica de negocio crítica en stored procedures
- **API Unificada**: Un solo endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`
- **Patrón de integración**: El frontend nunca accede directamente a la base de datos, siempre a través del endpoint Laravel

## API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ eRequest: { operation: string, params: object } }`
- **Salida**: `{ eResponse: { result: any, error: string|null } }`
- **Operaciones soportadas**:
  - `search_by_licencia`: Búsqueda por número de licencia
  - `search_by_ubicacion`: Búsqueda por ubicación
  - `search_by_contribuyente`: Búsqueda por nombre de propietario
  - `search_by_tramite`: Búsqueda por número de trámite
  - `get_adeudos`: Consulta de adeudos de licencia
  - `get_pagos`: Consulta de pagos de licencia
  - `bloquear_licencia`: Bloqueo de licencia
  - `desbloquear_licencia`: Desbloqueo de licencia
  - `exportar_excel`: Exportación de resultados a Excel

## Backend (Laravel)
- **Controlador**: `ConsultaLicenciaController`
- **Método principal**: `execute(Request $request)`
- **Lógica**: Cada operación del frontend se mapea a una función SQL o stored procedure. El controlador valida la operación, ejecuta la consulta/procedimiento y retorna el resultado o error.
- **Seguridad**: Se recomienda agregar autenticación JWT y validación de permisos por usuario.

## Frontend (Vue.js)
- **Componente**: `ConsultaLicenciaPage.vue`
- **Estructura**: Página completa, sin tabs. Cada formulario es una página independiente.
- **Flujo**:
  - El usuario llena uno de los criterios de búsqueda y presiona el botón correspondiente.
  - Se hace una llamada a `/api/execute` con la operación y parámetros.
  - Los resultados se muestran en una tabla. Cada fila tiene acciones para ver detalle, pagos, adeudos, bloquear/desbloquear, exportar.
  - Los detalles, pagos y adeudos se muestran en secciones independientes.
- **UX**: Mensajes de carga, error, y confirmación. Navegación breadcrumb.

## Stored Procedures
- Toda la lógica de negocio SQL se implementa en stored procedures para garantizar atomicidad y portabilidad.
- Los procedimientos deben ser idempotentes y seguros ante SQL Injection (usar parámetros).
- Los procedimientos de bloqueo/desbloqueo deben registrar bitácora de usuario y fecha.

## Exportación a Excel
- El backend puede generar el archivo y devolver una URL temporal para descarga, o devolver los datos en base64 para descarga directa.

## Seguridad y Validaciones
- Validar que los parámetros requeridos estén presentes antes de ejecutar cualquier operación.
- Validar que el usuario tenga permisos para bloquear/desbloquear/exportar.
- Manejar errores de base de datos y devolver mensajes claros al frontend.

## Pruebas y Casos de Uso
- Se deben cubrir búsquedas, bloqueos, desbloqueos, exportación y visualización de pagos/adeudos.
- Los casos de prueba deben incluir escenarios de error y edge cases.

## Migración de Datos
- Se recomienda migrar los datos de licencias, bloqueos, pagos, etc. a PostgreSQL usando scripts ETL o herramientas como pgloader.

## Notas
- El frontend debe ser desacoplado y reutilizable para otros módulos de consulta.
- El endpoint `/api/execute` puede ser extendido para otras operaciones futuras.
