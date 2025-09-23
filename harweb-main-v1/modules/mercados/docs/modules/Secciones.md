# Documentación Técnica: Catálogo de Secciones (Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo permite la administración del catálogo de secciones de mercados. Incluye la visualización, alta, edición y eliminación de secciones. La arquitectura utiliza Laravel para el backend, Vue.js para el frontend y PostgreSQL como base de datos, empleando stored procedures para toda la lógica de negocio.

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` que recibe peticiones con el patrón `eRequest/eResponse`.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y formularios independientes.
- **Base de Datos:** PostgreSQL, toda la lógica encapsulada en stored procedures.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": {
      "action": "secciones.list|secciones.create|secciones.update|secciones.delete",
      "params": { ... }
    }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [...],
      "message": "..."
    }
  }
  ```

## Stored Procedures
- **sp_secciones_list:** Devuelve todas las secciones.
- **sp_secciones_create:** Inserta una nueva sección.
- **sp_secciones_update:** Actualiza la descripción de una sección.
- **sp_secciones_delete:** Elimina una sección.

## Seguridad
- Validación de parámetros en el controlador Laravel.
- Uso de transacciones y manejo de errores en los stored procedures.
- El frontend valida campos requeridos y longitud máxima.

## Flujo de Trabajo
1. El usuario accede a la página de Secciones.
2. El frontend carga la lista de secciones vía `secciones.list`.
3. El usuario puede agregar, editar o eliminar secciones.
4. Cada acción envía una petición a `/api/execute` con el action correspondiente.
5. El backend ejecuta el stored procedure y retorna el resultado.

## Integración
- El componente Vue.js puede ser montado en cualquier ruta, por ejemplo `/secciones`.
- El backend debe exponer el endpoint `/api/execute` y registrar el controlador.
- Los stored procedures deben estar creados en la base de datos PostgreSQL.

## Consideraciones
- No se permite duplicidad de claves de sección.
- No se permite eliminar una sección inexistente.
- Todas las operaciones son atómicas y devuelven mensajes claros de éxito o error.

## Ejemplo de Petición
```json
{
  "eRequest": {
    "action": "secciones.create",
    "params": {
      "seccion": "A1",
      "descripcion": "Zona Norte"
    }
  }
}
```

## Ejemplo de Respuesta
```json
{
  "eResponse": {
    "success": true,
    "data": [{"success": true, "message": "Sección creada correctamente."}],
    "message": ""
  }
}
```
