# Casos de Uso - Mannto_Und_Recolec

**Categoría:** Form

## Caso de Uso 1: Alta de Unidad de Recolección

**Descripción:** El usuario desea agregar una nueva unidad de recolección para el ejercicio actual.

**Precondiciones:**
El usuario tiene permisos de administrador y el ejercicio está vigente.

**Pasos a seguir:**
1. El usuario accede a la página de Unidades de Recolección.
2. Hace clic en 'Agregar Unidad'.
3. Llena los campos: Ejercicio=2024, Clave='B', Descripción='Unidad tipo B', Costo=150.00, Costo Excedente=250.00.
4. Hace clic en 'Aceptar'.

**Resultado esperado:**
La unidad se agrega correctamente y aparece en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "ejercicio": 2024, "cve": "B", "descripcion": "Unidad tipo B", "costo": 150.00, "costo_exed": 250.00 }

---

## Caso de Uso 2: Intento de Baja de Unidad con Contratos Asociados

**Descripción:** El usuario intenta eliminar una unidad que tiene contratos asociados.

**Precondiciones:**
Existe al menos un contrato asociado a la unidad.

**Pasos a seguir:**
1. El usuario selecciona una unidad en la lista.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no se puede eliminar la unidad porque tiene contratos asociados.

**Datos de prueba:**
{ "ctrol_recolec": 101 }

---

## Caso de Uso 3: Modificación de Descripción y Costos

**Descripción:** El usuario edita la descripción y los costos de una unidad existente.

**Precondiciones:**
La unidad existe y no está bloqueada.

**Pasos a seguir:**
1. El usuario selecciona una unidad en la lista.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'Unidad tipo C', costo a 180.00 y costo excedente a 300.00.
4. Hace clic en 'Aceptar'.

**Resultado esperado:**
La unidad se actualiza correctamente y los nuevos valores se reflejan en la lista.

**Datos de prueba:**
{ "ctrol_recolec": 102, "descripcion": "Unidad tipo C", "costo": 180.00, "costo_exed": 300.00 }

---

