# Cuotas de Energía Eléctrica - Documentación Técnica

## Descripción General
Este módulo permite la gestión de las cuotas de energía eléctrica (ta_11_kilowhatts) en el sistema de mercados municipales. Incluye la consulta, alta, modificación y eliminación de cuotas, así como la visualización de historial y usuario responsable.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js independiente como página completa.
- **Base de Datos:** PostgreSQL con stored procedures para toda la lógica de negocio y acceso a datos.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "list|create|update|delete|get",
    "params": { ... },
    "module": "cuotas_energia"
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ] | { ... },
    "message": "..."
  }
  ```

## Métodos Disponibles
- `list`: Lista todas las cuotas.
- `create`: Crea una nueva cuota. Requiere `axo`, `periodo`, `importe`.
- `update`: Modifica una cuota existente. Requiere `id_kilowhatts`, `axo`, `periodo`, `importe`.
- `delete`: Elimina una cuota. Requiere `id_kilowhatts`.
- `get`: Obtiene una cuota por ID. Requiere `id_kilowhatts`.

## Validaciones
- El importe debe ser mayor a 0.
- El año (`axo`) debe ser razonable (ej. >= 2000).
- El periodo debe estar entre 1 y 12.

## Seguridad
- El usuario autenticado se toma de la sesión Laravel y se registra en los movimientos.
- Solo usuarios autorizados pueden crear, modificar o eliminar cuotas.

## Frontend
- Página Vue.js independiente, sin tabs.
- Tabla con paginación, búsqueda y acciones de editar/eliminar.
- Formulario para alta/modificación con validación en frontend y backend.
- Mensajes de éxito/error claros.

## Stored Procedures
- Toda la lógica de acceso y validación reside en los SPs de PostgreSQL.
- No se permite acceso directo a tablas desde el backend.

## Ejemplo de Llamada API
```js
// Listar cuotas
axios.post('/api/execute', { action: 'list', module: 'cuotas_energia' })

// Crear cuota
axios.post('/api/execute', { action: 'create', module: 'cuotas_energia', params: { axo: 2024, periodo: 6, importe: 123.456789 } })
```

## Manejo de Errores
- Los errores de validación y de base de datos se devuelven en el campo `message`.
- El frontend muestra los mensajes en pantalla.

## Integración
- El componente Vue puede ser usado en cualquier router-view.
- El backend puede ser extendido para otros catálogos usando el mismo patrón.

## Seguridad y Auditoría
- Todos los cambios quedan registrados con el usuario responsable y la fecha/hora.
- Se recomienda auditar los cambios críticos en una tabla de auditoría adicional.
