# Casos de Uso - GastosTransmision

**Categoría:** Form

## Caso de Uso 1: Consulta de Folio de Transmisión Patrimonial

**Descripción:** El usuario consulta los importes y estado de un folio de transmisión patrimonial.

**Precondiciones:**
El folio de transmisión existe y está vigente.

**Pasos a seguir:**
1. El usuario ingresa el número de folio y selecciona 'Transmisión Patrimonial'.
2. Presiona 'Consultar'.
3. El sistema envía la petición al endpoint /api/execute con action=consulta_foliotransm.
4. El backend ejecuta el SP y devuelve los importes y estado.

**Resultado esperado:**
Se muestran los importes (impuesto, recargos, multas, gastos, total) y el estado del folio.

**Datos de prueba:**
{ "folio": 12345, "opc": "T" }

---

## Caso de Uso 2: Aplicación de Gastos a Folio de Transmisión

**Descripción:** El usuario aplica un gasto capturado a un folio de transmisión patrimonial.

**Precondiciones:**
El folio existe, está vigente y no tiene gastos aplicados.

**Pasos a seguir:**
1. El usuario consulta el folio y visualiza los importes.
2. Ingresa el monto de gastos a aplicar.
3. Presiona 'Aplicar Gastos'.
4. El sistema envía la petición al endpoint /api/execute con action=afecta_gastostransm.
5. El backend ejecuta el SP y actualiza el folio.

**Resultado esperado:**
El gasto es aplicado correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "folio": 12345, "gastos": 500.00, "opc": "T" }

---

## Caso de Uso 3: Intento de Aplicar Gastos a Folio Inexistente

**Descripción:** El usuario intenta aplicar gastos a un folio que no existe.

**Precondiciones:**
El folio no existe en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa un folio inexistente y un monto de gastos.
2. Presiona 'Aplicar Gastos'.
3. El sistema envía la petición al endpoint /api/execute con action=afecta_gastostransm.
4. El backend ejecuta el SP y detecta que el folio no existe.

**Resultado esperado:**
Se muestra un mensaje de error indicando que el folio no fue encontrado.

**Datos de prueba:**
{ "folio": 999999, "gastos": 100.00, "opc": "T" }

---

