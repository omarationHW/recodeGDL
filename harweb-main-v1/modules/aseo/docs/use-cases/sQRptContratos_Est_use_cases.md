# Casos de Uso - sQRptContratos_Est

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadística General de Contratos (Todos los Tipos)

**Descripción:** El usuario desea ver la estadística general de contratos de aseo para todos los tipos y el periodo actual.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contratos y pagos registrados.

**Pasos a seguir:**
1. El usuario accede a la página de Estadística de Contratos.
2. Selecciona 'Todos' en el filtro de Tipo de Aseo.
3. Selecciona el año y mes actual como inicio y fin.
4. Presiona 'Consultar Estadística'.

**Resultado esperado:**
Se muestra una tabla con los totales y desgloses de contratos, importes, cuotas normales, excedentes, contenedores, vigentes, cancelados, pagados y condonados para todos los tipos de aseo.

**Datos de prueba:**
Contratos de tipo O, H, C con pagos en el periodo actual.

---

## Caso de Uso 2: Consulta de Estadística por Tipo de Aseo y Periodo

**Descripción:** El usuario desea ver la estadística de contratos solo para el tipo 'O' (Ordinario) entre enero y junio de 2023.

**Precondiciones:**
Existen contratos y pagos de tipo 'O' en el periodo 2023-01 a 2023-06.

**Pasos a seguir:**
1. El usuario accede a la página de Estadística de Contratos.
2. Selecciona 'O' en el filtro de Tipo de Aseo.
3. Selecciona 2023/01 como inicio y 2023/06 como fin.
4. Presiona 'Consultar Estadística'.

**Resultado esperado:**
Se muestra la estadística solo para el tipo 'O' y el periodo seleccionado.

**Datos de prueba:**
Contratos y pagos de tipo 'O' en 2023-01 a 2023-06.

---

## Caso de Uso 3: Validación de Parámetros Inválidos

**Descripción:** El usuario intenta consultar la estadística con un año de inicio mayor al año de fin.

**Precondiciones:**
El sistema está en línea.

**Pasos a seguir:**
1. El usuario accede a la página de Estadística de Contratos.
2. Selecciona cualquier tipo de aseo.
3. Selecciona 2024/01 como inicio y 2023/12 como fin.
4. Presiona 'Consultar Estadística'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el periodo es inválido.

**Datos de prueba:**
No relevante (solo validación de parámetros).

---

