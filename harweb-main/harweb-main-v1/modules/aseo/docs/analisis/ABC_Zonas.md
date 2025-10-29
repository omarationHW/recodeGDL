# Documentación Técnica: Catálogo de Zonas (ABC_Zonas)

## Descripción General
Este módulo permite la administración del catálogo de zonas (alta, baja, modificación, consulta) migrado desde Delphi a Laravel + Vue.js + PostgreSQL. Toda la lógica de negocio se implementa en stored procedures y se expone a través de un endpoint API unificado.

## Arquitectura
- **Backend**: Laravel Controller (ZonasController) con endpoint único `/api/execute`.
- **Frontend**: Componente Vue.js de página completa, sin tabs.
- **Base de Datos**: PostgreSQL con stored procedures para CRUD.
- **API**: Patrón eRequest/eResponse, donde el campo `action` define la operación y `payload` los datos.

## Endpoints
- **POST /api/execute**
  - **Body**:
    - `action`: string (ej: 'zonas.list', 'zonas.create', 'zonas.update', 'zonas.delete', 'zonas.get')
    - `payload`: objeto con los parámetros necesarios
  - **Response**:
    - `status`: 'success' | 'error'
    - `message`: string
    - `data`: resultado de la operación

## Stored Procedures
- `sp_zonas_create(zona, sub_zona, descripcion)`
- `sp_zonas_update(ctrol_zona, zona, sub_zona, descripcion)`
- `sp_zonas_delete(ctrol_zona)`

## Validaciones
- No se permite crear zonas duplicadas (zona + sub_zona únicos).
- No se puede eliminar una zona si existen empresas relacionadas.
- Todos los campos son obligatorios en alta y edición.

## Seguridad
- Validación de datos en backend (Laravel) y frontend (Vue).
- Manejo de errores y mensajes claros.

## Navegación
- Cada formulario es una página independiente.
- Breadcrumb para navegación contextual.

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otros catálogos siguiendo el mismo patrón.

## Ejemplo de Request
```json
{
  "action": "zonas.create",
  "payload": {
    "zona": 1,
    "sub_zona": 2,
    "descripcion": "Zona Norte"
  }
}
```

## Ejemplo de Response
```json
{
  "status": "success",
  "message": "Zona creada",
  "data": [{ "ctrol_zona": 5, "zona": 1, "sub_zona": 2, "descripcion": "Zona Norte" }]
}
```
