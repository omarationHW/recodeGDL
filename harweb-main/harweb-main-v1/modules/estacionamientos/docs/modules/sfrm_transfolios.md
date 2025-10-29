# Documentación Técnica: Migración de Formulario sfrm_transfolios (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` que recibe eRequest y responde con eResponse.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## 2. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: JSON `{ eRequest: { action, data, usuario_id, ejercicio } }`
- **Salida**: JSON `{ eResponse: { status, message, results } }`
- **Acciones soportadas**:
  - `altas_folios`: Altas de multas de estacionómetros
  - `bajas_folios`: Bajas de multas de estacionómetros
  - `altas_calcomanias`: Altas de calcomanías sin propietario

## 3. Stored Procedures
- Toda la lógica de inserción/actualización se realiza en funciones PostgreSQL:
  - `sp_altas_folios`: Inserta registros en `ta14_folios_adeudo`.
  - `sp_bajas_folios`: Actualiza estado de folios a baja en `ta14_folios_adeudo`.
  - `sp_altas_calcomanias`: Inserta registros en `ta14_calco`.

## 4. Frontend (Vue.js)
- Permite seleccionar el tipo de operación (altas/bajas/calcomanías).
- Permite cargar archivo TXT, parsea y muestra vista previa.
- Permite enviar los datos procesados al backend.
- Muestra resultados de la operación (OK/error por registro).

## 5. Backend (Laravel)
- Controlador `ExecuteController` procesa la petición según el campo `action`.
- Por cada registro, llama al stored procedure correspondiente y recopila el resultado.
- Devuelve un array de resultados por registro.

## 6. Seguridad
- El usuario y ejercicio deben ser validados/autenticados en producción.
- Validar que los archivos cargados sean de texto y el formato esperado.

## 7. Manejo de Errores
- Si ocurre un error en la base de datos, el resultado por registro será `error` y se incluirá el mensaje.
- Si la acción no es soportada, se devuelve error 400.

## 8. Consideraciones de Migración
- El procesamiento de archivos y parsing de líneas se realiza en el frontend.
- El backend solo recibe datos ya estructurados.
- Los nombres de campos y lógica de negocio se adaptaron a la estructura PostgreSQL.

## 9. Extensibilidad
- Para agregar nuevas operaciones, crear un nuevo stored procedure y agregar el case correspondiente en el controlador.

## 10. Pruebas
- Se recomienda probar con archivos de ejemplo y validar los resultados en la base de datos.
