# Casos de Uso - CuotasMdoMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva cuota de mercado

**Descripción:** El usuario desea registrar una nueva cuota para el año 2024, categoría 1, sección 'A', clave de cuota 1001, importe 1234.56.

**Precondiciones:**
El usuario tiene permisos de escritura. No existe una cuota para la combinación año/categoría/sección/clave_cuota.

**Pasos a seguir:**
1. El usuario accede a la página de Cuotas de Mercado.
2. Hace clic en 'Crear'.
3. Llena el formulario con: Año=2024, Categoría=1, Sección='A', Clave de Cuota=1001, Importe=1234.56.
4. Hace clic en 'Crear'.
5. El sistema valida y llama al endpoint con acción 'create'.

**Resultado esperado:**
La cuota es registrada y aparece en el listado. Mensaje de éxito.

**Datos de prueba:**
{ "axo": 2024, "categoria": 1, "seccion": "A", "clave_cuota": 1001, "importe": 1234.56, "id_usuario": 1 }

---

## Caso de Uso 2: Modificación de cuota existente

**Descripción:** El usuario desea modificar el importe de una cuota existente (id_cuotas=5) a 1500.00.

**Precondiciones:**
Existe la cuota con id_cuotas=5.

**Pasos a seguir:**
1. El usuario localiza la cuota en el listado y hace clic en 'Editar'.
2. Cambia el importe a 1500.00.
3. Hace clic en 'Actualizar'.
4. El sistema valida y llama al endpoint con acción 'update'.

**Resultado esperado:**
El importe es actualizado. Mensaje de éxito.

**Datos de prueba:**
{ "id_cuotas": 5, "axo": 2024, "categoria": 1, "seccion": "A", "clave_cuota": 1001, "importe": 1500.00, "id_usuario": 1 }

---

## Caso de Uso 3: Eliminación de cuota

**Descripción:** El usuario desea eliminar una cuota existente (id_cuotas=7).

**Precondiciones:**
Existe la cuota con id_cuotas=7.

**Pasos a seguir:**
1. El usuario localiza la cuota en el listado y hace clic en 'Eliminar'.
2. Confirma la eliminación.
3. El sistema llama al endpoint con acción 'delete'.

**Resultado esperado:**
La cuota es eliminada del listado. Mensaje de éxito.

**Datos de prueba:**
{ "id_cuotas": 7 }

---

