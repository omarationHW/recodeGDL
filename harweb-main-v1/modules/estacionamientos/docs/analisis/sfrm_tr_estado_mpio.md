# Documentación Técnica: Migración Formulario sfrm_tr_estado_mpio

## 1. Descripción General
Este módulo implementa la migración del formulario Delphi `sfrm_tr_estado_mpio` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es permitir la transferencia de datos de multas de estacionómetros del Estado al Municipio, incluyendo la carga de archivos y la visualización de remesas procesadas.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Parámetros:**
  - `eRequest`: Identificador de la acción a ejecutar.
  - `eParams`: Parámetros adicionales (opcional, tipo objeto).
  - Para carga de archivos, enviar como `multipart/form-data` con campo `archivo`.
- **Respuesta:**
  - `success`: true/false
  - `data`: datos de respuesta
  - `message`: mensaje de error o éxito

### eRequest soportados
- `get_remesas_estado_mpio`: Devuelve las últimas 5 remesas procesadas.
- `upload_archivo_estado_mpio`: Sube y procesa un archivo de datos.
- `procesar_delesta01`: Ejecuta una operación especial sobre los datos (ejemplo: eliminar registro).

## 4. Stored Procedures
- **sp_get_remesas_estado_mpio:** Consulta las últimas 5 remesas distintas.
- **sp_insert_folios_estado_mpio:** Carga datos desde un archivo CSV a la tabla principal.
- **spd_delesta01:** Procesa operaciones especiales (ejemplo: eliminar registro).

## 5. Frontend (Vue.js)
- Página independiente con formulario de carga de archivo y tabla de remesas.
- Al subir archivo, se refresca la tabla automáticamente.
- Mensajes de éxito/error visibles al usuario.

## 6. Seguridad
- Validación de archivos y parámetros en backend.
- El endpoint `/api/execute` debe protegerse con autenticación (no incluido aquí por simplicidad).

## 7. Consideraciones de Migración
- El proceso de carga de archivo asume formato CSV compatible con la estructura de la tabla.
- El proceso de stored procedure puede adaptarse según reglas de negocio específicas.

## 8. Extensibilidad
- Para agregar nuevas acciones, basta con implementar el eRequest correspondiente en el controlador y/o nuevos stored procedures.

## 9. Errores y Logs
- Todos los errores se registran en el log de Laravel.
- El frontend muestra mensajes claros al usuario.

## 10. Pruebas
- Casos de uso y pruebas detalladas en secciones siguientes.
