# Casos de Uso - RptPadronEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta exitosa del padrón de energía para un mercado existente

**Descripción:** El usuario ingresa una oficina y mercado válidos y obtiene el reporte completo con totales.

**Precondiciones:**
El usuario tiene acceso a la aplicación. Existen registros en las tablas para la oficina y mercado seleccionados.

**Pasos a seguir:**
1. Acceder a la página 'Padrón de Energía Eléctrica'.
2. Ingresar 'Oficina': 1.
3. Ingresar 'Mercado': 2.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra la tabla con los registros del padrón, el nombre del mercado, el total de registros y el total de cuota mensual.

**Datos de prueba:**
{ "oficina": 1, "mercado": 2 }

---

## Caso de Uso 2: Consulta con parámetros inválidos

**Descripción:** El usuario intenta consultar el reporte sin ingresar los parámetros requeridos.

**Precondiciones:**
El usuario tiene acceso a la aplicación.

**Pasos a seguir:**
1. Acceder a la página 'Padrón de Energía Eléctrica'.
2. Dejar vacíos los campos 'Oficina' y 'Mercado'.
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que los parámetros son inválidos.

**Datos de prueba:**
{ "oficina": "", "mercado": "" }

---

## Caso de Uso 3: Consulta de mercado sin registros

**Descripción:** El usuario consulta un mercado/oficina que existe pero no tiene registros de energía.

**Precondiciones:**
El usuario tiene acceso a la aplicación. El mercado/oficina existe pero no hay registros en ta_11_energia para ese mercado.

**Pasos a seguir:**
1. Acceder a la página 'Padrón de Energía Eléctrica'.
2. Ingresar 'Oficina': 99.
3. Ingresar 'Mercado': 99.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra la tabla vacía, el nombre del mercado (si existe), y totales en cero.

**Datos de prueba:**
{ "oficina": 99, "mercado": 99 }

---

