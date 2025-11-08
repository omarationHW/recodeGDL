# Documentación Técnica: Mantenimiento de Recargos (ta_16_recargos)

## Descripción General
Este módulo permite la administración de los recargos y multas mensuales asociados a periodos fiscales. Incluye la consulta, alta, modificación y eliminación de registros de recargos para cada mes de un año fiscal.

## Arquitectura
- **Backend:** Laravel Controller expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación y formularios completos.
- **Base de Datos:** Toda la lógica de negocio y validación reside en stored procedures PostgreSQL.
- **API:** El endpoint `/api/execute` recibe `{ action, params }` y responde con `{ success, data, message }`.

## API eRequest/eResponse
- **Endpoint:** `POST /api/execute`
- **Body:**
  ```json
  {
    "action": "recargos.list|recargos.create|recargos.update|recargos.delete",
    "params": { ... }
  }
  ```
- **Acciones:**
  - `recargos.list`: Listar recargos de un año `{ year }`
  - `recargos.create`: Crear recargo `{ year, month, porc_recargo, porc_multa }`
  - `recargos.update`: Actualizar recargo `{ year, month, porc_recargo, porc_multa }`
  - `recargos.delete`: Eliminar recargo `{ year, month }`
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [...],
    "message": "..."
  }
  ```

## Validaciones
- No se permite duplicar recargos para el mismo año-mes.
- No se permite eliminar o actualizar un recargo inexistente.
- Todos los campos son obligatorios y deben ser numéricos positivos.

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o Laravel Sanctum.
- Validar roles/privilegios para acceso a operaciones de escritura.

## Integración Vue.js
- El componente Vue.js consume el endpoint `/api/execute` usando fetch/AJAX.
- El formulario de alta y edición valida los campos antes de enviar.
- El listado se actualiza automáticamente tras operaciones exitosas.

## Navegación
- Cada formulario es una página independiente, sin tabs.
- Breadcrumbs opcionales para navegación.

## Errores y Mensajes
- Todos los errores de validación y de base de datos se devuelven en el campo `message`.
- El frontend muestra los mensajes de error o éxito en alertas visibles.

## Ejemplo de llamada
```json
{
  "action": "recargos.create",
  "params": {
    "year": 2024,
    "month": 6,
    "porc_recargo": 2.5,
    "porc_multa": 1.5
  }
}
```

## Ejemplo de respuesta
```json
{
  "success": true,
  "message": "Recargo creado correctamente"
}
```

# Base de Datos
- Tabla: `ta_16_recargos`
  - `aso_mes_recargo` DATE (PK)
  - `porc_recargo` NUMERIC
  - `porc_multa` NUMERIC

# Stored Procedures
- `sp_recargos_list(year)`
- `sp_recargos_create(year, month, porc_recargo, porc_multa)`
- `sp_recargos_update(year, month, porc_recargo, porc_multa)`
- `sp_recargos_delete(year, month)`

# Frontend
- Página Vue.js independiente
- Listado, alta, edición y eliminación de recargos
- Validación de campos y mensajes de error

# Backend
- Controlador Laravel único para todas las acciones
- Uso de validaciones y manejo de errores
- Llamadas a stored procedures PostgreSQL

# Pruebas
- Casos de uso y pruebas unitarias incluidas
