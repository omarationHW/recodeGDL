# Documentación Técnica: Migración de Formulario Ubicodifica (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario "Ubicodifica" del sistema Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad de consulta, alta, actualización, cancelación y listado de codificaciones de ubicación catastral, centralizando la lógica de negocio en stored procedures y exponiendo la funcionalidad a través de un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3, componente de página independiente, sin tabs.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse (un solo endpoint, acción y parámetros).

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  - `action`: Nombre de la acción (string)
  - `params`: Objeto de parámetros
- **Response:**
  - JSON con datos o error

### Acciones soportadas
- `get_ubicodifica_data`: Consulta datos de cuenta y codificación
- `alta_ubicodifica`: Alta de codificación
- `actualiza_ubicodifica`: Actualiza/reactiva codificación
- `cancela_ubicodifica`: Cancela codificación
- `listado_ubicodifica`: Listado de cuentas sin zona/subzona

## 4. Stored Procedures
Toda la lógica de negocio y reportes se implementa en funciones/stored procedures PostgreSQL, asegurando atomicidad y portabilidad. Los procedimientos están documentados en la sección correspondiente.

## 5. Seguridad
- Autenticación JWT (Laravel Sanctum o Passport recomendado)
- Validación de parámetros en backend
- Control de acceso por usuario en los procedimientos de alta/actualización/cancelación

## 6. Frontend (Vue.js)
- Página independiente para Ubicodifica
- Formulario para búsqueda y gestión de codificación
- Acciones de alta, actualización, cancelación
- Listado de cuentas sin zona/subzona
- Manejo de estados y mensajes de error
- No se usan tabs ni componentes tabulares; cada formulario es una página

## 7. Integración
- El frontend se comunica exclusivamente con `/api/execute` usando eRequest/eResponse
- El backend enruta la acción al procedimiento correspondiente
- Los stored procedures devuelven datos en formato tabular o de éxito/error

## 8. Migración de Lógica Delphi
- Los métodos y eventos Delphi se migran a métodos del controlador y stored procedures
- La lógica de habilitación/deshabilitación de botones se traslada a la lógica de estado en Vue.js
- Los reportes se migran a consultas SQL y pueden ser exportados desde el frontend si se requiere

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la migración

## 10. Consideraciones
- El endpoint `/api/execute` puede ser extendido para otras acciones del sistema
- Se recomienda versionar los stored procedures y documentar cambios
- El frontend puede ser extendido para incluir breadcrumbs y navegación contextual
