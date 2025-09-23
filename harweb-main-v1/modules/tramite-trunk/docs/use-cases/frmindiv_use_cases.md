# Casos de Uso - frmindiv

**Categoría:** Form

## Caso de Uso 1: Consulta de construcciones individuales por clave catastral

**Descripción:** El usuario ingresa la clave catastral de un predio y consulta todas las construcciones individuales asociadas.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. Existen registros en la tabla construc para la clave catastral.

**Pasos a seguir:**
- El usuario accede a la página de construcciones individuales.
- Ingresa la clave catastral (11 dígitos) en el campo de búsqueda.
- Presiona Enter o hace clic en 'Buscar'.
- El sistema consulta el endpoint /api/execute con action 'list' y la clave catastral.

**Resultado esperado:**
Se muestra una tabla con todas las construcciones individuales activas (vigente = 'V') para la clave catastral ingresada.

**Datos de prueba:**
{ "cvecatnva": "D651J100001" }

---

## Caso de Uso 2: Alta de una nueva construcción individual

**Descripción:** El usuario agrega una nueva construcción individual para un subpredio de una clave catastral.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta. La clave catastral existe y el subpredio no está duplicado.

**Pasos a seguir:**
- El usuario accede a la página y busca la clave catastral.
- Hace clic en 'Agregar Construcción'.
- Llena el formulario con los datos requeridos.
- Presiona 'Agregar'.
- El sistema envía la petición a /api/execute con action 'create' y los datos del formulario.

**Resultado esperado:**
La construcción se agrega y aparece en la tabla de resultados.

**Datos de prueba:**
{ "cvecatnva": "D651J100001", "subpredio": 2, "cvebloque": 1, "axoconst": 2005, "areaconst": 120.5, "cveclasif": 3, "cvecuenta": 12345 }

---

## Caso de Uso 3: Edición y baja lógica de una construcción individual

**Descripción:** El usuario edita los datos de una construcción individual existente y luego la elimina (baja lógica).

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición y baja. Existe al menos una construcción individual activa.

**Pasos a seguir:**
- El usuario busca la clave catastral y selecciona una construcción de la tabla.
- Hace clic en 'Editar', modifica los datos y guarda.
- Luego hace clic en 'Eliminar' y confirma la acción.
- El sistema envía las peticiones a /api/execute con actions 'update' y 'delete'.

**Resultado esperado:**
La construcción se actualiza y luego desaparece de la lista (vigente = 'C').

**Datos de prueba:**
{ "id": 10, "cvecatnva": "D651J100001", "subpredio": 2, "cvebloque": 1, "axoconst": 2010, "areaconst": 130.0, "cveclasif": 3, "cvecuenta": 12345 }

---

