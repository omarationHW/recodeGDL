# Documentación Técnica: Migración de Formulario sfrm_chg_autorizadescto

## 1. Descripción General
Este módulo permite consultar folios históricos por placa, visualizar descuentos otorgados y cambiar el estado de un descuento a "Tesorero". La migración se realizó desde Delphi a una arquitectura Laravel (API RESTful) + Vue.js (SPA) + PostgreSQL (con stored procedures).

## 2. Arquitectura
- **Backend:** Laravel 10+, PostgreSQL
- **Frontend:** Vue.js 2/3 (SPA)
- **API Unificada:** Un solo endpoint `/api/execute` que recibe un objeto `eRequest` y `params`.
- **Stored Procedures:** Toda la lógica SQL reside en funciones de PostgreSQL.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "buscar_folios_histo", // o 'buscar_folios_free', 'cambiar_a_tesorero'
    "params": { ... } // parámetros según operación
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- **sp_buscar_folios_histo(placa):** Devuelve los folios históricos para una placa.
- **sp_buscar_folios_free(axo, folio):** Devuelve los descuentos otorgados para un folio.
- **sp_cambiar_a_tesorero(axo, folio):** Cambia el campo `obs` a 'Tesorero' para el folio indicado.

## 5. Flujo de la Aplicación
1. **Buscar por Placa:**
   - El usuario ingresa una placa y presiona "Buscar".
   - Se llama a `/api/execute` con `eRequest: 'buscar_folios_histo'` y la placa.
   - Se muestran los folios encontrados.
2. **Seleccionar Folio:**
   - Al seleccionar un folio, se llama a `/api/execute` con `eRequest: 'buscar_folios_free'` y los datos del folio.
   - Se muestran los descuentos otorgados.
3. **Cambiar a Tesorero:**
   - El usuario puede presionar "Cambiar a Tesorero" en un descuento.
   - Se llama a `/api/execute` con `eRequest: 'cambiar_a_tesorero'` y los datos del folio.
   - Se actualiza la tabla y se muestra un mensaje de éxito o error.

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o session.
- Validar y sanear todos los parámetros recibidos.

## 7. Consideraciones
- El frontend es una página independiente, sin tabs.
- El backend es desacoplado y puede ser consumido por otros clientes.
- Los stored procedures pueden ser reutilizados por otros sistemas.

## 8. Manejo de Errores
- Todos los errores se devuelven en el campo `message` de la respuesta.
- El campo `success` indica si la operación fue exitosa.

## 9. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.
