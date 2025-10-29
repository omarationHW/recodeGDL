# Documentación Técnica: Carga de Pagos Especial (Años Anteriores sin Fecha de Ingreso)

## Descripción General
Este módulo permite la carga masiva de pagos especiales para años anteriores sin fecha de ingreso, permitiendo la regularización de adeudos históricos en el sistema de mercados municipales. Incluye la consulta de mercados, obtención de adeudos por local y la carga de pagos con reglas de negocio específicas (por ejemplo, descuentos en ciertos periodos).

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **API:** Todas las operaciones se realizan a través de un único endpoint, recibiendo un objeto JSON con los campos `action` y `payload`.

## Flujo de Trabajo
1. **Consulta de Mercados:** El usuario selecciona el mercado desde un combo alimentado por el SP `sp_get_mercados`.
2. **Consulta de Adeudos:** Al ingresar el número de local y presionar "Buscar Adeudos", se llama al SP `sp_get_adeudos_local`.
3. **Carga de Pagos:** El usuario selecciona los adeudos a pagar, captura la partida y presiona "Cargar Pagos". Se llama al SP `sp_cargar_pagos_especial`, que inserta los pagos y elimina los adeudos correspondientes.

## Validaciones y Reglas de Negocio
- Solo se pueden cargar pagos con partida válida (no vacía ni cero).
- Si el pago corresponde a axo=2005 y periodo=10, se aplica un descuento del 10%.
- El proceso es transaccional: si ocurre un error, se revierte toda la operación.

## Seguridad
- El endpoint requiere autenticación (no implementado en este ejemplo, pero el `usuario_id` debe provenir de la sesión).
- Validaciones de datos en backend y frontend.

## API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombreAccion",
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

## Stored Procedures
- Toda la lógica de negocio y acceso a datos está en SPs para facilitar la trazabilidad y el mantenimiento.

## Frontend
- Página Vue.js independiente, sin tabs.
- Navegación breadcrumb.
- Tabla editable para captura de partidas y selección de adeudos.
- Mensajes de éxito/error claros.

## Extensibilidad
- El endpoint y los SPs pueden ser reutilizados para otros procesos de carga masiva de pagos.

# Endpoints y Acciones
| Acción                 | Descripción                                 | SP/Función Backend           |
|------------------------|---------------------------------------------|------------------------------|
| getMercados            | Lista mercados activos                      | sp_get_mercados              |
| getAdeudosLocal        | Lista adeudos de un local                   | sp_get_adeudos_local         |
| cargarPagosEspecial    | Carga pagos especiales y elimina adeudos    | sp_cargar_pagos_especial     |

# Manejo de Errores
- Todos los errores se devuelven en el campo `message` de la respuesta JSON.
- Si ocurre un error en la transacción, se revierte y se informa al usuario.

# Seguridad y Auditoría
- El usuario que realiza la operación queda registrado en los pagos insertados.
- Se recomienda auditar los cambios en las tablas de pagos y adeudos.
