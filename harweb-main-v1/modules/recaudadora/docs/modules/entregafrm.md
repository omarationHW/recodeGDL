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
