# Casos de Uso - TrasladoFolSin

**Categoría:** Form

## Caso de Uso 1: Traslado exitoso de pagos entre dos folios válidos

**Descripción:** El usuario traslada pagos seleccionados del folio 1001 al folio 2002, ambos existentes y válidos.

**Precondiciones:**
Ambos folios existen y tienen pagos activos. El usuario está autenticado.

**Pasos a seguir:**
1. El usuario ingresa 1001 como Folio DE TRASLADO y 2002 como Folio A TRASLADAR.
2. Hace clic en 'Verificar'.
3. El sistema muestra los datos y pagos de ambos folios.
4. El usuario selecciona uno o más pagos del folio 1001.
5. Hace clic en 'Trasladar Pagos Seleccionados'.

**Resultado esperado:**
Los pagos seleccionados se actualizan para pertenecer al folio 2002. El campo axo_pagado de ambos folios se actualiza correctamente. Se muestra mensaje de éxito.

**Datos de prueba:**
folio_de: 1001
folio_a: 2002
pagos_ids: [30001, 30002]
usuario_id: 5

---

## Caso de Uso 2: Intento de traslado con folios iguales

**Descripción:** El usuario intenta trasladar pagos entre el mismo folio.

**Precondiciones:**
El folio 1001 existe y tiene pagos.

**Pasos a seguir:**
1. El usuario ingresa 1001 como Folio DE TRASLADO y 1001 como Folio A TRASLADAR.
2. Hace clic en 'Verificar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los folios no deben ser iguales.

**Datos de prueba:**
folio_de: 1001
folio_a: 1001

---

## Caso de Uso 3: Intento de traslado sin seleccionar pagos

**Descripción:** El usuario verifica folios válidos pero no selecciona ningún pago antes de trasladar.

**Precondiciones:**
Ambos folios existen y tienen pagos.

**Pasos a seguir:**
1. El usuario ingresa 1001 como Folio DE TRASLADO y 2002 como Folio A TRASLADAR.
2. Hace clic en 'Verificar'.
3. El sistema muestra los pagos disponibles.
4. El usuario hace clic en 'Trasladar Pagos Seleccionados' sin seleccionar ningún pago.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe seleccionar al menos un pago.

**Datos de prueba:**
folio_de: 1001
folio_a: 2002
pagos_ids: []

---

