# Casos de Uso - Menu

**Categoría:** Form

## Caso de Uso 1: Alta de Unidad de Recolección

**Descripción:** El usuario desea agregar una nueva unidad de recolección para el ejercicio 2024.

**Precondiciones:**
El usuario tiene permisos de administrador y el ejercicio 2024 existe.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Unidades.
2. Selecciona el ejercicio 2024.
3. Hace clic en 'Agregar Unidad'.
4. Llena los campos: Clave='K', Descripción='Unidad K', Costo Unidad=100.00, Costo Excedente=150.00.
5. Hace clic en 'Guardar'.
6. El sistema envía la petición a /api/execute con acción 'catalog.create.unidad'.

**Resultado esperado:**
La unidad se agrega correctamente y aparece en la tabla. Si la clave ya existe, se muestra un error.

**Datos de prueba:**
{ "ejercicio": 2024, "clave": "K", "descripcion": "Unidad K", "costo_unidad": 100.00, "costo_exed": 150.00 }

---

## Caso de Uso 2: Edición de Unidad de Recolección

**Descripción:** El usuario desea modificar la descripción y costos de una unidad existente.

**Precondiciones:**
Existe una unidad con clave 'K' para el ejercicio 2024.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Unidades.
2. Selecciona el ejercicio 2024.
3. Localiza la unidad 'K' y hace clic en 'Editar'.
4. Cambia la descripción a 'Unidad K Modificada', Costo Unidad=120.00, Costo Excedente=170.00.
5. Hace clic en 'Guardar'.
6. El sistema envía la petición a /api/execute con acción 'catalog.update.unidad'.

**Resultado esperado:**
La unidad se actualiza correctamente y los nuevos valores se reflejan en la tabla.

**Datos de prueba:**
{ "id": 1, "descripcion": "Unidad K Modificada", "costo_unidad": 120.00, "costo_exed": 170.00 }

---

## Caso de Uso 3: Eliminación de Unidad de Recolección

**Descripción:** El usuario desea eliminar una unidad de recolección que no tiene contratos asociados.

**Precondiciones:**
Existe una unidad con id=2 y no tiene contratos asociados.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Unidades.
2. Selecciona el ejercicio correspondiente.
3. Localiza la unidad y hace clic en 'Eliminar'.
4. Confirma la eliminación.
5. El sistema envía la petición a /api/execute con acción 'catalog.delete.unidad'.

**Resultado esperado:**
La unidad se elimina correctamente. Si tiene contratos asociados, se muestra un error.

**Datos de prueba:**
{ "id": 2 }

---

