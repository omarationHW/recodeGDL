# Casos de Uso - preferencialfrm

**Categoría:** Form

## Caso de Uso 1: Agregar una nueva tasa preferencial a un folio

**Descripción:** El usuario necesita autorizar una tasa preferencial para un folio de transmisión patrimonial con tasa irregular.

**Precondiciones:**
El folio debe estar en estado autorizado y no tener abstención.

**Pasos a seguir:**
- El usuario ingresa el folio en la página.
- El sistema muestra la lista de tasas preferenciales existentes.
- El usuario hace clic en 'Agregar Tasa Preferencial'.
- Selecciona la tasa válida del año correspondiente.
- Ingresa observaciones si lo desea.
- Hace clic en 'Aceptar'.

**Resultado esperado:**
La tasa preferencial se agrega correctamente y aparece en la lista.

**Datos de prueba:**
{ "folio": 12345, "tasa_nva": 0.002, "observacion": "Autorizada por situación especial", "axoefec": 2024, "user": "admin" }

---

## Caso de Uso 2: Editar una tasa preferencial existente

**Descripción:** El usuario necesita modificar la tasa preferencial previamente autorizada para un folio.

**Precondiciones:**
Debe existir una tasa preferencial activa para el folio.

**Pasos a seguir:**
- El usuario busca el folio y visualiza la lista.
- Hace clic en 'Editar' sobre la tasa deseada.
- Modifica el valor de la tasa o las observaciones.
- Hace clic en 'Aceptar'.

**Resultado esperado:**
La tasa preferencial se actualiza correctamente.

**Datos de prueba:**
{ "id": 10, "tasa_nva": 0.0018, "observacion": "Actualización por revisión", "user": "admin" }

---

## Caso de Uso 3: Dar de baja una tasa preferencial

**Descripción:** El usuario necesita dar de baja una tasa preferencial que ya no debe estar vigente.

**Precondiciones:**
Debe existir una tasa preferencial activa para el folio.

**Pasos a seguir:**
- El usuario busca el folio y visualiza la lista.
- Hace clic en 'Dar de Baja' sobre la tasa deseada.
- Confirma la acción.

**Resultado esperado:**
La tasa preferencial es marcada como dada de baja (fecha y usuario).

**Datos de prueba:**
{ "id": 10, "user_baja": "admin" }

---

