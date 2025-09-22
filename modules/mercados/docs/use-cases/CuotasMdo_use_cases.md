# Casos de Uso - CuotasMdo

**Categoría:** Form

## Caso de Uso 1: Alta de nueva cuota de mercado

**Descripción:** Un usuario autorizado desea agregar una nueva cuota de mercado para el año actual.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para crear cuotas.

**Pasos a seguir:**
1. El usuario accede a la página 'Cuotas de Mercados'.
2. Hace clic en 'Agregar'.
3. Llena el formulario con año, categoría, sección, clave de cuota, importe y su ID de usuario.
4. Hace clic en 'Guardar'.
5. El sistema valida y envía la petición al backend.

**Resultado esperado:**
La cuota se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{ "axo": 2024, "categoria": 1, "seccion": "A1", "clave_cuota": 2, "importe_cuota": 1500.00, "id_usuario": 5 }

---

## Caso de Uso 2: Edición de cuota existente

**Descripción:** Un usuario necesita modificar el importe de una cuota ya existente.

**Precondiciones:**
Debe existir al menos una cuota en el sistema.

**Pasos a seguir:**
1. El usuario accede a la página 'Cuotas de Mercados'.
2. Ubica la cuota a editar y hace clic en 'Editar'.
3. Modifica el campo 'Importe'.
4. Hace clic en 'Actualizar'.

**Resultado esperado:**
El importe de la cuota se actualiza y se refleja en el listado.

**Datos de prueba:**
{ "id_cuotas": 10, "axo": 2024, "categoria": 1, "seccion": "A1", "clave_cuota": 2, "importe_cuota": 1800.00, "id_usuario": 5 }

---

## Caso de Uso 3: Eliminación de cuota

**Descripción:** Un usuario elimina una cuota de mercado que ya no es válida.

**Precondiciones:**
Debe existir la cuota a eliminar.

**Pasos a seguir:**
1. El usuario accede a la página 'Cuotas de Mercados'.
2. Hace clic en 'Eliminar' en la cuota deseada.
3. Confirma la eliminación.

**Resultado esperado:**
La cuota desaparece del listado y no puede ser utilizada en operaciones futuras.

**Datos de prueba:**
{ "id_cuotas": 10 }

---

