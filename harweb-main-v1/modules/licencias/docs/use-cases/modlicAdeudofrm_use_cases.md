# Casos de Uso - modlicAdeudofrm

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo adeudo a una licencia

**Descripción:** El usuario desea registrar un nuevo adeudo para una licencia y anuncio específicos.

**Precondiciones:**
El usuario conoce el id de la licencia y el id del anuncio. No existe un adeudo para ese año.

**Pasos a seguir:**
1. El usuario accede a la página de Adeudo de Licencia.
2. Hace clic en 'Agregar'.
3. Llena los campos: Año=2024, Derechos=1000, Derechos2=100, Forma=500.
4. Hace clic en 'Aceptar'.
5. El sistema guarda el registro y recalcula los saldos.

**Resultado esperado:**
El nuevo adeudo aparece en la tabla y los saldos globales se actualizan.

**Datos de prueba:**
{ "id_licencia": 1, "id_anuncio": 2, "axo": 2024, "derechos": 1000, "derechos2": 100, "forma": 500 }

---

## Caso de Uso 2: Modificar un adeudo existente

**Descripción:** El usuario necesita corregir el monto de derechos de un adeudo ya registrado.

**Precondiciones:**
Existe al menos un adeudo para la licencia/anuncio y año deseado.

**Pasos a seguir:**
1. El usuario selecciona el registro a modificar en la tabla.
2. Hace clic en 'Modificar'.
3. Cambia el campo Derechos de 1000 a 1200.
4. Hace clic en 'Aceptar'.
5. El sistema actualiza el registro y recalcula los saldos.

**Resultado esperado:**
El registro muestra el nuevo valor y los saldos globales reflejan el cambio.

**Datos de prueba:**
{ "id": 5, "id_licencia": 1, "id_anuncio": 2, "axo": 2024, "derechos": 1200, "derechos2": 100, "forma": 500 }

---

## Caso de Uso 3: Eliminar un adeudo

**Descripción:** El usuario elimina un adeudo registrado por error.

**Precondiciones:**
Existe al menos un adeudo para la licencia/anuncio.

**Pasos a seguir:**
1. El usuario selecciona el registro a eliminar en la tabla.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.
4. El sistema borra el registro y recalcula los saldos.

**Resultado esperado:**
El registro desaparece de la tabla y los saldos globales se actualizan.

**Datos de prueba:**
{ "id": 5, "id_licencia": 1 }

---

