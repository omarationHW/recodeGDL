# CargaPagEspecial

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - CargaPagEspecial

**Categoría:** Form

## Caso de Uso 1: Carga masiva de pagos especiales para un local con adeudos de años anteriores

**Descripción:** El usuario regulariza los pagos de un local con adeudos históricos, seleccionando los adeudos y cargando los pagos correspondientes.

**Precondiciones:**
El usuario tiene permisos para cargar pagos especiales. Existen adeudos históricos para el local seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos Especial.
2. Selecciona el mercado y captura el número de local.
3. Presiona 'Buscar Adeudos'.
4. El sistema muestra los adeudos históricos del local.
5. El usuario captura la partida para cada adeudo a pagar y selecciona los adeudos.
6. Presiona 'Cargar Pagos'.
7. El sistema inserta los pagos y elimina los adeudos correspondientes.

**Resultado esperado:**
Los pagos se insertan correctamente y los adeudos seleccionados se eliminan. Se muestra un mensaje de éxito.

**Datos de prueba:**
{ "mercado": 10, "local": 123, "adeudos": [{ "axo": 2004, "periodo": 8, "importe": 1000, "partida": "P-001" }] }

---

## Caso de Uso 2: Intento de cargar pagos sin capturar partida

**Descripción:** El usuario intenta cargar pagos sin capturar el número de partida para los adeudos seleccionados.

**Precondiciones:**
Existen adeudos históricos para el local seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos Especial.
2. Selecciona el mercado y local.
3. Presiona 'Buscar Adeudos'.
4. El sistema muestra los adeudos.
5. El usuario no captura la partida y presiona 'Cargar Pagos'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe capturar la partida.

**Datos de prueba:**
{ "mercado": 10, "local": 123, "adeudos": [{ "axo": 2004, "periodo": 8, "importe": 1000, "partida": "" }] }

---

## Caso de Uso 3: Carga de pago con descuento automático (2005-10)

**Descripción:** El usuario carga un pago para el periodo 2005-10, el sistema aplica automáticamente un descuento del 10%.

**Precondiciones:**
Existe un adeudo para el local en axo=2005, periodo=10.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos Especial.
2. Selecciona el mercado y local.
3. Presiona 'Buscar Adeudos'.
4. El sistema muestra el adeudo para 2005-10.
5. El usuario captura la partida y selecciona el adeudo.
6. Presiona 'Cargar Pagos'.

**Resultado esperado:**
El pago se inserta con el importe de la renta menos el 10% de descuento.

**Datos de prueba:**
{ "mercado": 10, "local": 123, "adeudos": [{ "axo": 2005, "periodo": 10, "importe": 1000, "partida": "P-002" }] }

---



## Casos de Prueba

# Casos de Prueba para CargaPagEspecial

## Caso 1: Carga masiva de pagos especiales
- **Precondición:** Existen adeudos históricos para el local 123 en el mercado 10.
- **Pasos:**
  1. Seleccionar mercado 10, local 123.
  2. Buscar adeudos.
  3. Capturar partida 'P-001' para adeudo 2004-8.
  4. Seleccionar el adeudo y cargar pagos.
- **Esperado:** El pago se inserta y el adeudo se elimina.

## Caso 2: Intento de cargar pagos sin partida
- **Precondición:** Existen adeudos históricos para el local 123 en el mercado 10.
- **Pasos:**
  1. Seleccionar mercado 10, local 123.
  2. Buscar adeudos.
  3. No capturar partida.
  4. Seleccionar el adeudo y cargar pagos.
- **Esperado:** El sistema muestra error: 'Debe seleccionar al menos un adeudo y capturar la partida.'

## Caso 3: Carga de pago con descuento automático
- **Precondición:** Existe adeudo para local 123, mercado 10, axo=2005, periodo=10, importe=1000.
- **Pasos:**
  1. Seleccionar mercado 10, local 123.
  2. Buscar adeudos.
  3. Capturar partida 'P-002' para adeudo 2005-10.
  4. Seleccionar el adeudo y cargar pagos.
- **Esperado:** El pago se inserta con importe 900 (1000 - 10%).

## Caso 4: Error de conexión a base de datos
- **Precondición:** La base de datos está caída.
- **Pasos:**
  1. Intentar buscar mercados o cargar pagos.
- **Esperado:** El sistema muestra mensaje de error de conexión.

## Caso 5: Validación de campos obligatorios
- **Precondición:** El usuario no llena todos los campos del formulario.
- **Pasos:**
  1. Dejar vacío el campo 'local' y presionar 'Buscar Adeudos'.
- **Esperado:** El sistema muestra mensaje de error indicando el campo obligatorio.


