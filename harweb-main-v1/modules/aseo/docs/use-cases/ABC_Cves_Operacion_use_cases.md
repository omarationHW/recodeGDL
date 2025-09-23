# Casos de Uso - ABC_Cves_Operacion

**Categoría:** Form

## Caso de Uso 1: Alta de nueva clave de operación

**Descripción:** El usuario desea agregar una nueva clave de operación al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y está autenticado.

**Pasos a seguir:**
1. El usuario ingresa a la página de Catálogo de Claves de Operación.
2. Hace clic en 'Agregar Clave'.
3. Llena el formulario con clave 'X' y descripción 'Operación de prueba'.
4. Presiona 'Guardar'.

**Resultado esperado:**
La clave se agrega correctamente y aparece en la lista.

**Datos de prueba:**
{ "cve_operacion": "X", "descripcion": "Operación de prueba" }

---

## Caso de Uso 2: Intento de eliminar clave con pagos asociados

**Descripción:** El usuario intenta eliminar una clave de operación que ya está referenciada en pagos.

**Precondiciones:**
Existe una clave de operación con pagos asociados.

**Pasos a seguir:**
1. El usuario localiza la clave en la lista.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un error: 'No se puede eliminar: existen pagos asociados a esta clave.'

**Datos de prueba:**
{ "ctrol_operacion": 1 }

---

## Caso de Uso 3: Edición de descripción de clave de operación

**Descripción:** El usuario edita la descripción de una clave existente.

**Precondiciones:**
Existe una clave de operación válida.

**Pasos a seguir:**
1. El usuario localiza la clave en la lista.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'Nueva descripción'.
4. Presiona 'Actualizar'.

**Resultado esperado:**
La descripción se actualiza correctamente.

**Datos de prueba:**
{ "ctrol_operacion": 2, "cve_operacion": "A", "descripcion": "Nueva descripción" }

---

