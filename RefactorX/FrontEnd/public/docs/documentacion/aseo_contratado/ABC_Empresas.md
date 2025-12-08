# DocumentaciÃ³n TÃ©cnica: ABC_Empresas

## AnÃ¡lisis TÃ©cnico

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



## Casos de Prueba

# Casos de Prueba: Catálogo de Empresas

## 1. Alta de empresa válida
- Enviar a /api/execute:
  ```json
  { "action": "create", "payload": { "ctrol_emp": 9, "descripcion": "EMPRESA TEST", "representante": "TEST USER" } }
  ```
- Esperar: success=true, data contiene num_empresa y ctrol_emp

## 2. Alta de empresa sin descripción
- Enviar a /api/execute:
  ```json
  { "action": "create", "payload": { "ctrol_emp": 9, "descripcion": "", "representante": "TEST USER" } }
  ```
- Esperar: success=false, message indica campo requerido

## 3. Edición de empresa existente
- Enviar a /api/execute:
  ```json
  { "action": "update", "payload": { "num_empresa": 1, "ctrol_emp": 9, "descripcion": "EMPRESA MOD", "representante": "MOD USER" } }
  ```
- Esperar: success=true

## 4. Eliminación de empresa sin contratos
- Enviar a /api/execute:
  ```json
  { "action": "delete", "payload": { "num_empresa": 2, "ctrol_emp": 9 } }
  ```
- Esperar: success=true

## 5. Eliminación de empresa con contratos
- Enviar a /api/execute:
  ```json
  { "action": "delete", "payload": { "num_empresa": 10, "ctrol_emp": 9 } }
  ```
- Esperar: success=false, message indica que no se puede eliminar

## 6. Búsqueda por nombre
- Enviar a /api/execute:
  ```json
  { "action": "search", "payload": { "descripcion": "EMPRESA" } }
  ```
- Esperar: success=true, data contiene empresas cuyo nombre contiene 'EMPRESA'

## 7. Listado general
- Enviar a /api/execute:
  ```json
  { "action": "list" }
  ```
- Esperar: success=true, data contiene todas las empresas


## Casos de Uso

# Casos de Uso - ABC_Empresas

**Categoría:** Form

## Caso de Uso 1: Alta de nueva empresa privada

**Descripción:** El usuario desea registrar una nueva empresa privada en el catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y conoce el tipo de empresa.

**Pasos a seguir:**
1. El usuario accede a la página de Empresas.
2. Hace clic en 'Agregar Empresa'.
3. Selecciona 'Privada' en el combo de tipo de empresa.
4. Ingresa 'EMPRESA NUEVA' como descripción y 'JUAN PEREZ' como representante.
5. Hace clic en 'Guardar'.

**Resultado esperado:**
La empresa se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{ "ctrol_emp": 9, "descripcion": "EMPRESA NUEVA", "representante": "JUAN PEREZ" }

---

## Caso de Uso 2: Edición de empresa existente

**Descripción:** El usuario edita el nombre y representante de una empresa ya registrada.

**Precondiciones:**
Existe una empresa con num_empresa=5 y ctrol_emp=9.

**Pasos a seguir:**
1. El usuario busca la empresa con nombre 'EMPRESA VIEJA'.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'EMPRESA ACTUALIZADA' y el representante a 'MARIA LOPEZ'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La empresa se actualiza correctamente.

**Datos de prueba:**
{ "num_empresa": 5, "ctrol_emp": 9, "descripcion": "EMPRESA ACTUALIZADA", "representante": "MARIA LOPEZ" }

---

## Caso de Uso 3: Intento de eliminación de empresa con contratos asociados

**Descripción:** El usuario intenta eliminar una empresa que tiene contratos activos.

**Precondiciones:**
Existe una empresa con num_empresa=10, ctrol_emp=9 y al menos un contrato asociado.

**Pasos a seguir:**
1. El usuario busca la empresa con num_empresa=10.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no se puede eliminar la empresa porque tiene contratos asociados.

**Datos de prueba:**
{ "num_empresa": 10, "ctrol_emp": 9 }

---



---
**Componente:** `ABC_Empresas.vue`
**MÃ³dulo:** `aseo_contratado`

