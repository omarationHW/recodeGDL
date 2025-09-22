# Documentación Técnica: Migración ABC_Tipos_Emp Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Vue.js SPA, cada formulario es una página independiente
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures

## API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Request**:
  - `action`: string (ej: 'list_tipos_emp', 'create_tipos_emp', ...)
  - `payload`: objeto con los parámetros necesarios
- **Response**:
  - `success`: boolean
  - `data`: resultado de la operación
  - `message`: mensaje de error o éxito

## Métodos soportados (acciones)
- `list_tipos_emp`: Lista todos los tipos de empresa
- `get_tipos_emp`: Obtiene un tipo de empresa por su clave
- `create_tipos_emp`: Crea un nuevo tipo de empresa
- `update_tipos_emp`: Actualiza un tipo de empresa
- `delete_tipos_emp`: Elimina un tipo de empresa (si no tiene empresas asociadas)

## Stored Procedures
- Toda la lógica de negocio y validación reside en los SPs de PostgreSQL
- Los SPs devuelven siempre un resultado estructurado (éxito, mensaje, datos)

## Vue.js
- Página independiente `/tipos-emp` (ruta sugerida)
- Tabla con listado, botones de alta, edición y baja
- Formularios modales para alta/edición
- Mensajes de error y éxito
- Navegación breadcrumb

## Seguridad
- Validación de datos en backend y frontend
- Eliminar solo si no hay empresas asociadas

## Consideraciones de Migración
- El flujo de Delphi se respeta: recarga de tabla tras cada operación
- No se usan tabs ni componentes tabulares: cada formulario es una página
- El endpoint es único y centralizado

## Ejemplo de Request
```json
{
  "action": "create_tipos_emp",
  "payload": {
    "ctrol_emp": 10,
    "tipo_empresa": "P",
    "descripcion": "Privada"
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": [{"success": true, "message": "Tipo de empresa creado correctamente"}],
  "message": ""
}
```

## Validaciones
- No se permite duplicar `ctrol_emp`
- No se puede eliminar si existen empresas asociadas
- Todos los campos son obligatorios

## Errores comunes
- Si se intenta eliminar un tipo con empresas asociadas, el SP devuelve error y el frontend lo muestra

## Extensibilidad
- El patrón eRequest/eResponse permite agregar más acciones sin cambiar el endpoint
- Los SPs pueden evolucionar sin modificar el frontend
