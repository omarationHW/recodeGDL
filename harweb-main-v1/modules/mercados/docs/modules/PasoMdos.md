# Documentación Técnica: Migración PasoMdos (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite migrar los registros de la tabla `cobrotrimestral` (Tianguis) a la tabla de padrón de locales (`ta_11_locales`) en el contexto del Mercado de Abastos (num_mercado=214). La migración verifica si el local ya existe en el padrón antes de insertarlo. El proceso está expuesto como una API RESTful unificada y una interfaz Vue.js.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js de página completa, sin tabs, con tabla de datos y acciones
- **Base de Datos:** PostgreSQL, lógica de inserción en stored procedure
- **Seguridad:** Se recomienda proteger el endpoint con autenticación JWT o similar

## Flujo de Datos
1. El usuario accede a la página de migración y carga los datos de Tianguis.
2. El usuario ejecuta la migración, que llama al endpoint `/api/execute` con acción `migrar_tianguis_a_padron`.
3. El backend recorre los registros, verifica existencia en padrón y llama al stored procedure para insertar los nuevos.
4. Se retorna un resumen de errores y registros existentes.

## API
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `action`: string (ej: 'get_tianguis', 'migrar_tianguis_a_padron')
  - `data`: objeto (parámetros adicionales)
- **Salida:**
  - `status`: 'success' | 'error'
  - `message`: string
  - `data`: objeto (según acción)

## Stored Procedure
- **sp_insert_tianguis_padron**: Inserta un registro de Tianguis en el padrón de locales.
- **Validación de existencia**: Se realiza en el controlador antes de llamar al SP.

## Frontend
- Página Vue.js con tabla de Tianguis y botón para migrar.
- Muestra resultado de la migración (errores, existentes).
- No usa tabs ni componentes tabulares.

## Consideraciones
- El proceso es idempotente: no inserta duplicados.
- El usuario debe tener permisos para ejecutar la migración.
- El SP puede ser extendido para registrar logs de auditoría.

## Seguridad
- Se recomienda proteger el endpoint con autenticación y autorización.
- Validar los datos de entrada en el backend.

## Extensibilidad
- El endpoint puede ser extendido para otras acciones relacionadas con el padrón.
- El frontend puede mostrar más detalles o permitir filtros adicionales.
