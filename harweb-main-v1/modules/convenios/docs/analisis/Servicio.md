# Documentación Técnica: Migración de Formulario 'Servicio' (Obra Pública)

## Arquitectura General
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js SPA (Single Page Application)
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de datos:** PostgreSQL, lógica de negocio en stored procedures

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|show|create|update|delete|report",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## Acciones soportadas
- `list`: Lista todos los servicios
- `show`: Muestra un servicio por ID
- `create`: Crea un nuevo servicio
- `update`: Actualiza un servicio existente
- `delete`: Elimina un servicio
- `report`: Devuelve el catálogo completo para impresión

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o session según la política de la aplicación.
- Validar que los campos requeridos estén presentes y sean del tipo correcto.

## Validaciones
- `descripcion`: Obligatorio, máximo 50 caracteres
- `serv_obra94`: Opcional, numérico
- `servicio`: Obligatorio para update/delete/show

## Stored Procedures
- Toda la lógica de acceso y manipulación de datos está en stored procedures PostgreSQL.
- El controlador Laravel solo invoca los SP y retorna el resultado.

## Vue.js
- Página independiente (no tab, no modal global)
- Tabla con listado, botones de agregar/editar/eliminar
- Formulario modal para alta/modificación
- Mensajes de éxito/error
- Navegación breadcrumb

## Migración de Datos
- Si se requiere migrar datos desde otra base, se recomienda usar scripts ETL externos.

## Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.

# Estructura de la Tabla
```sql
CREATE TABLE ta_17_servicios (
  servicio smallint PRIMARY KEY,
  descripcion varchar(50) NOT NULL,
  serv_obra94 smallint
);
```

# Ejemplo de llamada API
```json
POST /api/execute
{
  "eRequest": {
    "action": "create",
    "data": {
      "descripcion": "Pavimentación Calle 2024",
      "serv_obra94": 94
    }
  }
}
```

# Respuesta esperada
```json
{
  "eResponse": {
    "success": true,
    "data": {
      "servicio": 123,
      "descripcion": "Pavimentación Calle 2024",
      "serv_obra94": 94
    }
  }
}
```

# Notas
- El frontend debe manejar los mensajes de error y mostrar alertas amigables.
- El backend debe manejar excepciones y retornar mensajes claros.
