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
