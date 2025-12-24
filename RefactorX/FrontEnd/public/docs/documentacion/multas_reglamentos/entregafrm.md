# Documentación: entregafrm

## Análisis Técnico

# Documentación Técnica: Entrega de Requerimientos por Ejecutor

## Descripción General
Este módulo permite la asignación, consulta, entrega y desasignación de requerimientos fiscales a ejecutores, así como la impresión de la relación de entrega. La migración se realizó desde Delphi a Laravel + Vue.js + PostgreSQL, centralizando la lógica en stored procedures y un endpoint API unificado.

## Arquitectura
- **Backend:** Laravel 10+, PostgreSQL 13+
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **API:** Endpoint único `/api/execute` con patrón eRequest/eResponse
- **Stored Procedures:** Toda la lógica de negocio y reportes en PostgreSQL

## Flujo Principal
1. **Búsqueda de ejecutor**: Por número o nombre.
2. **Selección de ejecutor**: Muestra datos y permite filtrar requerimientos por recaudadora y fecha.
3. **Listado de requerimientos**: Visualiza los requerimientos asignados al ejecutor en la fecha y recaudadora seleccionada.
4. **Asignación/Desasignación**: Permite asignar o quitar requerimientos a ejecutores (con actualización de contadores).
5. **Impresión**: Genera los datos para impresión de la relación de entrega.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": { ... },
    "message": "..."
  }
  ```

### Acciones soportadas
- `buscar_ejecutor`: Busca ejecutores por número o nombre.
- `listar_requerimientos`: Lista requerimientos asignados a ejecutor/fecha/recaudadora.
- `asignar_requerimiento`: Asigna un requerimiento a ejecutor.
- `quitar_requerimiento`: Quita la asignación de un requerimiento.
- `imprimir_entrega`: Devuelve datos para impresión de la relación de entrega.

## Seguridad
- Autenticación Laravel Sanctum/JWT recomendada.
- Validación de permisos en backend.

## Consideraciones de Migración
- Todas las operaciones de asignación/desasignación usan stored procedures para mantener la lógica transaccional.
- El frontend no usa tabs: cada formulario es una página Vue independiente.
- El endpoint `/api/execute` es el único punto de entrada para todas las operaciones.

## Estructura de la Base de Datos
- Tablas principales: `ejecutor`, `reqpredial`, `detejecutor`.
- Los contadores de asignados/pendientes se mantienen en `detejecutor`.

## Ejemplo de Uso
### Buscar ejecutor por nombre
```json
{
  "action": "buscar_ejecutor",
  "params": { "criterio": "JUAN PEREZ", "tipo": "nombre" }
}
```

### Listar requerimientos asignados
```json
{
  "action": "listar_requerimientos",
  "params": { "cveejecutor": 123, "recaud": 1, "fecha": "2024-06-01" }
}
```

### Asignar requerimiento
```json
{
  "action": "asignar_requerimiento",
  "params": { "folio": 456, "recaud": 1, "cveejecutor": 123, "fecha": "2024-06-01" }
}
```

### Quitar requerimiento
```json
{
  "action": "quitar_requerimiento",
  "params": { "folio": 456, "recaud": 1, "cveejecutor": 123 }
}
```

## Validaciones
- No se puede asignar requerimientos ya pagados/cancelados.
- No se puede quitar requerimientos no asignados.
- Los contadores de asignados/pendientes nunca bajan de cero.

## Impresión
- El endpoint `imprimir_entrega` devuelve los datos necesarios para generar el PDF en frontend o backend.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.

## Casos de Uso

# Casos de Uso - entregafrm

**Categoría:** Form

## Caso de Uso 1: Asignación de requerimientos a ejecutor

**Descripción:** Un usuario administrativo busca un ejecutor y le asigna un requerimiento fiscal para una fecha y recaudadora específica.

**Precondiciones:**
El ejecutor existe y tiene capacidad para recibir requerimientos.

**Pasos a seguir:**
[
  "El usuario ingresa el número o nombre del ejecutor y realiza la búsqueda.",
  "Selecciona el ejecutor de la lista.",
  "Indica la recaudadora y la fecha de entrega.",
  "Visualiza los requerimientos disponibles.",
  "Selecciona un requerimiento y lo asigna.",
  "El sistema actualiza los contadores de asignados/pendientes."
]

**Resultado esperado:**
El requerimiento queda asignado al ejecutor y aparece en la lista de entregados.

**Datos de prueba:**
{
  "ejecutor": {
    "cveejecutor": 101,
    "nombre": "JUAN PEREZ"
  },
  "recaud": 1,
  "fecha": "2024-06-01",
  "folio": 5001
}

---

## Caso de Uso 2: Quitar requerimiento de ejecutor

**Descripción:** Un usuario necesita quitar la asignación de un requerimiento a un ejecutor por error.

**Precondiciones:**
El requerimiento está asignado y no ha sido practicado ni pagado.

**Pasos a seguir:**
[
  "El usuario busca el ejecutor y filtra los requerimientos asignados.",
  "Selecciona el requerimiento a quitar.",
  "Confirma la acción.",
  "El sistema desasigna el requerimiento y actualiza los contadores."
]

**Resultado esperado:**
El requerimiento ya no aparece como asignado al ejecutor.

**Datos de prueba:**
{
  "ejecutor": {
    "cveejecutor": 101
  },
  "recaud": 1,
  "folio": 5001
}

---

## Caso de Uso 3: Impresión de relación de entrega

**Descripción:** El usuario imprime la relación de entrega de requerimientos para un ejecutor en una fecha y recaudadora.

**Precondiciones:**
Existen requerimientos asignados al ejecutor en la fecha y recaudadora seleccionada.

**Pasos a seguir:**
[
  "El usuario busca y selecciona el ejecutor.",
  "Indica la recaudadora y la fecha.",
  "Solicita la impresión.",
  "El sistema devuelve los datos para impresión."
]

**Resultado esperado:**
Se genera un PDF o vista imprimible con la relación de entrega.

**Datos de prueba:**
{
  "ejecutor": {
    "cveejecutor": 101
  },
  "recaud": 1,
  "fecha": "2024-06-01"
}

---

## Casos de Prueba

# Casos de Prueba: Entrega de Requerimientos por Ejecutor

## 1. Búsqueda de ejecutor por número
- **Entrada:** criterio=101, tipo=numero
- **Esperado:** Devuelve ejecutor con cveejecutor=101

## 2. Búsqueda de ejecutor por nombre
- **Entrada:** criterio="JUAN PEREZ", tipo=nombre
- **Esperado:** Devuelve lista de ejecutores que coincidan

## 3. Listar requerimientos asignados
- **Entrada:** cveejecutor=101, recaud=1, fecha="2024-06-01"
- **Esperado:** Lista de requerimientos asignados a ese ejecutor en esa fecha y recaudadora

## 4. Asignar requerimiento
- **Entrada:** folio=5001, recaud=1, cveejecutor=101, fecha="2024-06-01"
- **Esperado:** El requerimiento queda asignado y los contadores se actualizan

## 5. Quitar requerimiento
- **Entrada:** folio=5001, recaud=1, cveejecutor=101
- **Esperado:** El requerimiento se desasigna y los contadores se actualizan

## 6. Impresión de entrega
- **Entrada:** cveejecutor=101, recaud=1, fecha="2024-06-01"
- **Esperado:** Devuelve datos para impresión (ejecutor y requerimientos)

## 7. Validación de no asignar requerimiento pagado/cancelado
- **Entrada:** folio de requerimiento ya pagado/cancelado
- **Esperado:** Error y no se realiza la asignación

## 8. Validación de no quitar requerimiento no asignado
- **Entrada:** folio de requerimiento sin asignar
- **Esperado:** Error y no se realiza la desasignación

## Integración con Backend

> ⚠️ Pendiente de documentar

