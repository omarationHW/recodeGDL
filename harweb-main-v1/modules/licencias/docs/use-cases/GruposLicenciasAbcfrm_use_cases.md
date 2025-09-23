# Casos de Uso - GruposLicenciasAbcfrm

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo grupo de licencia

**Descripción:** El usuario desea agregar un nuevo grupo de licencia con la descripción 'ADMINISTRATIVOS'.

**Precondiciones:**
El usuario tiene acceso a la página de Grupos de Licencias y la tabla está vacía o no contiene el grupo 'ADMINISTRATIVOS'.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Agregar'.
2. Se muestra el formulario de alta.
3. El usuario ingresa 'ADMINISTRATIVOS' en el campo Descripción.
4. El usuario hace clic en 'Aceptar'.
5. El sistema envía la petición a /api/execute con la operación 'insert_grupo_licencia'.
6. El backend inserta el registro y retorna el grupo creado.
7. El frontend muestra mensaje de éxito y actualiza la tabla.

**Resultado esperado:**
El grupo 'ADMINISTRATIVOS' aparece en la tabla con un ID asignado automáticamente.

**Datos de prueba:**
{ "descripcion": "ADMINISTRATIVOS" }

---

## Caso de Uso 2: Edición de un grupo de licencia existente

**Descripción:** El usuario desea modificar la descripción del grupo con ID 1 a 'OPERATIVOS'.

**Precondiciones:**
Existe un grupo con ID 1 y descripción diferente a 'OPERATIVOS'.

**Pasos a seguir:**
1. El usuario localiza el grupo con ID 1 en la tabla.
2. Hace clic en 'Editar'.
3. Se muestra el formulario de edición con los datos actuales.
4. El usuario cambia la descripción a 'OPERATIVOS'.
5. Hace clic en 'Aceptar'.
6. El sistema envía la petición a /api/execute con la operación 'update_grupo_licencia'.
7. El backend actualiza el registro y retorna el grupo actualizado.
8. El frontend muestra mensaje de éxito y actualiza la tabla.

**Resultado esperado:**
El grupo con ID 1 muestra la descripción 'OPERATIVOS' en la tabla.

**Datos de prueba:**
{ "id": 1, "descripcion": "OPERATIVOS" }

---

## Caso de Uso 3: Filtrado de grupos de licencias por descripción

**Descripción:** El usuario desea buscar todos los grupos que contienen la palabra 'ADMIN' en la descripción.

**Precondiciones:**
Existen varios grupos de licencias, algunos con 'ADMIN' en la descripción.

**Pasos a seguir:**
1. El usuario escribe 'ADMIN' en el campo de filtro de descripción.
2. El sistema envía la petición a /api/execute con la operación 'list_grupos_licencias' y el parámetro 'descripcion'.
3. El backend retorna solo los grupos cuyo campo descripción contiene 'ADMIN'.
4. El frontend muestra la tabla filtrada.

**Resultado esperado:**
Solo se muestran los grupos que contienen 'ADMIN' en la descripción.

**Datos de prueba:**
{ "descripcion": "ADMIN" }

---

