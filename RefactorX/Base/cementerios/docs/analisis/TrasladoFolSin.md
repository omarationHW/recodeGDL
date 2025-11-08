# Documentación Técnica: Traslado de Pagos de Cementerio Sin Afectar Adeudos

## Descripción General
Este módulo permite trasladar pagos seleccionados de un folio de cementerio a otro, sin afectar los adeudos existentes. Está compuesto por:
- Un endpoint API unificado `/api/execute` (Laravel Controller)
- Un componente Vue.js de página completa
- Un stored procedure en PostgreSQL que realiza la lógica de negocio

## Arquitectura
- **Backend:** Laravel 10+, PostgreSQL 13+
- **Frontend:** Vue.js 3 (Composition API o Options API)
- **API:** Patrón eRequest/eResponse, endpoint único `/api/execute`
- **Seguridad:** El usuario debe estar autenticado y su ID se envía en cada petición

## Flujo de Trabajo
1. El usuario ingresa los folios DE y A TRASLADAR y solicita verificación.
2. El backend valida existencia y consistencia de ambos folios y muestra los pagos disponibles para traslado.
3. El usuario selecciona los pagos a trasladar y confirma la operación.
4. El backend ejecuta el stored procedure `sp_traslado_folios_sin_adeudo`, que actualiza los registros de pagos y los campos `axo_pagado` de ambos folios.
5. El frontend muestra mensajes de éxito o error según el resultado.

## API: /api/execute
- **Método:** POST
- **Body:**
  - `action`: string (ej: 'verificaFolios', 'trasladarPagos')
  - `data`: objeto con los parámetros requeridos
- **Respuesta:**
  - `success`: boolean
  - `message`: string
  - `data`: objeto (opcional)

### Acciones Soportadas
- `verificaFolios`: Verifica existencia y validez de los folios y devuelve datos y pagos asociados.
- `trasladarPagos`: Ejecuta el traslado de pagos seleccionados.
- `getPagosByFolio`: Devuelve pagos de un folio.
- `getDatosByFolio`: Devuelve datos de un folio.

## Stored Procedure: sp_traslado_folios_sin_adeudo
- **Entradas:**
  - `p_folio_de`: integer (folio origen)
  - `p_folio_a`: integer (folio destino)
  - `p_pagos_ids`: jsonb (array de IDs de pagos a trasladar)
  - `p_usuario`: integer (ID del usuario que realiza la operación)
- **Salidas:**
  - `success`: boolean
  - `message`: texto descriptivo
- **Lógica:**
  - Actualiza los pagos seleccionados para que apunten al folio destino y actualiza los campos de localización.
  - Actualiza el campo `axo_pagado` de ambos folios según el último pago registrado.
  - No afecta los adeudos (no borra ni crea nuevos).

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite buscar y validar folios, muestra datos y pagos, permite seleccionar pagos y ejecutar el traslado.
- Mensajes de error y éxito claros.
- Navegación sencilla, sin dependencias de otros formularios.

## Validaciones
- No se permite trasladar pagos entre el mismo folio.
- Ambos folios deben existir.
- Debe seleccionarse al menos un pago.
- El usuario debe estar autenticado.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- El ID de usuario debe ser confiable (obtenido del contexto de sesión, no del frontend).

## Manejo de Errores
- Todos los errores de validación y de base de datos se devuelven en el campo `message` de la respuesta.
- El frontend muestra los mensajes al usuario.

## Consideraciones de Integridad
- El stored procedure ejecuta todo en una transacción.
- Si ocurre un error, no se realiza ningún cambio parcial.

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas.
- El stored procedure puede ser adaptado para incluir lógica adicional si se requiere en el futuro.
