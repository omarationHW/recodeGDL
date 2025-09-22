# Documentación Técnica: Catálogo de Unidades de Recolección (Mannto_Und_Recolec)

## Descripción General
Este módulo permite la administración del catálogo de Unidades de Recolección, incluyendo operaciones de alta, baja, modificación y consulta. La lógica de negocio se implementa en stored procedures PostgreSQL, expuesta a través de un endpoint API unificado `/api/execute` bajo el patrón eRequest/eResponse. El frontend es una página Vue.js independiente.

## Arquitectura
- **Backend:** Laravel Controller (`ManntoUndRecolecController`) expone un endpoint `/api/execute` que recibe `{ action, data }` y despacha a los stored procedures correspondientes.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con CRUD y navegación.
- **Base de Datos:** Toda la lógica de negocio reside en stored procedures PostgreSQL.

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "list|insert|update|delete|get",
    "data": { ...campos según acción... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "message": "Mensaje de resultado",
    "data": [ ... ]
  }
  ```

## Acciones Soportadas
- `list`: Lista todas las unidades para un ejercicio.
- `get`: Obtiene una unidad por su control.
- `insert`: Inserta una nueva unidad (requiere ejercicio, clave, descripción, costo, costo_exed).
- `update`: Modifica una unidad existente (requiere ctrol_recolec, descripción, costo, costo_exed).
- `delete`: Elimina una unidad (requiere ctrol_recolec, sólo si no tiene contratos asociados).

## Validaciones
- No se permite duplicar clave para el mismo ejercicio.
- No se permite eliminar unidades con contratos asociados.
- Todos los campos requeridos deben estar presentes y válidos.

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validaciones adicionales pueden implementarse en el controlador Laravel.

## Integración Frontend
- El componente Vue.js consume el endpoint `/api/execute` para todas las operaciones.
- El formulario de alta y edición valida los campos antes de enviar.
- Mensajes de error y éxito se muestran al usuario.

## Ejemplo de Request/Response
### Alta de Unidad
```json
POST /api/execute
{
  "action": "insert",
  "data": {
    "ejercicio": 2024,
    "cve": "A",
    "descripcion": "Unidad tipo A",
    "costo": 123.45,
    "costo_exed": 200.00
  }
}
```
**Response:**
```json
{
  "success": true,
  "message": "Unidad creada correctamente",
  "data": { ... }
}
```

## Stored Procedures
- Toda la lógica de negocio reside en los SPs documentados en este entregable.
- Los SPs devuelven mensajes de éxito/error y datos relevantes.

## Consideraciones de Migración
- Los nombres de campos y lógica replican el comportamiento Delphi original.
- El control de errores y mensajes se centraliza en los SPs y el controlador.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- El frontend puede extenderse fácilmente para nuevos campos o validaciones.
