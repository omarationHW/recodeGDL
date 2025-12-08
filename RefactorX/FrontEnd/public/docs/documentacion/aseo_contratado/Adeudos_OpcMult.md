# DocumentaciÃ³n TÃ©cnica: Adeudos_OpcMult

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario Adeudos_OpcMult (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (API RESTful)
- **Frontend:** Vue.js 3 (SPA, página independiente)
- **Base de Datos:** PostgreSQL 13+
- **API Unificada:** Un solo endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Stored Procedures:** Toda la lógica de negocio y reportes SQL se implementa en funciones y vistas PostgreSQL.

## 2. Flujo de Trabajo
1. **Carga inicial:**
   - El frontend solicita los catálogos de tipo de aseo y recaudadoras.
2. **Búsqueda de contrato:**
   - El usuario ingresa número de contrato y tipo de aseo.
   - El frontend consulta `/api/execute` con acción `buscar_contrato`.
   - Si existe, muestra datos y busca convenio asociado.
   - Si el contrato está vigente, muestra los adeudos pendientes (`listar_adeudos`).
3. **Selección de adeudos:**
   - El usuario selecciona uno o varios adeudos de la lista.
4. **Ejecución de opción:**
   - El usuario elige la opción (Pagar, Condonar, Cancelar, Prescribir) y llena los datos requeridos.
   - El frontend envía la acción `ejecutar_opcion` con los adeudos seleccionados y los datos de operación.
   - El backend ejecuta el SP `upd16_ade` para cada adeudo seleccionado.
   - Se retorna el resultado de cada operación.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listar_tipo_aseo|buscar_contrato|listar_recaudadoras|listar_cajas|listar_adeudos|ejecutar_opcion",
      ... parámetros ...
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [...],
      "message": "..."
    }
  }
  ```

## 4. Stored Procedures y Vistas
- **con16_detade_021:** Devuelve los adeudos vigentes de un contrato.
- **upd16_ade:** Actualiza el estado de un adeudo (pagado, condonado, cancelado, prescrito).
- **vw_contratos_detalle:** Vista para obtener detalle de contrato.
- **vw_convenios:** Vista para obtener convenio asociado a un contrato.

## 5. Validaciones y Seguridad
- Validar que el usuario tenga permisos para ejecutar la acción (por implementar en middleware Laravel).
- Validar que los datos requeridos estén presentes antes de ejecutar la acción.
- Todas las operaciones de actualización se ejecutan en transacción.

## 6. Consideraciones de Migración
- Los combos y catálogos Delphi se migran a endpoints de catálogo.
- El grid de selección múltiple se implementa como tabla con checkboxes en Vue.js.
- El SP `upd16_ade` encapsula toda la lógica de actualización de adeudos.
- El frontend es una página independiente, sin tabs ni componentes compartidos.

## 7. Estructura de Carpetas Sugerida
- `app/Http/Controllers/Api/AdeudosOpcMultController.php`
- `resources/js/pages/AdeudosOpcMult.vue`
- `database/migrations/` y `database/functions/` para SP y vistas

## 8. Ejemplo de Llamada API
```js
// Buscar contrato
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ eRequest: { action: 'buscar_contrato', num_contrato: 123, ctrol_aseo: 9 } })
})
```

## 9. Notas
- El endpoint es único y todas las acciones se discriminan por el campo `action`.
- El frontend debe manejar los estados de error y éxito según la respuesta.
- Los nombres de los campos y combos deben coincidir con los del backend.


## Casos de Prueba

## Casos de Prueba para Adeudos_OpcMult

### 1. Buscar contrato existente y listar adeudos
- **Entrada:** action: 'buscar_contrato', num_contrato: 12345, ctrol_aseo: 9
- **Esperado:** Responde con datos del contrato y status_vigencia = 'V'

### 2. Listar tipo de aseo y recaudadoras
- **Entrada:** action: 'listar_tipo_aseo'
- **Esperado:** Lista de tipos de aseo
- **Entrada:** action: 'listar_recaudadoras'
- **Esperado:** Lista de recaudadoras

### 3. Listar adeudos de contrato
- **Entrada:** action: 'listar_adeudos', control_contrato: 12345
- **Esperado:** Lista de adeudos vigentes

### 4. Ejecutar opción 'P' (Pagado) para varios adeudos
- **Entrada:** action: 'ejecutar_opcion', rows: [{control_contrato: 12345, periodo: '2024-06', ctrol_oper: 6}, ...], opcion: 'P', fecha: '2024-06-01', reca: 1, caja: 'A', operacion: 123456, folio_rcbo: 'RCB123', obs: 'Pago masivo', usuario: 1
- **Esperado:** Respuesta 'OK' para cada adeudo

### 5. Ejecutar opción 'S' (Condonar) para un adeudo
- **Entrada:** action: 'ejecutar_opcion', rows: [{control_contrato: 54321, periodo: '2024-06', ctrol_oper: 6}], opcion: 'S', fecha: '2024-06-02', reca: 2, caja: 'B', operacion: 0, folio_rcbo: 'COND001', obs: 'Condonación por convenio', usuario: 2
- **Esperado:** Respuesta 'OK'

### 6. Ejecutar opción 'C' (Cancelar) para varios adeudos
- **Entrada:** action: 'ejecutar_opcion', rows: [{control_contrato: 67890, periodo: '2024-06', ctrol_oper: 6}, ...], opcion: 'C', fecha: '2024-06-03', reca: 3, caja: 'C', operacion: 0, folio_rcbo: 'CANCEL01', obs: 'Cancelación administrativa', usuario: 3
- **Esperado:** Respuesta 'OK' para cada adeudo

### 7. Error: Intentar ejecutar opción sobre adeudo inexistente
- **Entrada:** action: 'ejecutar_opcion', rows: [{control_contrato: 99999, periodo: '2024-06', ctrol_oper: 6}], ...
- **Esperado:** Respuesta 'No existe adeudo vigente para el periodo'


## Casos de Uso

# Casos de Uso - Adeudos_OpcMult

**Categoría:** Form

## Caso de Uso 1: Caso de Uso 1: Dar de Pagado Adeudos Múltiples

**Descripción:** El usuario busca un contrato vigente, selecciona varios adeudos y los marca como pagados.

**Precondiciones:**
El contrato existe y tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar'.
3. El sistema muestra los datos del contrato y los adeudos vigentes.
4. El usuario selecciona varios adeudos en la tabla.
5. Elige la opción 'P - DAR DE PAGADO', ingresa fecha, recaudadora, caja, consecutivo de operación, folio y observaciones.
6. Presiona 'Ejecutar'.

**Resultado esperado:**
Los adeudos seleccionados cambian su estado a 'P' (Pagado) y desaparecen de la lista de adeudos vigentes.

**Datos de prueba:**
{ "num_contrato": 12345, "ctrol_aseo": 9, "opcion": "P", "fecha": "2024-06-01", "reca": 1, "caja": "A", "operacion": 123456, "folio_rcbo": "RCB123", "obs": "Pago masivo", "usuario": 1 }

---

## Caso de Uso 2: Caso de Uso 2: Condonar Adeudo Individual

**Descripción:** El usuario condona un adeudo específico de un contrato.

**Precondiciones:**
El contrato existe y tiene al menos un adeudo vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Selecciona un solo adeudo.
3. Elige la opción 'S - CONDONAR', ingresa fecha, recaudadora, caja, folio y observaciones.
4. Presiona 'Ejecutar'.

**Resultado esperado:**
El adeudo seleccionado cambia su estado a 'S' (Condonado).

**Datos de prueba:**
{ "num_contrato": 54321, "ctrol_aseo": 4, "opcion": "S", "fecha": "2024-06-02", "reca": 2, "caja": "B", "operacion": 0, "folio_rcbo": "COND001", "obs": "Condonación por convenio", "usuario": 2 }

---

## Caso de Uso 3: Caso de Uso 3: Cancelar Adeudos con Observaciones

**Descripción:** El usuario cancela varios adeudos y deja una observación.

**Precondiciones:**
El contrato existe y tiene adeudos vigentes.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Selecciona varios adeudos.
3. Elige la opción 'C - CANCELAR', ingresa fecha, recaudadora, caja, folio y observaciones.
4. Presiona 'Ejecutar'.

**Resultado esperado:**
Los adeudos seleccionados cambian su estado a 'C' (Cancelado) y la observación queda registrada.

**Datos de prueba:**
{ "num_contrato": 67890, "ctrol_aseo": 8, "opcion": "C", "fecha": "2024-06-03", "reca": 3, "caja": "C", "operacion": 0, "folio_rcbo": "CANCEL01", "obs": "Cancelación administrativa", "usuario": 3 }

---



---
**Componente:** `Adeudos_OpcMult.vue`
**MÃ³dulo:** `aseo_contratado`

