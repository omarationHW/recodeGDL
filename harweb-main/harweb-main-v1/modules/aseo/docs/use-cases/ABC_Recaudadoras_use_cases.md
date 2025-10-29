# Casos de Uso - ABC_Recaudadoras

**Categoría:** Form

## Caso de Uso 1: Alta de Recaudadora

**Descripción:** El usuario desea agregar una nueva recaudadora al catálogo.

**Precondiciones:**
El usuario tiene acceso a la página de recaudadoras y permisos de alta.

**Pasos a seguir:**
1. El usuario hace clic en 'Agregar Recaudadora'.
2. Ingresa el número (ej: 10) y la descripción (ej: 'Recaudadora Norte').
3. Hace clic en 'Guardar'.
4. El sistema envía la petición a /api/execute con action 'insertRecaudadora'.
5. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
La recaudadora aparece en la lista y se muestra el mensaje 'Recaudadora agregada correctamente.'

**Datos de prueba:**
{ "num_rec": 10, "descripcion": "Recaudadora Norte" }

---

## Caso de Uso 2: Edición de Recaudadora

**Descripción:** El usuario desea modificar la descripción de una recaudadora existente.

**Precondiciones:**
Existe una recaudadora con num_rec=10.

**Pasos a seguir:**
1. El usuario hace clic en 'Editar' en la fila de la recaudadora 10.
2. Cambia la descripción a 'Recaudadora Norte Modificada'.
3. Hace clic en 'Actualizar'.
4. El sistema envía la petición a /api/execute con action 'updateRecaudadora'.
5. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
La descripción se actualiza en la lista y se muestra el mensaje 'Recaudadora actualizada correctamente.'

**Datos de prueba:**
{ "num_rec": 10, "descripcion": "Recaudadora Norte Modificada" }

---

## Caso de Uso 3: Eliminación de Recaudadora sin contratos asociados

**Descripción:** El usuario desea eliminar una recaudadora que no tiene contratos asociados.

**Precondiciones:**
Existe una recaudadora con num_rec=11 y no tiene contratos asociados.

**Pasos a seguir:**
1. El usuario hace clic en 'Eliminar' en la fila de la recaudadora 11.
2. Confirma la eliminación.
3. El sistema envía la petición a /api/execute con action 'deleteRecaudadora'.
4. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
La recaudadora desaparece de la lista y se muestra el mensaje 'Recaudadora eliminada correctamente.'

**Datos de prueba:**
{ "num_rec": 11 }

---

