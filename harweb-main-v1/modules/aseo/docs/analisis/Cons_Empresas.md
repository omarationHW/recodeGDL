# Documentación Técnica: Consulta de Empresas (Cons_Empresas)

## Descripción General
Este módulo permite consultar el catálogo de empresas, filtrando por número, nombre o mostrando todas. Incluye exportación a Excel y utiliza un endpoint API unificado con patrón eRequest/eResponse. La lógica de negocio se implementa en stored procedures PostgreSQL.

## Arquitectura
- **Backend:** Laravel Controller (EmpresasController) con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación y exportación.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **API:** Patrón eRequest/eResponse, entrada y salida JSON.

## API
### Endpoint
`POST /api/execute`

#### Entrada
```json
{
  "eRequest": {
    "action": "search|byNumber|byName|all|list|export|listTiposEmp",
    "params": { ... }
  }
}
```

#### Salida
```json
{
  "eResponse": {
    "success": true|false,
    "data": [...],
    "message": "..."
  }
}
```

### Acciones soportadas
- `list` / `all`: Lista todas las empresas
- `byNumber`: Busca empresa por número y tipo
- `byName`: Busca empresas por nombre
- `search`: Búsqueda flexible (por número, nombre o todas)
- `export`: Devuelve los datos para exportar (el frontend genera el archivo)
- `listTiposEmp`: Lista los tipos de empresa (para combos)

## Stored Procedures
- `sp_empresas_list()`: Lista todas las empresas
- `sp_empresas_by_number(num_empresa, ctrol_emp)`: Busca empresa por número y tipo
- `sp_empresas_by_name(nombre)`: Busca empresas por nombre
- `sp_empresas_search(opcion, num_empresa, ctrol_emp, nombre)`: Búsqueda flexible
- `sp_tipos_emp_list()`: Lista tipos de empresa

## Seguridad
- Todas las consultas son de solo lectura.
- No se exponen datos sensibles.
- El endpoint puede ser protegido por middleware de autenticación si es necesario.

## Integración Frontend
- El componente Vue.js consume el endpoint `/api/execute` usando axios.
- El combo de tipos de empresa se llena con `listTiposEmp`.
- La búsqueda se realiza según la opción seleccionada.
- Exportación a Excel se realiza en frontend (descarga CSV).

## Consideraciones
- El frontend debe manejar errores y mostrar mensajes amigables.
- El backend debe validar los parámetros recibidos.
- El stored procedure `sp_empresas_search` permite búsquedas flexibles y seguras.

# Diagrama de Flujo
1. Usuario selecciona opción de búsqueda y llena campos.
2. Al presionar Buscar, Vue envía eRequest al endpoint.
3. Laravel Controller ejecuta el stored procedure correspondiente.
4. El resultado se devuelve en eResponse.
5. Vue muestra los resultados en tabla.
6. Si se presiona Exportar, Vue genera y descarga el CSV.

# Ejemplo de eRequest/eResponse
## Buscar por número
```json
{
  "eRequest": {
    "action": "byNumber",
    "params": {
      "num_empresa": 123,
      "ctrol_emp": 9
    }
  }
}
```

## Buscar por nombre
```json
{
  "eRequest": {
    "action": "byName",
    "params": {
      "nombre": "ACME"
    }
  }
}
```

## Buscar todas
```json
{
  "eRequest": {
    "action": "all",
    "params": {}
  }
}
```

# Pruebas y Validación
- Todos los endpoints y stored procedures deben ser probados con datos reales y casos límite.
- El frontend debe validar que los combos y campos estén correctamente sincronizados.

# Mantenimiento
- Para agregar nuevos filtros, modificar el stored procedure `sp_empresas_search`.
- Para agregar columnas, modificar el SP y el frontend.
