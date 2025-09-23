# Casos de Uso - pagosdivfrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda de pagos diversos por fecha y recaudadora

**Descripción:** El usuario desea consultar todos los pagos diversos realizados en una fecha específica y por una recaudadora determinada.

**Precondiciones:**
Existen pagos diversos registrados en la base de datos para la fecha y recaudadora indicadas.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos Diversos.
2. Ingresa la fecha deseada en el campo 'Fecha'.
3. Ingresa el número de recaudadora en el campo 'Rec'.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los pagos diversos que coinciden con la fecha y recaudadora ingresadas.

**Datos de prueba:**
fecha: 2024-06-10
recaud: 2
caja: (vacío)
folio: (vacío)
contribuyente: (vacío)

---

## Caso de Uso 2: Consulta de detalle de un pago diverso

**Descripción:** El usuario desea ver el detalle completo de un pago diverso específico, incluyendo contribuyente, concepto, aplicaciones y cancelación.

**Precondiciones:**
Existe al menos un pago diverso en la base de datos.

**Pasos a seguir:**
1. El usuario realiza una búsqueda general de pagos diversos.
2. En la tabla de resultados, identifica el pago de interés y presiona el botón 'Detalle'.

**Resultado esperado:**
Se muestra la información detallada del pago, incluyendo nombre, domicilio, concepto, aplicaciones y, si existe, información de cancelación.

**Datos de prueba:**
cvepago: 12345 (debe existir en la base de datos)

---

## Caso de Uso 3: Búsqueda por nombre de contribuyente

**Descripción:** El usuario busca pagos diversos filtrando por el nombre del contribuyente.

**Precondiciones:**
Existen pagos diversos asociados a contribuyentes cuyos nombres contienen la cadena buscada.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos Diversos.
2. Ingresa una parte del nombre del contribuyente en el campo 'Nombre'.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestran todos los pagos diversos cuyo contribuyente coincide parcial o totalmente con el texto ingresado.

**Datos de prueba:**
contribuyente: "JUAN"

---

