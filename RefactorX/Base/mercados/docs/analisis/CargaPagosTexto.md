# Documentación Técnica: Carga de Pagos Texto (Delphi → Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo permite importar pagos realizados en el Mercado Libertad a partir de un archivo de texto plano con formato fijo. El proceso incluye:
- Previsualización del archivo y parsing de registros.
- Importación masiva de pagos a la tabla `ta_11_pagos_local`.
- Eliminación automática de adeudos pagados (`ta_11_adeudo_local`).
- Resumen de la importación (pagos grabados, ya existentes, adeudos borrados, importe total).

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js de página completa, sin tabs, con carga de archivo, previsualización y resumen.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedure `sp_importar_pago_texto`.

## Flujo de Trabajo
1. **Carga de Archivo:** El usuario selecciona un archivo `.txt` y lo sube (base64).
2. **Previsualización:** El backend parsea el archivo y devuelve los registros para revisión.
3. **Importación:** El usuario confirma e importa los pagos. Cada registro se procesa vía stored procedure.
4. **Resumen:** Se muestra el resultado de la importación (grabados, ya grabados, adeudos borrados, importe total).

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Métodos:** POST
- **Body:**
  ```json
  {
    "action": "preview_pagos_texto|importar_pagos_texto|resumen_importacion_pagos_texto",
    "payload": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "message": "...",
    "data": { ... }
  }
  ```

## Formato del Archivo de Texto
Cada línea representa un pago, con posiciones fijas:
- Id Local: 1-6
- Año: 7-10
- Periodo: 11-12
- Fecha Pago: 13-20 (DDMMYYYY)
- Oficina: 21-23
- Caja: 24
- Operación: 25-29
- Importe: 30-38
- Folio: 39-44
- Fecha Actualización: 45-63
- Id Usuario: 64-66
- Rec: 67-69
- Merc: 70-72

## Validaciones
- El archivo debe ser texto plano, codificado en base64.
- Cada línea debe tener al menos 72 caracteres.
- El importe debe ser numérico.
- No se permite importar pagos duplicados (mismo id_local, año, periodo).

## Seguridad
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí).
- El id de usuario del sistema se toma de `auth()->id()`.

## Errores y Manejo de Transacciones
- Toda la importación se realiza en una transacción.
- Si ocurre un error, se hace rollback y se informa al usuario.

## Extensibilidad
- El endpoint puede extenderse para otros formularios de carga masiva.
- El stored procedure puede adaptarse para lógica adicional (validaciones, logs, etc).

## Frontend
- Página Vue.js independiente.
- Permite cargar archivo, previsualizar, importar y ver resumen.
- Mensajes de error y éxito claros.

## Backend
- Controlador Laravel con métodos para cada acción.
- Uso de stored procedure para lógica de importación.

## Base de Datos
- Stored procedure en PostgreSQL para encapsular la lógica de inserción y borrado.

# Esquema de Tablas Relacionadas
- `ta_11_pagos_local`: Pagos realizados.
- `ta_11_adeudo_local`: Adeudos pendientes.

# Seguridad y Auditoría
- El id de usuario que realiza la importación queda registrado en los pagos.
- Se recomienda auditar los logs de importación para trazabilidad.

# Pruebas y Validación
- Casos de uso y pruebas incluidas para asegurar la robustez del proceso.
