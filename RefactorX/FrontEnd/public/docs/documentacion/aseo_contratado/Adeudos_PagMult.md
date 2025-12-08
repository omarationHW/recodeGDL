# DocumentaciÃ³n TÃ©cnica: Adeudos_PagMult

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Adeudos_PagMult (Laravel + Vue.js + PostgreSQL)

## Descripción General
El formulario "Adeudos_PagMult" permite dar de pagado en forma múltiple los adeudos vigentes (excedencias) de un contrato. El proceso incluye:
- Selección de contrato y tipo de aseo
- Visualización de adeudos vigentes
- Selección múltiple de adeudos a pagar
- Captura de datos de pago (fecha, recaudadora, caja, consecutivo, folio)
- Ejecución del pago en lote

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA, página independiente para el formulario
- **Base de datos:** PostgreSQL, lógica de negocio en stored procedures

## API (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listar_catalogos|buscar_contrato|listar_adeudos|pagar_adeudos",
      ... parámetros ...
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```

### Acciones soportadas
- `listar_catalogos`: Devuelve catálogos de tipos de aseo, recaudadoras y cajas
- `buscar_contrato`: Busca contrato por número y tipo de aseo
- `listar_adeudos`: Lista adeudos vigentes de un contrato
- `pagar_adeudos`: Marca como pagados los adeudos seleccionados

## Stored Procedures
- **sp_adeudos_pagmult_listar_catalogos**: Devuelve catálogos
- **sp_adeudos_pagmult_buscar_contrato**: Busca contrato
- **sp_adeudos_pagmult_listar_adeudos**: Lista adeudos vigentes
- **sp_adeudos_pagmult_pagar_adeudos**: Marca como pagados los adeudos seleccionados

## Seguridad
- El endpoint requiere autenticación (no implementada en ejemplo, pero debe integrarse con middleware de Laravel)
- Validación de parámetros en backend
- Transacciones para operaciones de pago

## Frontend (Vue.js)
- Página independiente, sin tabs
- Navegación breadcrumb
- Tabla de adeudos con selección múltiple
- Formulario de datos de pago
- Mensajes de error y éxito

## Flujo de Usuario
1. Selecciona contrato y tipo de aseo
2. Visualiza datos del contrato
3. Consulta adeudos vigentes
4. Selecciona adeudos a pagar
5. Captura datos de pago y ejecuta
6. El sistema actualiza los registros y muestra confirmación

## Integración
- El componente Vue.js se comunica con el backend mediante fetch/AJAX al endpoint `/api/execute`
- El backend ejecuta el stored procedure correspondiente según la acción

## Consideraciones
- El usuario debe estar autenticado (simulado en ejemplo)
- Los SP deben estar creados en la base de datos PostgreSQL
- El endpoint puede ser extendido para otras acciones del sistema


## Casos de Prueba

# Casos de Prueba: Adeudos_PagMult

## Caso 1: Pago múltiple exitoso
- Buscar contrato existente con adeudos vigentes
- Seleccionar varios adeudos
- Llenar todos los datos de pago
- Ejecutar pago
- Verificar en la base de datos que los registros cambian a status 'P' y los campos de pago se actualizan

## Caso 2: Intento de pago sin selección
- Buscar contrato con adeudos vigentes
- No seleccionar ningún adeudo
- Llenar datos de pago
- Ejecutar pago
- Verificar que el sistema muestra mensaje de error y no realiza ningún cambio en la base de datos

## Caso 3: Intento de pago con datos incompletos
- Buscar contrato con adeudos vigentes
- Seleccionar uno o más adeudos
- Omitir algún campo obligatorio de pago (ejemplo: consecutivo)
- Ejecutar pago
- Verificar que el sistema muestra mensaje de error y no realiza ningún cambio en la base de datos

## Caso 4: Contrato inexistente
- Ingresar un número de contrato que no existe
- Buscar
- Verificar que el sistema muestra mensaje de error 'Contrato no encontrado'

## Caso 5: Integridad de transacción
- Simular error en la base de datos durante el pago
- Verificar que ningún adeudo cambia de estado y se revierte la transacción


## Casos de Uso

# Casos de Uso - Adeudos_PagMult

**Categoría:** Form

## Caso de Uso 1: Pago múltiple de excedencias vigentes de un contrato

**Descripción:** El usuario selecciona un contrato y tipo de aseo, visualiza los adeudos vigentes, selecciona varios y los da de pagado en una sola operación.

**Precondiciones:**
El contrato existe y tiene adeudos vigentes de tipo excedencia.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar'.
3. El sistema muestra los datos del contrato.
4. El usuario presiona 'Ver Adeudos Vigentes'.
5. El sistema muestra la lista de adeudos vigentes.
6. El usuario selecciona varios adeudos (checkbox).
7. El usuario llena los datos de pago (fecha, recaudadora, caja, consecutivo, folio).
8. Presiona 'Dar de Pagado Seleccionados'.

**Resultado esperado:**
Los adeudos seleccionados cambian su estatus a 'Pagado' y se actualizan los campos de pago.

**Datos de prueba:**
Contrato: 12345
Tipo de aseo: 4
Adeudos: 3 registros vigentes
Datos de pago: fecha actual, recaudadora 1, caja 'A', consecutivo 1001, folio 'F123'

---

## Caso de Uso 2: Intento de pago sin seleccionar adeudos

**Descripción:** El usuario intenta ejecutar el pago sin seleccionar ningún adeudo.

**Precondiciones:**
El contrato tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario busca el contrato y visualiza los adeudos.
2. No selecciona ningún adeudo.
3. Llena los datos de pago y presiona 'Dar de Pagado Seleccionados'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe seleccionar al menos un adeudo.

**Datos de prueba:**
Contrato: 12345
Tipo de aseo: 4
Adeudos: 2 registros vigentes
Datos de pago: fecha actual, recaudadora 1, caja 'A', consecutivo 1002, folio 'F124'

---

## Caso de Uso 3: Intento de pago con datos incompletos

**Descripción:** El usuario selecciona adeudos pero omite algún dato obligatorio de pago.

**Precondiciones:**
El contrato tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario busca el contrato y visualiza los adeudos.
2. Selecciona uno o más adeudos.
3. Omite llenar el campo 'Consecutivo de Operación'.
4. Presiona 'Dar de Pagado Seleccionados'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe completar todos los datos de pago.

**Datos de prueba:**
Contrato: 12345
Tipo de aseo: 4
Adeudos: 2 registros vigentes
Datos de pago: fecha actual, recaudadora 1, caja 'A', consecutivo vacío, folio 'F125'

---



---
**Componente:** `Adeudos_PagMult.vue`
**MÃ³dulo:** `aseo_contratado`

