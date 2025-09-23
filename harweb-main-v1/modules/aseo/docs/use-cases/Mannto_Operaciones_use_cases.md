# Casos de Uso - Mannto_Operaciones

**Categoría:** Form

## Caso de Uso 1: Alta de nueva Clave de Operación

**Descripción:** El usuario desea registrar una nueva clave de operación para un nuevo tipo de movimiento.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de catálogo.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Operación.
2. Hace clic en 'Nueva Clave'.
3. Ingresa la clave (un carácter) y la descripción.
4. Presiona 'Guardar'.

**Resultado esperado:**
La clave se registra y aparece en el listado. Si la clave ya existe, se muestra un mensaje de error.

**Datos de prueba:**
{ "cve_operacion": "Z", "descripcion": "ZONA ESPECIAL" }

---

## Caso de Uso 2: Edición de descripción de Clave de Operación

**Descripción:** El usuario necesita corregir la descripción de una clave existente.

**Precondiciones:**
Existe al menos una clave de operación registrada.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Operación.
2. Hace clic en 'Editar' sobre la clave deseada.
3. Modifica la descripción.
4. Presiona 'Guardar'.

**Resultado esperado:**
La descripción se actualiza correctamente.

**Datos de prueba:**
{ "cve_operacion": "A", "descripcion": "CUOTA NORMAL ACTUALIZADA" }

---

## Caso de Uso 3: Eliminación de Clave de Operación sin pagos asociados

**Descripción:** El usuario desea eliminar una clave que no está en uso.

**Precondiciones:**
Existe una clave de operación sin pagos asociados.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Operación.
2. Hace clic en 'Eliminar' sobre la clave deseada.
3. Confirma la eliminación.

**Resultado esperado:**
La clave se elimina del catálogo.

**Datos de prueba:**
{ "ctrol_operacion": 10 }

---

