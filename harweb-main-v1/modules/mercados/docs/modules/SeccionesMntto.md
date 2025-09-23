# Documentación Técnica: Mantenimiento a Secciones (SeccionesMntto)

## Descripción General
Este módulo permite la administración del catálogo de secciones de mercados. Incluye alta, modificación y consulta de secciones. La solución está compuesta por:

- **Backend Laravel**: Un controlador con endpoint unificado `/api/execute` que recibe acciones y datos en formato eRequest/eResponse.
- **Frontend Vue.js**: Un componente de página independiente para la gestión de secciones.
- **Base de Datos PostgreSQL**: Stored procedures para inserción y actualización de secciones.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "action": "getAllSecciones|getSeccion|insertSeccion|updateSeccion",
    "data": { ... }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "success": true|false,
    "message": "Mensaje de resultado",
    "data": { ... }
  }
  ```

## Acciones Soportadas
- `getAllSecciones`: Lista todas las secciones.
- `getSeccion`: Obtiene una sección específica (`data.seccion`).
- `insertSeccion`: Inserta una nueva sección (`data.seccion`, `data.descripcion`).
- `updateSeccion`: Actualiza la descripción de una sección (`data.seccion`, `data.descripcion`).

## Validaciones
- `seccion`: Obligatorio, máximo 2 caracteres, mayúsculas.
- `descripcion`: Obligatorio, máximo 30 caracteres, mayúsculas.

## Stored Procedures
- `sp_insert_seccion(p_seccion, p_descripcion)`
- `sp_update_seccion(p_seccion, p_descripcion)`

## Seguridad
- Todas las operaciones deben estar autenticadas (middleware Laravel recomendado).
- Validación de datos en backend y frontend.

## Frontend
- Página independiente, sin tabs.
- Formulario para alta/modificación.
- Tabla de consulta.
- Mensajes de éxito/error.
- Navegación breadcrumb.

## Backend
- Controlador Laravel centralizado.
- Uso de stored procedures para operaciones de escritura.
- Manejo de errores y mensajes claros.

## Integración
- El frontend consume el endpoint `/api/execute` con la acción y datos correspondientes.
- El backend enruta la acción al stored procedure o consulta adecuada.

## Ejemplo de Request para Insertar
```json
{
  "action": "insertSeccion",
  "data": {
    "seccion": "AB",
    "descripcion": "ABASTOS"
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "message": "Sección insertada correctamente",
  "data": null
}
```

## Notas
- El endpoint puede ser extendido para otras entidades siguiendo el mismo patrón.
- El frontend puede ser adaptado para otros catálogos reutilizando la estructura.
