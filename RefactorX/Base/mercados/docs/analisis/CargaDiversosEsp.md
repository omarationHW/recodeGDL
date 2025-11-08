# Documentación Técnica: Carga Diversos Especial (CargaDiversosEsp)

## Descripción General
El formulario "Carga Diversos Especial" permite cargar pagos realizados por conceptos diversos (no regulares) en mercados, a partir de los registros de ingresos y aplicarlos a los locales correspondientes, eliminando los adeudos asociados. El proceso está orientado a la migración de la lógica Delphi a una arquitectura moderna con Laravel (backend), Vue.js (frontend) y PostgreSQL (base de datos).

## Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel, API RESTful con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## Flujo de Trabajo
1. **Selección de Fecha de Pago**: El usuario selecciona una fecha y consulta los adeudos pendientes para esa fecha.
2. **Visualización de Adeudos**: Se muestran los adeudos agrupados por local, con opción de capturar el número de partida para cada uno.
3. **Carga de Pagos**: El usuario ingresa los números de partida y graba los pagos. Solo se procesan los pagos con partida válida.
4. **Procesamiento Backend**:
   - Se valida la existencia del local.
   - Se inserta el pago en `ta_11_pagos_local`.
   - Se elimina el adeudo correspondiente en `ta_11_adeudo_local`.

## API Unificada
- **Endpoint**: `/api/execute`
- **Entrada**: JSON `{ eRequest: { action: string, data: object } }`
- **Salida**: JSON `{ eResponse: { success: bool, message: string, data: any } }`

### Acciones soportadas
- `getAdeudos`: Obtiene adeudos para una fecha.
- `getLocales`: Valida y obtiene información de un local.
- `cargarPagos`: Procesa la carga de pagos.
- `getFechasDescuento`: Obtiene la fecha de descuento para un mes.

## Stored Procedures
Toda la lógica SQL se implementa en stored procedures PostgreSQL:
- `sp_get_adeudos_diversos_esp(fecha_pago)`
- `sp_get_locales_diversos_esp(...)`
- `sp_cargar_pagos_diversos_esp(pagos_json, usuario, fecha_pago)`
- `sp_get_fecha_descuento(mes)`

## Validaciones
- Solo se procesan pagos con número de partida válido.
- Se valida la existencia del local antes de grabar el pago.
- Se eliminan los adeudos correspondientes tras el pago.
- Se maneja control de errores y transacciones.

## Seguridad
- El usuario autenticado se envía en el payload y se registra en los movimientos.
- El endpoint está protegido por autenticación Laravel (middleware `auth:api`).

## Frontend
- Página Vue.js independiente, sin tabs.
- Tabla editable para partidas.
- Mensajes de éxito y error.
- Navegación breadcrumb.

## Ejemplo de Payload
```json
{
  "eRequest": {
    "action": "cargarPagos",
    "data": {
      "pagos": [
        { "FECHA": "2024-06-01", "REC": "5", ... , "PARTIDA": "123" }
      ],
      "usuario": 1,
      "fecha_pago": "2024-06-01"
    }
  }
}
```

## Ejemplo de Respuesta
```json
{
  "eResponse": {
    "success": true,
    "message": "",
    "data": { "inserted": 5, "errors": 0 }
  }
}
```

## Consideraciones
- El frontend debe mapear los campos correctamente según los nombres esperados por el backend.
- El backend debe validar la integridad de los datos antes de ejecutar los procedimientos.
- El proceso es transaccional: si un pago falla, se revierte toda la operación.
