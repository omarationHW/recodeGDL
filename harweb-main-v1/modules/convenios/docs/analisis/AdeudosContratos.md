# Documentación Técnica - Migración Formulario AdeudosContratos (Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL 13+ (toda la lógica SQL en stored procedures)
- **Patrón de Comunicación:** eRequest/eResponse (payload JSON)

## Flujo de Trabajo
1. **El usuario accede a la página de Listados de Adeudos** (AdeudosContratos) en Vue.js.
2. **Selecciona el tipo de listado** (Todos, Adeudos, Saldos a Favor, Pagos con Descuento, Liquidados) y proporciona los parámetros requeridos (colonia, calle, importe).
3. **Al hacer clic en Ejecutar**, el componente Vue.js envía un POST a `/api/execute` con el eRequest correspondiente.
4. **El controlador Laravel** recibe la petición, identifica la operación y llama al stored procedure adecuado en PostgreSQL.
5. **El resultado** se devuelve en eResponse y se muestra en la tabla de resultados en la página Vue.js.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "operation": "listado_adeudos", // o cualquier otra operación
      "params": { "colonia": 1, "calle": 2 }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "data": [ ... ],
      "error": "..." // si aplica
    }
  }
  ```

## Stored Procedures
- Toda la lógica de consulta y reporte está en stored procedures PostgreSQL.
- Cada operación del formulario corresponde a un SP.
- Los SPs devuelven tablas (RETURNS TABLE) para fácil consumo desde Laravel.

## Seguridad
- Validación de parámetros en el frontend y backend.
- El endpoint puede protegerse con middleware de autenticación Laravel (ej: Sanctum).

## Manejo de Errores
- Los errores de validación y ejecución se devuelven en el campo `error` de eResponse.
- El frontend muestra mensajes claros al usuario.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin cambiar la API.
- Los stored procedures pueden evolucionar sin afectar la interfaz.

## Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.

## Despliegue
- El backend y frontend pueden desplegarse por separado.
- El endpoint `/api/execute` debe estar accesible desde el frontend.

# Parámetros de Entrada por Operación
| Operación                        | Parámetros requeridos           |
|----------------------------------|---------------------------------|
| listado_todos                    | colonia, calle                  |
| listado_adeudos                  | colonia, calle                  |
| listado_saldos_favor             | colonia, calle                  |
| listado_pagos_descuento          | colonia                         |
| listado_liquidados_col_calle     | colonia, calle                  |
| listado_liquidados_col           | colonia, importe                |

# Notas de Migración
- El frontend NO usa tabs ni componentes tabulares: cada formulario es una página.
- El endpoint es único y flexible.
- Los reportes pueden exportarse a Excel desde el frontend si se requiere.

# Casos de Uso
Ver sección `use_cases`.

# Casos de Prueba
Ver sección `test_cases`.
