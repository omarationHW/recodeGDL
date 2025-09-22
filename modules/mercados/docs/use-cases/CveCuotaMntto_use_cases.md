# Casos de Uso - CveCuotaMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva clave de cuota

**Descripción:** Un usuario desea agregar una nueva clave de cuota para un tipo de local especial.

**Precondiciones:**
El usuario tiene permisos de administrador. La clave de cuota no existe.

**Pasos a seguir:**
1. El usuario ingresa a la página de Claves de Cuota.
2. Hace clic en 'Nueva Clave de Cuota'.
3. Ingresa el número de clave (ej: 10) y la descripción (ej: 'CUOTA ESPECIAL').
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La clave de cuota se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{ "clave_cuota": 10, "descripcion": "CUOTA ESPECIAL" }

---

## Caso de Uso 2: Edición de una clave de cuota existente

**Descripción:** El usuario necesita corregir la descripción de una clave de cuota.

**Precondiciones:**
La clave de cuota existe.

**Pasos a seguir:**
1. El usuario selecciona la clave de cuota a editar.
2. Hace clic en 'Editar'.
3. Modifica la descripción (ej: 'CUOTA MODIFICADA').
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La descripción se actualiza correctamente.

**Datos de prueba:**
{ "clave_cuota": 10, "descripcion": "CUOTA MODIFICADA" }

---

## Caso de Uso 3: Eliminación de una clave de cuota

**Descripción:** El usuario elimina una clave de cuota que ya no se utiliza.

**Precondiciones:**
La clave de cuota existe y no está referenciada en otras tablas.

**Pasos a seguir:**
1. El usuario selecciona la clave de cuota a eliminar.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La clave de cuota se elimina del sistema.

**Datos de prueba:**
{ "clave_cuota": 10 }

---

