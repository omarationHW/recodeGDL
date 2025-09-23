# Documentación Técnica: Migración de Formulario sfrm_up_pagos (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite la actualización masiva de pagos en el sistema a partir de un archivo de texto plano. El usuario selecciona un archivo, el sistema procesa cada línea, extrae los datos necesarios y actualiza la tabla `ta_14_folios` en la base de datos PostgreSQL usando un procedimiento almacenado. El proceso es accesible vía una API unificada y una interfaz web moderna.

## Arquitectura
- **Frontend:** Vue.js (componente de página independiente)
- **Backend:** Laravel (controlador API unificado, endpoint `/api/execute`)
- **Base de Datos:** PostgreSQL (stored procedure `sp_up_pagos_update`)
- **Patrón API:** eRequest/eResponse

## Flujo de Trabajo
1. El usuario accede a la página de actualización de pagos y selecciona un archivo de texto.
2. El archivo se lee en el navegador y se envía su contenido codificado en base64 al backend vía `/api/execute`.
3. El backend decodifica el archivo, procesa cada línea, y por cada registro llama al stored procedure `sp_up_pagos_update`.
4. El resultado (éxitos, errores, detalles) se devuelve al frontend y se muestra al usuario.

## Formato del Archivo de Entrada
Cada línea del archivo debe contener:
- **Año (alo):** caracteres 1-4
- **Folio:** caracteres 5-11
- **Fecha (YYMMDD):** caracteres 19-24

Ejemplo de línea:
```
20231234567      230501
```

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
```json
{
  "eRequest": {
    "action": "up_pagos_upload",
    "data": {
      "file_content": "...base64...",
      "filename": "archivo.txt"
    }
  }
}
```
- **Response:**
```json
{
  "eResponse": {
    "success": true,
    "total": 10,
    "updated": 10,
    "errors": 0,
    "error_lines": [],
    "message": "All records updated successfully"
  }
}
```

## Stored Procedure
- **Nombre:** `sp_up_pagos_update`
- **Parámetros:**
  - `p_alo` (integer): Año
  - `p_folio` (integer): Folio
  - `p_fecbaj` (date): Fecha de baja/pago
- **Acción:** Actualiza la tabla `ta_14_folios` con los datos recibidos.
- **Retorno:**
  - `success` (boolean)
  - `message` (text)

## Validaciones y Manejo de Errores
- Si una línea no puede ser procesada, se registra el error y se continúa con las siguientes líneas.
- El resultado incluye el número total de registros, actualizados y errores, así como detalles de las líneas con error.

## Seguridad
- El endpoint requiere autenticación (recomendado implementar middleware de autenticación en producción).
- El archivo nunca se almacena en disco, solo se procesa en memoria.

## Consideraciones
- El proceso es idempotente: si se reenvía el mismo archivo, solo se actualizarán los registros existentes.
- El stored procedure maneja errores de SQL y retorna mensajes claros.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
