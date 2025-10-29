# Documentación Técnica: Catálogo de Empresas (ABC_Empresas)

## Arquitectura General
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente (no tabs)
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **API:** Todas las operaciones (listar, crear, editar, eliminar, buscar) se realizan mediante el endpoint `/api/execute` con un campo `action` y un campo `payload`.

## Endpoints
### `/api/execute` (POST)
- **action:** string (ej: 'list', 'get', 'create', 'update', 'delete', 'search', 'list_tipos_emp')
- **payload:** objeto con los parámetros necesarios para la acción

#### Ejemplo de request:
```json
{
  "action": "create",
  "payload": {
    "ctrol_emp": 9,
    "descripcion": "EMPRESA NUEVA",
    "representante": "JUAN PEREZ"
  }
}
```

#### Ejemplo de response:
```json
{
  "success": true,
  "data": { "num_empresa": 123, "ctrol_emp": 9 },
  "message": ""
}
```

## Stored Procedures
- Toda la lógica de negocio y validaciones críticas están en stored procedures PostgreSQL.
- El controlador Laravel invoca los SP usando DB::select o DB::statement según corresponda.

## Frontend (Vue.js)
- Página independiente `/empresas`.
- Tabla con listado de empresas y acciones (editar, eliminar).
- Modal para alta/edición.
- Búsqueda por nombre.
- Llama a `/api/execute` con el action adecuado.
- Carga tipos de empresa para el combo desde el backend.

## Seguridad
- Validaciones de datos en backend y frontend.
- No se permite eliminar empresas con contratos asociados.

## Consideraciones
- El endpoint es único y multipropósito.
- El frontend es desacoplado y puede ser SPA o tradicional.
- El backend puede extenderse para otros catálogos usando el mismo patrón.

## Estructura de la tabla `ta_16_empresas`
- num_empresa (int, PK)
- ctrol_emp (int, FK a tipos_emp)
- descripcion (varchar)
- representante (varchar)

## Estructura de la tabla `ta_16_tipos_emp`
- ctrol_emp (int, PK)
- tipo_empresa (char)
- descripcion (varchar)

## Estructura de la tabla `ta_16_contratos` (relación para borrado seguro)
- num_empresa (int, FK)
- ctrol_emp (int, FK)

## Flujo de operaciones
1. El frontend envía un request a `/api/execute` con el action y payload.
2. El controlador Laravel despacha la acción y llama el stored procedure correspondiente.
3. El resultado se retorna en formato estándar eResponse.
4. El frontend actualiza la UI según el resultado.

## Errores comunes
- Intentar eliminar una empresa con contratos asociados retorna error amigable.
- Validaciones de campos obligatorios en ambos lados.

## Extensibilidad
- El patrón permite agregar otros catálogos fácilmente.
- Los stored procedures pueden ser versionados y auditados.

