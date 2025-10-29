# Casos de Uso - ValoresFrm_aux

**Categoría:** Form

## Caso de Uso 1: Creación de un nuevo valor auxiliar

**Descripción:** El usuario ingresa los datos de un nuevo valor fiscal para un año y bimestre específico y lo guarda.

**Precondiciones:**
El usuario tiene acceso a la página de Valores Auxiliares.

**Pasos a seguir:**
1. El usuario accede a la página de Valores Auxiliares.
2. Completa los campos requeridos: Año efectos, Bimestre efectos, Valor Fiscal, Tasa.
3. (Opcional) Ingresa Año sobretasa, Año hasta, Bim hasta y Observaciones.
4. Presiona el botón 'Crear'.

**Resultado esperado:**
El registro es guardado en la base de datos y aparece en la tabla de la página.

**Datos de prueba:**
{ "axoefec": 2024, "bimefec": 1, "valfiscal": 10000.00, "tasa": 0.015, "axosobre": 2024, "ahasta": 2025, "bhasta": 2, "observacion": "Alta inicial" }

---

## Caso de Uso 2: Edición de un valor auxiliar existente

**Descripción:** El usuario selecciona un registro existente, modifica el valor fiscal y guarda los cambios.

**Precondiciones:**
Existe al menos un registro en la tabla.

**Pasos a seguir:**
1. El usuario localiza el registro en la tabla y presiona 'Editar'.
2. Modifica el campo 'Valor Fiscal'.
3. Presiona el botón 'Actualizar'.

**Resultado esperado:**
El registro se actualiza en la base de datos y la tabla refleja el nuevo valor.

**Datos de prueba:**
{ "id": 1, "valfiscal": 12000.00 }

---

## Caso de Uso 3: Eliminación de un valor auxiliar

**Descripción:** El usuario elimina un registro existente.

**Precondiciones:**
Existe al menos un registro en la tabla.

**Pasos a seguir:**
1. El usuario selecciona un registro y presiona 'Editar'.
2. Presiona el botón 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El registro es eliminado de la base de datos y desaparece de la tabla.

**Datos de prueba:**
{ "id": 1 }

---

