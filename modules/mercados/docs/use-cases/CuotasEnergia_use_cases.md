# Casos de Uso - CuotasEnergia

**Categoría:** Form

## Caso de Uso 1: Alta de nueva cuota de energía eléctrica

**Descripción:** El usuario desea registrar una nueva cuota de energía eléctrica para el periodo 7 del año 2024.

**Precondiciones:**
El usuario tiene permisos de administrador y está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Cuotas de Energía Eléctrica.
2. Hace clic en 'Agregar Cuota'.
3. Ingresa Año: 2024, Periodo: 7, Importe: 150.123456.
4. Hace clic en 'Agregar'.

**Resultado esperado:**
La cuota se agrega correctamente, aparece en la tabla y muestra mensaje de éxito.

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "importe": 150.123456 }

---

## Caso de Uso 2: Modificación de cuota existente

**Descripción:** El usuario necesita corregir el importe de una cuota ya registrada.

**Precondiciones:**
Existe una cuota con id_kilowhatts=5, el usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario localiza la cuota con id 5 en la tabla.
2. Hace clic en 'Editar'.
3. Cambia el importe a 200.654321.
4. Hace clic en 'Guardar Cambios'.

**Resultado esperado:**
El importe se actualiza y la tabla refleja el nuevo valor.

**Datos de prueba:**
{ "id_kilowhatts": 5, "axo": 2024, "periodo": 7, "importe": 200.654321 }

---

## Caso de Uso 3: Eliminación de cuota

**Descripción:** El usuario elimina una cuota que fue registrada por error.

**Precondiciones:**
Existe una cuota con id_kilowhatts=10.

**Pasos a seguir:**
1. El usuario localiza la cuota con id 10 en la tabla.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La cuota desaparece de la tabla y se muestra mensaje de éxito.

**Datos de prueba:**
{ "id_kilowhatts": 10 }

---

