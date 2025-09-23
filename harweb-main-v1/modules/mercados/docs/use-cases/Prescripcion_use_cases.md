# Casos de Uso - Prescripcion

**Categoría:** Form

## Caso de Uso 1: Prescribir adeudos de energía eléctrica a un local

**Descripción:** El usuario selecciona un local con adeudos de energía eléctrica y realiza la prescripción de uno o varios adeudos, registrando el número de oficio.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos. El local debe tener adeudos activos.

**Pasos a seguir:**
1. El usuario accede a la página de Prescripción.
2. Selecciona el mercado, sección, local, letra y bloque.
3. Selecciona el tipo de movimiento (Prescripción).
4. Da clic en 'Buscar'.
5. Visualiza los adeudos activos.
6. Selecciona uno o varios adeudos a prescribir.
7. Captura el número de oficio.
8. Da clic en 'Prescribir'.

**Resultado esperado:**
Los adeudos seleccionados desaparecen de la lista de adeudos activos y aparecen en la lista de prescripciones. Se muestra mensaje de éxito.

**Datos de prueba:**
Mercado: 1-2-1-SS, Local: 10, Movimiento: Prescripción, Oficio: ABC/2024/0001

---

## Caso de Uso 2: Quitar prescripción y restaurar adeudo

**Descripción:** El usuario selecciona una prescripción existente y la revierte, restaurando el adeudo original.

**Precondiciones:**
Debe existir al menos una prescripción para el local.

**Pasos a seguir:**
1. El usuario accede a la página de Prescripción.
2. Busca el local correspondiente.
3. Visualiza la lista de prescripciones.
4. Selecciona una o varias prescripciones.
5. Da clic en 'Quitar'.

**Resultado esperado:**
Las prescripciones seleccionadas desaparecen de la lista y los adeudos reaparecen en la lista de adeudos activos.

**Datos de prueba:**
Prescripción con id_cancelacion: 456, Local: 10

---

## Caso de Uso 3: Validación de oficio obligatorio

**Descripción:** El usuario intenta prescribir adeudos sin capturar el número de oficio.

**Precondiciones:**
El usuario debe estar autenticado y haber seleccionado al menos un adeudo.

**Pasos a seguir:**
1. El usuario accede a la página de Prescripción.
2. Busca un local con adeudos.
3. Selecciona uno o varios adeudos.
4. Deja el campo de oficio vacío.
5. Da clic en 'Prescribir'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el número de oficio es obligatorio y no realiza ninguna operación.

**Datos de prueba:**
Mercado: 1-2-1-SS, Local: 10, Movimiento: Prescripción, Oficio: (vacío)

---

