# Casos de Uso - ligapagoTra

**Categoría:** Form

## Caso de Uso 1: Ligar un pago diverso a una transmisión patrimonial (completo)

**Descripción:** El usuario liga un pago de caja a una transmisión patrimonial existente, tipo completo.

**Precondiciones:**
El pago existe en la tabla pagos (cveconcepto=4) y la transmisión existe en actostransm.

**Pasos a seguir:**
1. El usuario ingresa fecha, recaudadora, caja y folio del pago.
2. El sistema busca y muestra el pago.
3. El usuario ingresa el folio de transmisión.
4. El sistema busca y muestra la transmisión.
5. El usuario selecciona tipo 'Completo' y ejecuta la liga.
6. El sistema llama al SP y actualiza la transmisión.

**Resultado esperado:**
El pago queda ligado a la transmisión patrimonial y el usuario recibe confirmación.

**Datos de prueba:**
{ "fecha": "2024-06-01", "recaud": 1, "caja": "A", "folio": 123, "folio_transmision": 5555, "tipo": 22 }

---

## Caso de Uso 2: Ligar un pago diverso a una transmisión patrimonial (diferencia)

**Descripción:** El usuario liga un pago de caja a una transmisión patrimonial como diferencia.

**Precondiciones:**
El pago existe, la transmisión existe, y existe registro en diferencias_glosa.

**Pasos a seguir:**
1. El usuario ingresa los datos del pago y lo busca.
2. El usuario ingresa el folio de transmisión y lo busca.
3. El usuario selecciona tipo 'Diferencia' y ejecuta la liga.
4. El sistema actualiza diferencias_glosa y actostransm.

**Resultado esperado:**
El pago queda ligado como diferencia y se actualizan los registros correspondientes.

**Datos de prueba:**
{ "fecha": "2024-06-01", "recaud": 1, "caja": "A", "folio": 124, "folio_transmision": 5556, "tipo": 2 }

---

## Caso de Uso 3: Error al ligar pago inexistente

**Descripción:** El usuario intenta ligar un pago que no existe.

**Precondiciones:**
No existe el pago con los datos proporcionados.

**Pasos a seguir:**
1. El usuario ingresa datos de pago inexistente.
2. El sistema muestra mensaje de error.

**Resultado esperado:**
El usuario recibe mensaje 'No existe el pago a ligar'.

**Datos de prueba:**
{ "fecha": "2024-06-01", "recaud": 1, "caja": "A", "folio": 99999, "folio_transmision": 5555, "tipo": 22 }

---

