# Casos de Uso - Mannto_Recargos

**Categoría:** Form

## Caso de Uso 1: Alta de Recargo Mensual

**Descripción:** El usuario desea registrar el recargo y multa para el mes de junio de 2024.

**Precondiciones:**
El usuario tiene permisos de administrador. No existe recargo para junio 2024.

**Pasos a seguir:**
1. Accede a la página de Recargos.
2. Da clic en 'Nuevo Recargo'.
3. Ingresa Año: 2024, Mes: 6, % Recargo: 2.5, % Multa: 1.5.
4. Da clic en 'Guardar'.

**Resultado esperado:**
El sistema muestra mensaje 'Recargo creado correctamente' y el nuevo registro aparece en la lista.

**Datos de prueba:**
{ "year": 2024, "month": 6, "porc_recargo": 2.5, "porc_multa": 1.5 }

---

## Caso de Uso 2: Edición de Recargo Existente

**Descripción:** El usuario modifica el porcentaje de multa para el recargo de junio 2024.

**Precondiciones:**
Existe un recargo para junio 2024.

**Pasos a seguir:**
1. Accede a la página de Recargos.
2. Busca el año 2024.
3. Da clic en 'Editar' en el recargo de junio.
4. Cambia % Multa a 2.0.
5. Da clic en 'Guardar'.

**Resultado esperado:**
El sistema muestra mensaje 'Recargo actualizado correctamente' y el valor se actualiza en la lista.

**Datos de prueba:**
{ "year": 2024, "month": 6, "porc_recargo": 2.5, "porc_multa": 2.0 }

---

## Caso de Uso 3: Eliminación de Recargo

**Descripción:** El usuario elimina el recargo del mes de junio 2024.

**Precondiciones:**
Existe un recargo para junio 2024.

**Pasos a seguir:**
1. Accede a la página de Recargos.
2. Busca el año 2024.
3. Da clic en 'Eliminar' en el recargo de junio.
4. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra mensaje 'Recargo eliminado correctamente' y el registro desaparece de la lista.

**Datos de prueba:**
{ "year": 2024, "month": 6 }

---

