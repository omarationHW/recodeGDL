# Documentación Técnica: Migración Formulario investctafrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la funcionalidad de "Investigación de Cuentas" del sistema catastral. Permite consultar y actualizar observaciones sobre una cuenta catastral específica, registrando el movimiento como investigación (cvemov=73) y actualizando el número de asiento.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "update_investcta",
    "params": {
      "cvecuenta": 12345,
      "observacion": "TEXTO OBSERVACION"
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "message": "Investigación de cuenta actualizada correctamente"
  }
  ```

## 4. Stored Procedure Principal
- **sp_update_investcta**: Actualiza la observación, cvemov y asiento de la cuenta catastral.

## 5. Seguridad
- El endpoint requiere autenticación (Laravel Auth). El usuario autenticado se registra como capturista.
- Validaciones de parámetros en backend y frontend.

## 6. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite buscar cuenta por número y muestra los datos del último comprobante.
- Permite editar y guardar observaciones (en mayúsculas).
- Mensajes de éxito/error claros.

## 7. Backend (Laravel)
- Controlador único con método `execute` que enruta la acción solicitada.
- Métodos para consultar y actualizar la investigación de cuenta.
- Llama a stored procedures PostgreSQL para lógica de negocio.

## 8. Base de Datos
- Tabla principal: `catastro`
- Campos relevantes: `cvecuenta`, `observacion`, `cvemov`, `asiento`, `feccap`, `capturista`
- Stored procedure maneja la lógica de actualización.

## 9. Flujo de Trabajo
1. Usuario ingresa número de cuenta.
2. El sistema muestra los datos del último comprobante.
3. Usuario ingresa/edita observaciones.
4. Al guardar, se actualiza la cuenta vía stored procedure.
5. Se muestra mensaje de éxito o error.

## 10. Consideraciones
- El formulario es una página independiente.
- No se usan tabs ni componentes tabulares.
- El endpoint es único y extensible para otras acciones.

## 11. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los stored procedures pueden ampliarse para más lógica de negocio.
