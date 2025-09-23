# Casos de Uso - Mannto_Recaudadoras

**Categoría:** Form

## Caso de Uso 1: Alta de nueva recaudadora

**Descripción:** El usuario desea dar de alta una nueva recaudadora con un número único y una descripción.

**Precondiciones:**
El número de recaudadora no debe existir previamente.

**Pasos a seguir:**
1. El usuario accede a la página de recaudadoras.
2. Hace clic en 'Nueva Recaudadora'.
3. Ingresa el número (ej: 10) y la descripción (ej: 'Recaudadora Sur').
4. Presiona 'Crear'.

**Resultado esperado:**
La recaudadora se crea exitosamente y aparece en la lista.

**Datos de prueba:**
{ "num_rec": 10, "descripcion": "Recaudadora Sur" }

---

## Caso de Uso 2: Intento de eliminar recaudadora con contratos asociados

**Descripción:** El usuario intenta eliminar una recaudadora que tiene contratos asociados.

**Precondiciones:**
La recaudadora existe y tiene al menos un contrato asociado en ta_16_contratos.

**Pasos a seguir:**
1. El usuario accede a la página de recaudadoras.
2. Hace clic en 'Eliminar' sobre la recaudadora con contratos.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no se puede eliminar porque existen contratos asociados.

**Datos de prueba:**
{ "num_rec": 1 }

---

## Caso de Uso 3: Edición de descripción de recaudadora

**Descripción:** El usuario desea actualizar la descripción de una recaudadora existente.

**Precondiciones:**
La recaudadora existe.

**Pasos a seguir:**
1. El usuario accede a la página de recaudadoras.
2. Hace clic en 'Editar' sobre la recaudadora deseada.
3. Modifica la descripción.
4. Presiona 'Actualizar'.

**Resultado esperado:**
La descripción se actualiza correctamente y se refleja en la lista.

**Datos de prueba:**
{ "num_rec": 10, "descripcion": "Recaudadora Sur Actualizada" }

---

