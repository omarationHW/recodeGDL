# Documentación Técnica: Cons_Empresas

## Análisis

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


## Casos de Uso

# Casos de Uso - Cons_Empresas

**Categoría:** Form

## Caso de Uso 1: Consulta de empresa por número y tipo

**Descripción:** El usuario desea consultar una empresa específica ingresando su número y tipo.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el número y tipo de la empresa.

**Pasos a seguir:**
1. Selecciona 'Por Número' en la opción de búsqueda.
2. Ingresa el número de empresa y selecciona el tipo de empresa.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra la empresa correspondiente en la tabla con todos sus datos.

**Datos de prueba:**
{ "num_empresa": 123, "ctrol_emp": 9 }

---

## Caso de Uso 2: Búsqueda de empresas por nombre parcial

**Descripción:** El usuario busca todas las empresas cuyo nombre contiene una palabra clave.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Selecciona 'Por Nombre' en la opción de búsqueda.
2. Ingresa una palabra clave (ejemplo: 'ACME').
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se listan todas las empresas cuyo nombre contiene la palabra clave.

**Datos de prueba:**
{ "nombre": "ACME" }

---

## Caso de Uso 3: Exportar listado completo de empresas a Excel

**Descripción:** El usuario desea exportar el catálogo completo de empresas a un archivo Excel.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Selecciona 'Todas' en la opción de búsqueda.
2. Presiona el botón 'Buscar' para mostrar todas las empresas.
3. Presiona el botón 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo CSV/Excel con todos los datos de empresas.

**Datos de prueba:**
{}

---



## Casos de Prueba

# Casos de Prueba: Consulta de Empresas

## Caso 1: Consulta por número y tipo
- **Entrada:**
  - action: byNumber
  - params: { num_empresa: 123, ctrol_emp: 9 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene exactamente una empresa con num_empresa=123 y ctrol_emp=9

## Caso 2: Consulta por nombre parcial
- **Entrada:**
  - action: byName
  - params: { nombre: "ACME" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene una o más empresas cuyo campo descripcion incluye "ACME"

## Caso 3: Consulta de todas las empresas
- **Entrada:**
  - action: all
  - params: { }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene todas las empresas existentes

## Caso 4: Exportar empresas
- **Entrada:**
  - action: export
  - params: { }
- **Esperado:**
  - eResponse.success = true
  - eResponse.export = true
  - eResponse.data contiene todas las empresas

## Caso 5: Listar tipos de empresa
- **Entrada:**
  - action: listTiposEmp
  - params: { }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene todos los tipos de empresa

## Caso 6: Error por parámetros faltantes
- **Entrada:**
  - action: byNumber
  - params: { num_empresa: 123 }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica error de parámetros


