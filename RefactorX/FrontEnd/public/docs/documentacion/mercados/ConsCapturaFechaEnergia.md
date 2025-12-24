# ConsCapturaFechaEnergia

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: ConsCapturaFechaEnergia

## Descripción General
Este módulo permite consultar y eliminar pagos capturados de energía eléctrica por fecha, oficina, caja y operación. Incluye:
- Consulta de pagos por filtros
- Eliminación de pagos seleccionados (con regeneración de adeudos si corresponde)
- Listado de oficinas y cajas

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** PostgreSQL con stored procedures

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Body:**
  ```json
  {
    "action": "getPagosByFecha", // o 'deletePagosEnergia', 'getOficinas', 'getCajasByOficina'
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [...],
    "message": ""
  }
  ```

## Stored Procedures
- `sp_get_pagos_energia_fecha`: Devuelve pagos por fecha/oficina/caja/operación
- `sp_delete_pagos_energia`: Borra pagos seleccionados y regenera adeudos si corresponde

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel)
- El userId se obtiene del usuario autenticado

## Validaciones
- Todos los parámetros son validados en backend
- El frontend valida que los filtros estén completos antes de buscar
- Solo usuarios autorizados pueden borrar pagos

## Flujo de Eliminación
1. El usuario selecciona uno o varios pagos
2. Se envía la lista de IDs al backend
3. Por cada pago:
   - Si no existe adeudo para ese periodo, se regenera
   - Se elimina el pago
4. Se devuelve el resultado

## Navegación
- Cada formulario es una página independiente
- Breadcrumb incluido
- No se usan tabs

## Estructura de Carpetas
- `app/Http/Controllers/ConsCapturaFechaEnergiaController.php`
- `resources/js/pages/ConsCapturaFechaEnergia.vue`
- `database/migrations/` y `database/procedures/` para los SP

## Ejemplo de Request
```json
{
  "action": "getPagosByFecha",
  "params": {
    "fecha_pago": "2024-06-01",
    "oficina_pago": 1,
    "caja_pago": "A",
    "operacion_pago": 12345
  }
}
```

## Ejemplo de Respuesta
```json
{
  "success": true,
  "data": [ ... ],
  "message": ""
}
```

# Notas de Migración
- Todas las operaciones SQL se migran a stored procedures PostgreSQL
- El frontend nunca accede directo a la base de datos
- El endpoint `/api/execute` es el único punto de entrada
- El componente Vue es una página completa, sin tabs


## Casos de Uso

# Casos de Uso - ConsCapturaFechaEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Pagos de Energía por Fecha y Oficina

**Descripción:** El usuario consulta todos los pagos capturados de energía eléctrica para una fecha, oficina, caja y operación específica.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de consulta.
2. Selecciona la fecha, oficina, caja y operación.
3. Presiona 'Buscar'.
4. El sistema muestra la lista de pagos encontrados.

**Resultado esperado:**
Se muestra una tabla con los pagos capturados que cumplen los filtros.

**Datos de prueba:**
{ "fecha_pago": "2024-06-01", "oficina_pago": 1, "caja_pago": "A", "operacion_pago": 12345 }

---

## Caso de Uso 2: Eliminación de Pagos Seleccionados

**Descripción:** El usuario selecciona uno o varios pagos y los elimina. El sistema regenera el adeudo si corresponde.

**Precondiciones:**
El usuario está autenticado y tiene permisos de eliminación.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de pagos.
2. Selecciona uno o varios pagos en la tabla.
3. Presiona 'Borrar Pago(s)'.
4. Confirma la acción.
5. El sistema elimina los pagos y regenera adeudos si es necesario.

**Resultado esperado:**
Los pagos seleccionados son eliminados y los adeudos se regeneran si no existen.

**Datos de prueba:**
{ "pagos_ids": [101, 102], "fecha_pago": "2024-06-01", "oficina_pago": 1, "operacion_pago": 12345 }

---

## Caso de Uso 3: Carga de Cajas por Oficina

**Descripción:** El usuario selecciona una oficina y el sistema carga automáticamente las cajas disponibles.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario selecciona una oficina en el filtro.
2. El sistema consulta y muestra las cajas asociadas a esa oficina.

**Resultado esperado:**
El select de cajas se llena con las cajas correspondientes a la oficina seleccionada.

**Datos de prueba:**
{ "oficina": 1 }

---



## Casos de Prueba

# Casos de Prueba: ConsCapturaFechaEnergia

## Caso 1: Consulta de Pagos Existentes
- **Entrada:** fecha_pago=2024-06-01, oficina_pago=1, caja_pago='A', operacion_pago=12345
- **Acción:** Buscar pagos
- **Resultado esperado:** Lista de pagos mostrada, success=true

## Caso 2: Consulta sin Resultados
- **Entrada:** fecha_pago=2024-06-01, oficina_pago=99, caja_pago='Z', operacion_pago=99999
- **Acción:** Buscar pagos
- **Resultado esperado:** Lista vacía, success=true

## Caso 3: Eliminación de Pagos Existentes
- **Entrada:** pagos_ids=[101,102], fecha_pago=2024-06-01, oficina_pago=1, operacion_pago=12345
- **Acción:** Borrar pagos
- **Resultado esperado:** success=true, pagos eliminados, adeudos regenerados si corresponde

## Caso 4: Eliminación de Pagos No Existentes
- **Entrada:** pagos_ids=[9999], fecha_pago=2024-06-01, oficina_pago=1, operacion_pago=12345
- **Acción:** Borrar pagos
- **Resultado esperado:** success=true, sin error, no afecta datos

## Caso 5: Carga de Cajas por Oficina
- **Entrada:** oficina=1
- **Acción:** Consultar cajas
- **Resultado esperado:** Lista de cajas asociadas a la oficina 1

## Caso 6: Validación de Permisos
- **Entrada:** Usuario sin permisos de eliminación
- **Acción:** Intentar borrar pagos
- **Resultado esperado:** success=false, mensaje de error de permisos



