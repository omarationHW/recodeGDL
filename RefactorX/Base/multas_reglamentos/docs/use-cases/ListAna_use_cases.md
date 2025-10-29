# Casos de Uso - ListAna

**Categoría:** Form

## Caso de Uso 1: Consulta de cajas disponibles para una fecha y recaudadora

**Descripción:** El usuario selecciona una fecha y una recaudadora, y el sistema muestra las cajas disponibles para esa combinación.

**Precondiciones:**
Existen registros en la tabla pagos para la fecha y recaudadora seleccionadas.

**Pasos a seguir:**
1. El usuario ingresa a la página ListAna.
2. Selecciona una fecha y una recaudadora.
3. El sistema consulta las cajas disponibles y las muestra en el combo de cajas.

**Resultado esperado:**
El combo de cajas se llena con las cajas disponibles para la fecha y recaudadora seleccionadas.

**Datos de prueba:**
fecha: '2024-06-10', recaud: '1'

---

## Caso de Uso 2: Generación de reporte analítico de ingresos diarios

**Descripción:** El usuario selecciona fecha, recaudadora y caja, y genera el reporte con totales y detalle.

**Precondiciones:**
Existen pagos registrados para la fecha, recaudadora y caja seleccionadas.

**Pasos a seguir:**
1. El usuario selecciona fecha, recaudadora y caja.
2. Da clic en 'Imprimir'.
3. El sistema consulta totales, folios y detalle de pagos y muestra el reporte.

**Resultado esperado:**
Se muestra el resumen de totales, folios y el detalle de pagos en la tabla.

**Datos de prueba:**
fecha: '2024-06-10', recaud: '1', caja: 'A'

---

## Caso de Uso 3: Manejo de ausencia de datos

**Descripción:** El usuario selecciona una combinación de fecha, recaudadora y caja para la cual no existen pagos.

**Precondiciones:**
No existen registros en pagos para la combinación seleccionada.

**Pasos a seguir:**
1. El usuario selecciona fecha, recaudadora y caja sin datos.
2. Da clic en 'Imprimir'.
3. El sistema muestra totales y folios en cero o vacío, y la tabla de detalle vacía.

**Resultado esperado:**
El sistema indica que no hay datos para mostrar, sin errores.

**Datos de prueba:**
fecha: '2024-01-01', recaud: '5', caja: 'Z'

---

