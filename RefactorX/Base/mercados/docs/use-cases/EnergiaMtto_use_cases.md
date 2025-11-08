# Casos de Uso - EnergiaMtto

**Categoría:** Form

## Caso de Uso 1: Alta de Energía para un Local Existente

**Descripción:** El usuario da de alta un registro de energía para un local que no tiene energía registrada.

**Precondiciones:**
El local existe y no tiene energía registrada.

**Pasos a seguir:**
1. El usuario ingresa los datos del local (recaudadora, mercado, categoría, sección, local, letra, bloque).
2. Presiona 'Buscar Local'.
3. El sistema muestra el formulario de alta de energía.
4. El usuario llena los campos de consumo, descripción, cantidad, vigencia, fecha alta, año y número de oficio.
5. Presiona 'Grabar'.

**Resultado esperado:**
El registro de energía se crea correctamente, se genera historial y adeudos. El usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 34, "categoria": 1, "seccion": "SS", "local": 1202, "letra_local": null, "bloque": null, "cve_consumo": "F", "descripcion": "Local 1202", "cantidad": 100, "vigencia": "A", "fecha_alta": "2024-06-01", "axo": 2024, "numero": "OF-1202" }

---

## Caso de Uso 2: Intento de Alta en Local con Energía Existente

**Descripción:** El usuario intenta dar de alta energía en un local que ya tiene energía registrada.

**Precondiciones:**
El local ya tiene un registro en ta_11_energia.

**Pasos a seguir:**
1. El usuario ingresa los datos del local y presiona 'Buscar Local'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que ya existe energía para ese local.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 34, "categoria": 1, "seccion": "SS", "local": 1202, "letra_local": null, "bloque": null }

---

## Caso de Uso 3: Validación de Vigencia Incorrecta

**Descripción:** El usuario intenta dar de alta energía con una vigencia inválida.

**Precondiciones:**
El local es válido y no tiene energía.

**Pasos a seguir:**
1. El usuario llena el formulario de alta de energía con vigencia 'X'.
2. Presiona 'Grabar'.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error sobre la vigencia.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 34, "categoria": 1, "seccion": "SS", "local": 1202, "letra_local": null, "bloque": null, "cve_consumo": "F", "descripcion": "Local 1202", "cantidad": 100, "vigencia": "X", "fecha_alta": "2024-06-01", "axo": 2024, "numero": "OF-1202" }

---

