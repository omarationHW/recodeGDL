# ConsPagos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Consulta de Pagos (ConsPagos)

## Descripción General
Este módulo permite consultar, agregar y eliminar pagos asociados a un local específico en el sistema de mercados municipales. La migración se realizó desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos), siguiendo el patrón eRequest/eResponse con un endpoint unificado `/api/execute`.

## Arquitectura
- **Backend:** Laravel Controller (`ConsPagosController`) expone un endpoint `/api/execute` que recibe acciones y parámetros en formato JSON.
- **Frontend:** Componente Vue.js de página completa, independiente, sin tabs, con navegación breadcrumb y tabla de resultados.
- **Base de Datos:** Toda la lógica SQL se encapsula en stored procedures PostgreSQL.
- **API:** Todas las operaciones (consulta, alta, baja) se realizan a través de un único endpoint, usando el campo `action` para determinar la operación.

## Flujo de Datos
1. El usuario ingresa el ID del local y consulta los pagos asociados.
2. Puede agregar un nuevo pago llenando el formulario modal.
3. Puede eliminar un pago existente desde la tabla.
4. Todas las operaciones se comunican con el backend mediante `/api/execute`.

## Formato de Petición (eRequest)
```json
{
  "action": "getPagosByLocal", // o "addPago", "deletePago"
  "params": { ... } // parámetros según la acción
}
```

## Formato de Respuesta (eResponse)
```json
{
  "success": true,
  "data": [...], // o null
  "message": "Mensaje de error o éxito"
}
```

## Stored Procedures
- **sp_cons_pagos_get_by_local:** Devuelve todos los pagos de un local, con datos relacionados.
- **sp_cons_pagos_add:** Inserta un nuevo pago.
- **sp_cons_pagos_delete:** Elimina un pago por su identificador.

## Seguridad
- Validación de parámetros en backend (Laravel Validator).
- El id_usuario debe ser autenticado en producción (en el ejemplo se simula).
- El endpoint debe protegerse con autenticación JWT o similar en producción.

## Consideraciones de Migración
- Los campos y lógica de negocio se respetan según el código Delphi original.
- Los nombres de tablas y campos se mantienen para compatibilidad.
- El frontend es completamente independiente y funcional como página única.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el mismo patrón.
- Los stored procedures pueden ampliarse para lógica adicional (por ejemplo, validaciones de negocio más complejas).

## Dependencias
- Laravel 10+
- Vue.js 2/3 + Element UI (o similar)
- PostgreSQL 12+



## Casos de Uso

# Casos de Uso - ConsPagos

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de un local

**Descripción:** El usuario desea ver todos los pagos realizados para un local específico.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID del local.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos.
2. Ingresa el ID del local en el campo correspondiente.
3. Presiona el botón 'Buscar'.
4. El sistema muestra la lista de pagos asociados al local.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados para el local, incluyendo fecha, importe, usuario, etc.

**Datos de prueba:**
id_local: 12345

---

## Caso de Uso 2: Agregar un nuevo pago a un local

**Descripción:** El usuario necesita registrar un nuevo pago para un local.

**Precondiciones:**
El usuario tiene permisos para agregar pagos y conoce los datos requeridos.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos.
2. Ingresa el ID del local y busca los pagos existentes.
3. Presiona el botón 'Agregar Pago'.
4. Llena el formulario con los datos del pago (año, mes, fecha, oficina, caja, operación, importe, partida).
5. Presiona 'Agregar'.
6. El sistema registra el pago y actualiza la tabla.

**Resultado esperado:**
El nuevo pago aparece en la tabla de pagos del local.

**Datos de prueba:**
{
  "id_local": 12345,
  "axo": 2024,
  "periodo": 6,
  "fecha_pago": "2024-06-15",
  "oficina_pago": 2,
  "caja_pago": "A",
  "operacion_pago": 1001,
  "importe_pago": 1500.00,
  "folio": "F1234",
  "id_usuario": 1
}

---

## Caso de Uso 3: Eliminar un pago existente

**Descripción:** El usuario necesita eliminar un pago registrado por error.

**Precondiciones:**
El usuario tiene permisos para eliminar pagos.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos.
2. Busca los pagos de un local.
3. Identifica el pago a eliminar y presiona el botón 'Eliminar'.
4. Confirma la eliminación en el diálogo.
5. El sistema elimina el pago y actualiza la tabla.

**Resultado esperado:**
El pago seleccionado ya no aparece en la tabla.

**Datos de prueba:**
id_pago_local: 98765

---



## Casos de Prueba

# Casos de Prueba: Consulta de Pagos (ConsPagos)

## Caso 1: Consulta de pagos de un local existente
- **Entrada:** id_local = 12345
- **Acción:** POST /api/execute { action: 'getPagosByLocal', params: { id_local: 12345 } }
- **Resultado esperado:** Respuesta success=true, data contiene lista de pagos, cada uno con campos completos.

## Caso 2: Consulta de pagos de un local inexistente
- **Entrada:** id_local = 999999
- **Acción:** POST /api/execute { action: 'getPagosByLocal', params: { id_local: 999999 } }
- **Resultado esperado:** Respuesta success=true, data=[], mensaje vacío o informativo.

## Caso 3: Agregar un pago válido
- **Entrada:**
  - id_local: 12345
  - axo: 2024
  - periodo: 6
  - fecha_pago: '2024-06-15'
  - oficina_pago: 2
  - caja_pago: 'A'
  - operacion_pago: 1001
  - importe_pago: 1500.00
  - folio: 'F1234'
  - id_usuario: 1
- **Acción:** POST /api/execute { action: 'addPago', params: {...} }
- **Resultado esperado:** success=true, data contiene id_pago_local generado.

## Caso 4: Agregar un pago con datos faltantes
- **Entrada:** Falta campo 'importe_pago'
- **Acción:** POST /api/execute { action: 'addPago', params: {...} }
- **Resultado esperado:** success=false, message indica campo requerido.

## Caso 5: Eliminar un pago existente
- **Entrada:** id_pago_local = 98765
- **Acción:** POST /api/execute { action: 'deletePago', params: { id_pago_local: 98765 } }
- **Resultado esperado:** success=true, data=true

## Caso 6: Eliminar un pago inexistente
- **Entrada:** id_pago_local = 999999
- **Acción:** POST /api/execute { action: 'deletePago', params: { id_pago_local: 999999 } }
- **Resultado esperado:** success=true, data=true (o success=false si se requiere validación estricta)



