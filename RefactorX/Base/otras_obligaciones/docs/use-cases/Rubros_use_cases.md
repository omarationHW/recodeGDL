# Casos de Uso - Rubros

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Rubro con dos status

**Descripción:** El usuario desea crear un nuevo rubro llamado 'RUBRO PRUEBA' y asignarle los status 'A' (Activo) y 'I' (Inactivo).

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para crear rubros.

**Pasos a seguir:**
1. El usuario accede a la página de Rubros.
2. Da clic en 'Crear Nuevo Rubro'.
3. Ingresa el nombre 'RUBRO PRUEBA'.
4. Selecciona los status 'A' y 'I'.
5. Da clic en 'Ejecutar'.

**Resultado esperado:**
El sistema muestra mensaje de éxito y el nuevo rubro aparece en la lista.

**Datos de prueba:**
{ "nombre": "RUBRO PRUEBA", "status_selected": [ {"cve_stat": "A", "descripcion": "Activo"}, {"cve_stat": "I", "descripcion": "Inactivo"} ] }

---

## Caso de Uso 2: Intento de crear rubro duplicado

**Descripción:** El usuario intenta crear un rubro con un nombre que ya existe.

**Precondiciones:**
Existe un rubro llamado 'RUBRO PRUEBA'.

**Pasos a seguir:**
1. El usuario accede a la página de Rubros.
2. Ingresa el nombre 'RUBRO PRUEBA'.
3. Selecciona cualquier status.
4. Da clic en 'Ejecutar'.

**Resultado esperado:**
El sistema muestra mensaje de error indicando que el rubro ya existe.

**Datos de prueba:**
{ "nombre": "RUBRO PRUEBA", "status_selected": [ {"cve_stat": "A", "descripcion": "Activo"} ] }

---

## Caso de Uso 3: Consulta de rubros y status

**Descripción:** El usuario consulta la lista de rubros y el catálogo de status.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de Rubros.
2. El sistema muestra la tabla de rubros existentes y el catálogo de status.

**Resultado esperado:**
Se visualizan correctamente los rubros y status.

**Datos de prueba:**
N/A

---

