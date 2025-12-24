# CargaPagEnergiaElec

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Carga de Pagos de Energía Eléctrica

## Descripción General
Este módulo permite la consulta de adeudos de energía eléctrica para locales de mercados, la carga de pagos asociados y la consulta de pagos realizados. La solución está compuesta por:

- Un controlador Laravel que expone un endpoint único `/api/execute` bajo el patrón eRequest/eResponse.
- Un componente Vue.js que implementa la interfaz de usuario como página independiente.
- Stored Procedures en PostgreSQL para encapsular la lógica de negocio y acceso a datos.
- Documentación de casos de uso y pruebas.

## Arquitectura

- **Backend:** Laravel 10+, PostgreSQL 13+, API RESTful.
- **Frontend:** Vue.js 3+, SPA (Single Page Application).
- **Comunicación:** JSON, endpoint único `/api/execute`.
- **Seguridad:** Autenticación por token (no incluida en el ejemplo, pero debe implementarse en producción).

## Flujo de Trabajo

1. El usuario selecciona los parámetros del local (recaudadora, mercado, categoría, sección, local desde/hasta) y consulta los adeudos.
2. El usuario selecciona los adeudos a pagar, captura la partida y los datos del pago (fecha, oficina, caja, operación).
3. El usuario ejecuta la carga de pagos. El backend valida y ejecuta la transacción, insertando los pagos y eliminando los adeudos correspondientes.
4. El usuario puede consultar los pagos realizados para un local/energía.

## Endpoints y Acciones

- `/api/execute` (POST)
  - **action: 'buscarAdeudos'**: Busca adeudos de energía eléctrica.
  - **action: 'cargarPagos'**: Carga pagos de energía eléctrica.
  - **action: 'consultarPagos'**: Consulta pagos realizados para un local/energía.
  - **action: 'consultarCajas'**: Devuelve las cajas disponibles para una oficina.
  - **action: 'consultarMercados'**: Devuelve los mercados de una oficina.

## Stored Procedures

- `sp_buscar_adeudos_energia_elec`: Devuelve los adeudos de energía eléctrica para un rango de locales.
- `sp_cargar_pago_energia_elec`: Inserta un pago y elimina el adeudo correspondiente.
- `sp_consultar_pagos_energia_elec`: Devuelve los pagos realizados para un id_energia.
- `sp_consultar_cajas`: Devuelve las cajas disponibles para una oficina.
- `sp_consultar_mercados`: Devuelve los mercados de una oficina.

## Validaciones
- No se permite cargar pagos sin partida o sin seleccionar el adeudo.
- No se permite cargar pagos si faltan datos obligatorios del pago.
- La operación es atómica: si falla un pago, se revierte toda la transacción.

## Consideraciones de Seguridad
- El usuario debe estar autenticado y autorizado para ejecutar la acción.
- Los parámetros deben ser validados en backend y frontend.

## Integración
- El frontend consume el endpoint `/api/execute` enviando el campo `action` y los datos necesarios en `data`.
- El backend responde con un objeto JSON con los campos `success`, `message` y `data`.

## Ejemplo de Request
```json
{
  "action": "cargarPagos",
  "data": {
    "pagos": [
      {
        "id_energia": 123,
        "axo": 2024,
        "periodo": 6,
        "importe": 150.00,
        "cve_consumo": "F",
        "cantidad": 100,
        "folio": "12345"
      }
    ],
    "usuario_id": 1,
    "fecha_pago": "2024-06-10",
    "oficina_pago": 2,
    "caja_pago": "A1",
    "operacion_pago": 45678
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "message": "",
  "data": [ ... ]
}
```

## Errores Comunes
- `success: false` y `message` con la descripción del error.
- Validaciones de campos obligatorios y tipos de datos.

## Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los stored procedures pueden ser extendidos para lógica adicional.

## Seguridad y Auditoría
- Todas las operaciones quedan registradas con el usuario y la fecha/hora.
- Se recomienda implementar logs de auditoría adicionales en producción.


## Casos de Uso

# Casos de Uso - CargaPagEnergiaElec

**Categoría:** Form

## Caso de Uso 1: Carga de Pagos de Energía Eléctrica para un Local

**Descripción:** El usuario consulta los adeudos de energía eléctrica de un local y realiza la carga de pagos correspondientes.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para cargar pagos. Debe existir al menos un adeudo pendiente para el local.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía Eléctrica.
2. Selecciona la recaudadora, mercado, categoría, sección y rango de locales.
3. Hace clic en 'Buscar Adeudos'.
4. El sistema muestra la lista de adeudos pendientes.
5. El usuario selecciona los adeudos a pagar y captura la partida.
6. Captura los datos del pago (fecha, oficina, caja, operación).
7. Hace clic en 'Cargar Pagos'.
8. El sistema valida y ejecuta la carga de pagos.
9. El sistema muestra mensaje de éxito y actualiza la lista de adeudos.

**Resultado esperado:**
Los pagos seleccionados se registran correctamente y los adeudos correspondientes se eliminan. El usuario ve un mensaje de éxito.

**Datos de prueba:**
oficina: 2, mercado: 5, categoria: 1, seccion: 'A', local_desde: 10, local_hasta: 10, fecha_pago: '2024-06-10', oficina_pago: 2, caja_pago: 'A1', operacion_pago: 12345, pagos: [{ id_energia: 123, axo: 2024, periodo: 6, importe: 150.00, cve_consumo: 'F', cantidad: 100, folio: '12345' }]

---

## Caso de Uso 2: Consulta de Pagos Realizados para un Local

**Descripción:** El usuario consulta los pagos realizados para un local específico.

**Precondiciones:**
El usuario debe estar autenticado. Debe existir al menos un pago registrado para el local.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía Eléctrica.
2. Busca los adeudos de un local y selecciona uno.
3. Hace clic en 'Consultar Pagos'.
4. El sistema muestra la lista de pagos realizados para ese local.

**Resultado esperado:**
El usuario visualiza la lista de pagos realizados para el local seleccionado.

**Datos de prueba:**
id_energia: 123

---

## Caso de Uso 3: Validación de Campos Obligatorios al Cargar Pagos

**Descripción:** El usuario intenta cargar pagos sin capturar la partida o sin seleccionar adeudos.

**Precondiciones:**
El usuario debe estar autenticado. Debe haber adeudos listados.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía Eléctrica.
2. Busca los adeudos de un local.
3. Intenta cargar pagos sin seleccionar ningún adeudo o sin capturar la partida.
4. El sistema valida y muestra un mensaje de error.

**Resultado esperado:**
El sistema no permite cargar pagos y muestra un mensaje de error indicando que debe seleccionar al menos un adeudo y capturar la partida.

**Datos de prueba:**
pagos: []

---



## Casos de Prueba

# Casos de Prueba: Carga de Pagos de Energía Eléctrica

## Caso 1: Carga exitosa de pagos
- **Precondición:** Existen adeudos para el local.
- **Acción:** El usuario selecciona adeudos, captura partida y datos de pago, y ejecuta la carga.
- **Esperado:** Los pagos se insertan y los adeudos se eliminan. Mensaje de éxito.

## Caso 2: Consulta de pagos realizados
- **Precondición:** Existen pagos registrados para el local.
- **Acción:** El usuario consulta los pagos realizados para un id_energia.
- **Esperado:** Se muestra la lista de pagos realizados.

## Caso 3: Intento de carga sin seleccionar adeudos
- **Precondición:** Hay adeudos listados.
- **Acción:** El usuario intenta cargar pagos sin seleccionar ningún adeudo o sin capturar la partida.
- **Esperado:** El sistema muestra un mensaje de error y no realiza ninguna operación.

## Caso 4: Error de base de datos
- **Precondición:** La base de datos está inaccesible.
- **Acción:** El usuario intenta cargar pagos.
- **Esperado:** El sistema muestra un mensaje de error y no realiza ninguna operación.

## Caso 5: Validación de campos obligatorios
- **Precondición:** El usuario deja campos obligatorios vacíos (fecha de pago, oficina, caja, operación).
- **Acción:** El usuario intenta cargar pagos.
- **Esperado:** El sistema muestra un mensaje de error indicando los campos faltantes.



