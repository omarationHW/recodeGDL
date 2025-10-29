# Documentación Técnica - Migración SGCV2 Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8.1+), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón de integración**: eRequest/eResponse (entrada/salida JSON), desacoplando lógica de UI y backend.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ "eRequest": { "action": "nombre_accion", "params": { ... } } }`
- **Salida**: `{ "eResponse": { ... } }`
- **Acciones soportadas**: buscarCuenta, login, cambiarClave, consultarPropietarios, guardarPropietario, consultarLiquidacion, autorizarTransmision, consultarHorarioUsuario, consultarVersion, etc.

## Controlador Laravel
- Centraliza la lógica de ruteo de acciones.
- Cada acción mapea a un método privado.
- Validación de parámetros y errores centralizada.
- Uso de DB::select/insert/update para acceso a datos y ejecución de stored procedures.

## Componentes Vue.js
- Cada formulario es una página Vue independiente.
- No se usan tabs ni componentes tabulares.
- Navegación mediante breadcrumbs.
- Uso de Axios para consumir `/api/execute`.
- Manejo de errores y estados de carga.

## Stored Procedures PostgreSQL
- Toda la lógica de negocio y reportes se implementa como funciones SQL.
- CRUD y procesos complejos (autorizaciones, validaciones, etc) se encapsulan en funciones.
- Uso de tipos de retorno TABLE para reportes y consultas.
- Uso de transacciones y manejo de errores en funciones de proceso.

## Seguridad
- Autenticación por usuario/clave (hash bcrypt).
- Validación de sesión/token recomendada (no incluida en este ejemplo).
- Validación de parámetros en backend y frontend.

## Migración de Datos
- Tablas Delphi/Paradox deben migrarse a PostgreSQL con los mismos nombres y campos equivalentes.
- Se recomienda usar herramientas de ETL o scripts de migración.

## Pruebas y QA
- Casos de uso y pruebas unitarias para cada acción principal.
- Validación de integridad de datos y lógica de negocio.

## Extensibilidad
- Para agregar nuevas acciones, implementar el método en el controlador y el stored procedure correspondiente.
- El frontend puede agregar nuevas páginas Vue para cada formulario/proceso.

## Ejemplo de llamada API
```json
{
  "eRequest": {
    "action": "buscarCuenta",
    "params": {
      "recaud": 1,
      "urbrus": "U",
      "cuenta": 12345
    }
  }
}
```

## Ejemplo de respuesta
```json
{
  "eResponse": {
    "cuenta": {
      "cvecuenta": 123,
      "recaud": 1,
      "urbrus": "U",
      "cuenta": 12345,
      "claveutm": "1-U-12345",
      ...
    }
  }
}
```

## Notas
- Todos los formularios Delphi tienen su equivalente como página Vue.
- Los reportes y procesos complejos se implementan como stored procedures.
- El endpoint único simplifica la integración y el mantenimiento.
