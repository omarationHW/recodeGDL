# Casos de Uso - ABC_Und_Recolec

**Categoría:** Form

## Caso de Uso 1: Alta de Unidad de Recolección

**Descripción:** El usuario desea agregar una nueva unidad de recolección para el ejercicio actual.

**Precondiciones:**
El usuario tiene permisos de administrador y el ejercicio está abierto.

**Pasos a seguir:**
1. El usuario accede a la página de Unidades de Recolección.
2. Hace clic en 'Agregar Unidad'.
3. Llena los campos: Ejercicio=2024, Clave='K', Descripción='Camión Compactador', Costo Unidad=1500.00, Costo Excedente=2000.00.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La unidad se agrega correctamente y aparece en la lista. Si la clave ya existe para ese ejercicio, se muestra un error.

**Datos de prueba:**
{ "ejercicio_recolec": 2024, "cve_recolec": "K", "descripcion": "Camión Compactador", "costo_unidad": 1500.00, "costo_exed": 2000.00 }

---

## Caso de Uso 2: Edición de Unidad de Recolección

**Descripción:** El usuario desea modificar la descripción y el costo de una unidad existente.

**Precondiciones:**
Existe una unidad con ctrol_recolec=5, ejercicio=2024.

**Pasos a seguir:**
1. El usuario localiza la unidad con ctrol_recolec=5.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'Camión Compactador 2024' y el costo a 1600.00.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La unidad se actualiza correctamente. Si el control no existe, se muestra un error.

**Datos de prueba:**
{ "ctrol_recolec": 5, "ejercicio_recolec": 2024, "cve_recolec": "K", "descripcion": "Camión Compactador 2024", "costo_unidad": 1600.00, "costo_exed": 2000.00 }

---

## Caso de Uso 3: Eliminación de Unidad de Recolección

**Descripción:** El usuario intenta eliminar una unidad de recolección.

**Precondiciones:**
Existe una unidad con ctrol_recolec=7 y no está referenciada en contratos.

**Pasos a seguir:**
1. El usuario localiza la unidad con ctrol_recolec=7.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La unidad se elimina correctamente. Si está referenciada en contratos, se muestra un error.

**Datos de prueba:**
{ "ctrol_recolec": 7 }

---

