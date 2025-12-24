# CargaPagEnergia

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Carga de Pagos de Energía Eléctrica

## Descripción General
Este módulo permite la consulta de adeudos de energía eléctrica para locales de mercados, la carga de pagos de dichos adeudos, y la consulta de pagos realizados. La solución está compuesta por:
- Un controlador Laravel con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- Un componente Vue.js de página completa
- Stored Procedures en PostgreSQL para la lógica de negocio
- Documentación de casos de uso y pruebas

## Arquitectura
- **Backend**: Laravel (PHP), PostgreSQL
- **Frontend**: Vue.js SPA
- **API**: Un único endpoint `/api/execute` que recibe `{ action, payload }` y responde con `{ data, error }`.
- **Seguridad**: Se recomienda autenticación JWT o session para identificar al usuario (`userId`).

## Flujo Principal
1. El usuario selecciona recaudadora, mercado, sección y local.
2. El sistema consulta los adeudos de energía eléctrica pendientes para ese local.
3. El usuario selecciona los adeudos a pagar, ingresa los datos del pago (fecha, oficina, caja, operación, folio) y ejecuta la carga.
4. El sistema registra los pagos y elimina los adeudos correspondientes.
5. El usuario puede consultar los pagos realizados para el local/energía.

## API (Laravel Controller)
- **/api/execute** (POST)
  - `action`: Acción a ejecutar (string)
  - `payload`: Parámetros de la acción (object)

### Acciones soportadas
- `buscarAdeudosEnergia`: Busca adeudos de energía eléctrica para un local
- `cargarPagosEnergia`: Carga pagos de energía eléctrica (array de pagos)
- `consultarPagosEnergia`: Consulta pagos realizados para un id_energia
- `listarRecaudadoras`: Lista recaudadoras
- `listarSecciones`: Lista secciones
- `listarCajas`: Lista cajas para una recaudadora

## Stored Procedures
- **sp_buscar_adeudos_energia**: Devuelve los adeudos pendientes de energía eléctrica para un local
- **sp_cargar_pago_energia**: Inserta un pago y elimina el adeudo correspondiente
- **sp_consultar_pagos_energia**: Devuelve los pagos realizados para un id_energia

## Validaciones
- Todos los campos requeridos deben ser validados en backend y frontend.
- No se permite cargar pagos sin seleccionar al menos un adeudo.
- No se permite cargar pagos con datos incompletos.

## Manejo de Errores
- Todos los errores de validación y de base de datos se devuelven en el campo `error` del response.
- El frontend muestra los errores en pantalla.

## Seguridad
- El endpoint debe estar protegido por autenticación.
- El id_usuario se obtiene del usuario autenticado.

## Consideraciones
- El frontend es una página independiente, no usa tabs.
- El backend es desacoplado y puede ser consumido por otros clientes.
- El frontend permite seleccionar múltiples adeudos para pago masivo.

## Ejemplo de Request/Response
### Buscar Adeudos
```json
{
  "action": "buscarAdeudosEnergia",
  "payload": {
    "oficina": 5,
    "mercado": 1,
    "categoria": 2,
    "seccion": "SS",
    "local": 123
  }
}
```

### Cargar Pagos
```json
{
  "action": "cargarPagosEnergia",
  "payload": {
    "pagos": [
      { "id_energia": 1001, "axo": 2024, "periodo": 6, "importe": 500.00, "cve_consumo": "F", "cantidad": 100 },
      { "id_energia": 1002, "axo": 2024, "periodo": 7, "importe": 600.00, "cve_consumo": "K", "cantidad": 120 }
    ],
    "fecha_pago": "2024-06-10",
    "oficina_pago": 5,
    "caja_pago": "A",
    "operacion_pago": 12345,
    "folio": "FOL123"
  }
}
```

### Consultar Pagos
```json
{
  "action": "consultarPagosEnergia",
  "payload": { "id_energia": 1001 }
}
```

## Estructura de la Base de Datos (Tablas principales)
- ta_11_adeudo_energ
- ta_11_pago_energia
- ta_11_energia
- ta_11_locales
- ta_12_passwords
- ta_12_recaudadoras
- ta_12_operaciones
- ta_11_secciones

## Frontend (Vue.js)
- Página independiente
- Permite buscar adeudos, seleccionar y cargar pagos, y consultar pagos realizados
- Validación de campos y mensajes de error/success

## Backend (Laravel)
- Controlador único, desacoplado, fácil de mantener
- Uso de stored procedures para lógica de negocio
- Manejo de transacciones y errores


## Casos de Uso

# Casos de Uso - CargaPagEnergia

**Categoría:** Form

## Caso de Uso 1: Carga de Pago de Energía para un Local

**Descripción:** El usuario busca los adeudos de energía eléctrica de un local y realiza el pago de uno o varios adeudos.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para cargar pagos. Debe existir al menos un adeudo pendiente para el local.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía.
2. Selecciona la recaudadora, mercado, sección y local.
3. Hace clic en 'Buscar Adeudos'.
4. El sistema muestra los adeudos pendientes.
5. El usuario selecciona uno o varios adeudos.
6. Ingresa los datos del pago (fecha, oficina de pago, caja, operación, folio).
7. Hace clic en 'Cargar Pagos'.
8. El sistema registra los pagos y elimina los adeudos correspondientes.

**Resultado esperado:**
Los pagos quedan registrados y los adeudos seleccionados desaparecen de la lista de pendientes.

**Datos de prueba:**
oficina: 5, mercado: 1, categoria: 2, seccion: 'SS', local: 123, fecha_pago: '2024-06-10', oficina_pago: 5, caja_pago: 'A', operacion_pago: 12345, folio: 'FOL123'

---

## Caso de Uso 2: Consulta de Pagos Realizados

**Descripción:** El usuario consulta los pagos realizados para un local/energía.

**Precondiciones:**
El usuario debe estar autenticado. Debe existir al menos un pago registrado para el id_energia consultado.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía.
2. Realiza una búsqueda de adeudos y/o pagos.
3. Hace clic en 'Consultar Pagos' para un id_energia.
4. El sistema muestra la lista de pagos realizados.

**Resultado esperado:**
Se muestra la lista de pagos realizados para el id_energia seleccionado.

**Datos de prueba:**
id_energia: 1001

---

## Caso de Uso 3: Validación de Campos Requeridos

**Descripción:** El usuario intenta cargar pagos sin seleccionar ningún adeudo o sin completar los datos requeridos.

**Precondiciones:**
El usuario debe estar autenticado. Debe haber adeudos listados.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía.
2. Busca adeudos para un local.
3. No selecciona ningún adeudo y hace clic en 'Cargar Pagos'.
4. El sistema muestra un mensaje de error.
5. El usuario selecciona adeudos pero omite algún campo obligatorio (ej. fecha de pago).
6. El sistema muestra un mensaje de error.

**Resultado esperado:**
El sistema no permite cargar pagos y muestra mensajes de error claros.

**Datos de prueba:**
oficina: 5, mercado: 1, categoria: 2, seccion: 'SS', local: 123, pagos: [], fecha_pago: '', oficina_pago: '', caja_pago: '', operacion_pago: '', folio: ''

---



## Casos de Prueba

# Casos de Prueba: CargaPagEnergia

## Caso 1: Carga exitosa de pagos de energía
- **Precondición:** Existen adeudos pendientes para el local.
- **Pasos:**
  1. Buscar adeudos para oficina=5, mercado=1, categoria=2, seccion='SS', local=123
  2. Seleccionar todos los adeudos listados
  3. Ingresar fecha_pago='2024-06-10', oficina_pago=5, caja_pago='A', operacion_pago=12345, folio='FOL123'
  4. Ejecutar carga de pagos
- **Resultado esperado:** Los pagos se registran y los adeudos desaparecen de la lista.

## Caso 2: Intento de carga sin seleccionar adeudos
- **Precondición:** Existen adeudos listados
- **Pasos:**
  1. Buscar adeudos para un local
  2. No seleccionar ningún adeudo
  3. Intentar cargar pagos
- **Resultado esperado:** El sistema muestra error 'Debe seleccionar al menos un adeudo para cargar el pago.'

## Caso 3: Consulta de pagos realizados
- **Precondición:** Existen pagos registrados para id_energia=1001
- **Pasos:**
  1. Consultar pagos para id_energia=1001
- **Resultado esperado:** Se muestra la lista de pagos realizados para ese id_energia.

## Caso 4: Validación de campos obligatorios
- **Precondición:** Existen adeudos listados
- **Pasos:**
  1. Seleccionar adeudos
  2. Omitir algún campo obligatorio (ej. fecha_pago)
  3. Intentar cargar pagos
- **Resultado esperado:** El sistema muestra error de validación indicando el campo faltante.

## Caso 5: Integridad transaccional
- **Precondición:** El sistema está operativo
- **Pasos:**
  1. Simular un error de base de datos durante la carga de pagos (ej. duplicidad, error de conexión)
  2. Intentar cargar pagos
- **Resultado esperado:** El sistema revierte la transacción y muestra un mensaje de error.



