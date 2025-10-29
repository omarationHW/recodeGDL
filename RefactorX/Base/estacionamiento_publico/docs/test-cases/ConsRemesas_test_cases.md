# Casos de Prueba: Consulta de Remesas

## Caso 1: Consulta de remesas del estado (Tipo A)
- **Precondición:** Existen remesas de tipo 'A' en ta14_bitacora.
- **Acción:** Acceder a la página y verificar que se muestran las remesas de tipo 'A'.
- **Resultado esperado:** Tabla con remesas tipo 'A' ordenadas por num_remesa descendente.

## Caso 2: Consulta de detalle de remesa del estado
- **Precondición:** Existe una remesa de tipo 'A' con num_remesa = 1001 y registros en ta14_datos_edo con remesa = 'dti_est_r1001'.
- **Acción:** Hacer doble clic sobre la remesa 1001.
- **Resultado esperado:** Se muestra el detalle de la remesa. Si no hay registros, se muestra mensaje de advertencia.

## Caso 3: Consulta de remesas de pagos en Banorte (Tipo D)
- **Precondición:** Existen remesas de tipo 'D' en ta14_bitacora.
- **Acción:** Seleccionar la opción 'Pgos. en Banorte'.
- **Resultado esperado:** Tabla con remesas tipo 'D' ordenadas por num_remesa descendente.

## Caso 4: Consulta de detalle de remesa municipal
- **Precondición:** Existe una remesa de tipo 'B' con num_remesa = 2002 y registros en ta14_datos_mpio con remesa = 'ayt_gdl_r2002'.
- **Acción:** Seleccionar 'Altas enviadas', hacer doble clic sobre la remesa 2002.
- **Resultado esperado:** Se muestra el detalle de la remesa municipal.

## Caso 5: Consulta de detalle sin registros
- **Precondición:** Existe una remesa de tipo 'A' con num_remesa = 9999 pero sin registros en ta14_datos_edo.
- **Acción:** Hacer doble clic sobre la remesa 9999.
- **Resultado esperado:** Se muestra mensaje de advertencia 'No hay detalle para esta remesa.'
