# CargaDiversosEsp

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - CargaDiversosEsp

**Categoría:** Form

## Caso de Uso 1: Carga de Pagos Diversos para Fecha Específica

**Descripción:** El usuario desea cargar pagos realizados por diversos para una fecha específica, ingresando los números de partida correspondientes.

**Precondiciones:**
El usuario tiene permisos de acceso y existen adeudos pendientes para la fecha seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página 'Carga Diversos Especial'.
2. Selecciona la fecha de pago (ejemplo: 2024-06-01).
3. Presiona 'Buscar'.
4. El sistema muestra la lista de adeudos pendientes.
5. El usuario ingresa el número de partida para cada pago que desea procesar.
6. Presiona 'Grabar'.
7. El sistema procesa los pagos y elimina los adeudos correspondientes.

**Resultado esperado:**
Los pagos con partida válida se graban correctamente y los adeudos asociados se eliminan. Se muestra un mensaje de éxito.

**Datos de prueba:**
fecha_pago: 2024-06-01
pagos: [ { FECHA: '2024-06-01', REC: '5', ... , PARTIDA: '123' }, ... ]

---

## Caso de Uso 2: Intento de Carga sin Partidas Válidas

**Descripción:** El usuario intenta grabar pagos sin ingresar ningún número de partida.

**Precondiciones:**
Existen adeudos pendientes, pero el usuario no ingresa ningún número de partida.

**Pasos a seguir:**
1. El usuario accede a la página y busca adeudos.
2. No ingresa ningún número de partida.
3. Presiona 'Grabar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no hay pagos válidos para grabar.

**Datos de prueba:**
fecha_pago: 2024-06-01
pagos: [ { FECHA: '2024-06-01', REC: '5', ... , PARTIDA: '' }, ... ]

---

## Caso de Uso 3: Validación de Local Inexistente

**Descripción:** El sistema intenta procesar un pago para un local que no existe en la base de datos.

**Precondiciones:**
El usuario ingresa una partida para un local que no existe.

**Pasos a seguir:**
1. El usuario busca adeudos y edita la información para simular un local inexistente.
2. Ingresa un número de partida y presiona 'Grabar'.

**Resultado esperado:**
El sistema omite el pago para el local inexistente y lo reporta como error en la respuesta.

**Datos de prueba:**
pagos: [ { FECHA: '2024-06-01', REC: '5', MER: '99', CAT: '9', LOCAL: '9999', PARTIDA: '999' } ]

---



## Casos de Prueba

# Casos de Prueba: Carga Diversos Especial

## Caso 1: Carga exitosa de pagos
- **Precondición:** Existen adeudos para la fecha 2024-06-01
- **Acción:**
  - Buscar adeudos para 2024-06-01
  - Ingresar partida '123' en el primer registro
  - Grabar
- **Esperado:**
  - El pago se graba y el adeudo se elimina
  - Respuesta: `{ success: true, data: { inserted: 1, errors: 0 } }`

## Caso 2: Intento de grabar sin partidas válidas
- **Precondición:** Existen adeudos para la fecha
- **Acción:**
  - Buscar adeudos
  - No ingresar ninguna partida
  - Grabar
- **Esperado:**
  - Mensaje de error: 'No hay pagos válidos para grabar.'

## Caso 3: Error por local inexistente
- **Precondición:** Se simula un pago para un local que no existe
- **Acción:**
  - Buscar adeudos
  - Editar el registro para poner MER: '99', CAT: '9', LOCAL: '9999'
  - Ingresar partida '999'
  - Grabar
- **Esperado:**
  - El sistema omite el pago y reporta error en el campo 'errors' de la respuesta

## Caso 4: Consulta de fechas de descuento
- **Acción:**
  - Llamar a la acción 'getFechasDescuento' con mes=6
- **Esperado:**
  - Se retorna la fecha de descuento correspondiente al mes 6

## Caso 5: Validación de integridad de datos
- **Acción:**
  - Enviar pagos con campos faltantes o tipos incorrectos
- **Esperado:**
  - El sistema retorna error de validación y no procesa la transacción



