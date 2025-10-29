# Casos de Uso - PagosIndividual

**Categoría:** Form

## Caso de Uso 1: Consulta de Pago Individual Existente

**Descripción:** El usuario consulta el pago de un local que existe y tiene pagos registrados.

**Precondiciones:**
El local con ID 123 tiene un pago registrado para el año 2024 y mes 6.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Individual de Pagos del Local.
2. Ingresa ID Local = 123, Año = 2024, Mes = 6.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra la información completa del pago, local, mercado y usuario.

**Datos de prueba:**
{ "id_local": 123, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 2: Consulta de Pago Individual Inexistente

**Descripción:** El usuario consulta un pago que no existe para el local y periodo especificados.

**Precondiciones:**
El local con ID 999 no tiene pagos registrados para el año 2024 y mes 6.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Individual de Pagos del Local.
2. Ingresa ID Local = 999, Año = 2024, Mes = 6.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que no se encontró el pago.

**Datos de prueba:**
{ "id_local": 999, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 3: Consulta con Parámetros Inválidos

**Descripción:** El usuario intenta consultar sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario deja vacío el campo 'Año'.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Individual de Pagos del Local.
2. Ingresa ID Local = 123, deja vacío el campo Año, Mes = 6.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los parámetros son inválidos.

**Datos de prueba:**
{ "id_local": 123, "axo": "", "periodo": 6 }

---

