# Documentación Técnica: Consulta de Tipos de Aseo (Cons_Tipos_Aseo)

## Descripción General
Este módulo permite consultar el catálogo de Tipos de Aseo desde la base de datos PostgreSQL, mostrando los resultados en una tabla ordenable y permitiendo la exportación a Excel. La arquitectura sigue el patrón API unificada (eRequest/eResponse) y desacopla completamente el frontend (Vue.js) del backend (Laravel).

## Arquitectura
- **Backend:** Laravel Controller (ConsTiposAseoController)
- **Frontend:** Vue.js Single Page Component (ConsTiposAseoPage.vue)
- **Base de datos:** PostgreSQL, con stored procedures para lógica de negocio
- **API:** Endpoint único `/api/execute` que recibe eRequest y retorna eResponse

## Flujo de Datos
1. El usuario accede a la página de consulta de Tipos de Aseo.
2. El componente Vue envía una petición POST a `/api/execute` con el action `cons_tipos_aseo_list` y el campo de ordenamiento.
3. El backend ejecuta el stored procedure `sp_cons_tipos_aseo_list` y retorna los datos en formato JSON.
4. El usuario puede cambiar el orden y volver a consultar, o exportar a Excel (acción que puede ser implementada como descarga de archivo).

## API eRequest/eResponse
- **eRequest:**
  - `action`: Nombre de la acción (ej: `cons_tipos_aseo_list`)
  - `params`: Parámetros para la acción (ej: `{ order: 'descripcion' }`)
- **eResponse:**
  - `success`: true/false
  - `data`: Datos devueltos (array de objetos)
  - `message`: Mensaje de error o información

## Seguridad
- El controlador valida el campo de ordenamiento para evitar SQL Injection.
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## Stored Procedures
- Toda la lógica de consulta y exportación está en stored procedures PostgreSQL.
- El procedimiento de exportación retorna los mismos datos; la generación del archivo Excel se realiza en el backend PHP.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- El frontend puede ser reutilizado para otros catálogos cambiando el action y los campos.

## Integración
- El componente Vue debe estar registrado en el router como página independiente.
- El backend debe exponer el endpoint `/api/execute` y registrar el controlador en `routes/api.php`.

## Ejemplo de eRequest
```json
{
  "eRequest": {
    "action": "cons_tipos_aseo_list",
    "params": { "order": "descripcion" }
  }
}
```

## Ejemplo de eResponse
```json
{
  "eResponse": {
    "success": true,
    "data": [
      { "ctrol_aseo": 1, "tipo_aseo": "O", "descripcion": "Ordinario" },
      ...
    ],
    "message": ""
  }
}
```

## Consideraciones
- El frontend muestra mensajes de error si la consulta falla.
- La exportación a Excel puede implementarse como descarga directa o generación asíncrona.
