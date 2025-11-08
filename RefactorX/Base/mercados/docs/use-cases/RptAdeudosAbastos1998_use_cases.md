# Casos de Uso - RptAdeudosAbastos1998

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Abastos 1998 para Cruz del Sur

**Descripción:** El usuario desea consultar todos los adeudos del año 1998 para la oficina Cruz del Sur (oficina 5) hasta el periodo 12.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar adeudos.

**Pasos a seguir:**
1. El usuario accede a la página 'Adeudos Abastos 1998'.
2. Selecciona año 1998, oficina 'Cruz del Sur', periodo 12.
3. Presiona el botón 'Buscar'.
4. El sistema muestra la tabla de adeudos, meses, totales y desglose de renta.

**Resultado esperado:**
Se muestra el listado completo de adeudos de la oficina Cruz del Sur para el año 1998, con totales y desglose correcto.

**Datos de prueba:**
{ "axo": 1998, "oficina": 5, "periodo": 12 }

---

## Caso de Uso 2: Consulta de Renta para Local Específico

**Descripción:** El usuario desea consultar la renta de un local específico en 1998.

**Precondiciones:**
El usuario conoce los valores de categoría, sección y clave de cuota.

**Pasos a seguir:**
1. El usuario accede a la funcionalidad de consulta de renta.
2. Ingresa año 1998, categoría 2, sección 'SS', clave de cuota 4.
3. El sistema consulta y muestra la información de renta.

**Resultado esperado:**
Se muestra la información de renta correspondiente al local solicitado.

**Datos de prueba:**
{ "vaxo": 1998, "vcat": 2, "vsec": "SS", "vcve": 4 }

---

## Caso de Uso 3: Consulta de Meses de Adeudo para Local

**Descripción:** El usuario desea ver los meses de adeudo de un local específico en 1998.

**Precondiciones:**
El usuario conoce el id_local.

**Pasos a seguir:**
1. El usuario accede a la funcionalidad de consulta de meses de adeudo.
2. Ingresa id_local 1234 y año 1998.
3. El sistema consulta y muestra los meses y montos de adeudo.

**Resultado esperado:**
Se muestra la lista de meses y montos de adeudo para el local solicitado.

**Datos de prueba:**
{ "vid_local": 1234, "vaxo": 1998 }

---

