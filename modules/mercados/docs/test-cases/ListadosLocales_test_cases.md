# Casos de Prueba - ListadosLocales

## Prueba 1: Consulta de Padrón de Locales
- **Entrada**: recaudadora_id=1, mercado_id=5
- **Acción**: getPadronLocales
- **Esperado**: Respuesta con array de locales, cada uno con campos: id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, superficie, renta, vigencia

## Prueba 2: Consulta de Movimientos de Locales
- **Entrada**: recaudadora_id=2, fecha_desde='2024-01-01', fecha_hasta='2024-01-31'
- **Acción**: getMovimientosLocales
- **Esperado**: Respuesta con array de movimientos, cada uno con campos: id_movimiento, fecha, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, tipodescripcion, nombre

## Prueba 3: Consulta de Ingreso por Zonas
- **Entrada**: fecha_desde='2024-01-01', fecha_hasta='2024-01-31'
- **Acción**: getIngresoZonificado
- **Esperado**: Respuesta con array de ingresos, cada uno con campos: id_zona, zona, pagado

## Prueba 4: Exportación a Excel (no implementada)
- **Entrada**: recaudadora_id=1, mercado_id=5
- **Acción**: exportPadronExcel
- **Esperado**: Mensaje de éxito o advertencia de implementación pendiente

## Prueba 5: Validación de parámetros faltantes
- **Entrada**: acción sin parámetros requeridos
- **Esperado**: Respuesta HTTP 400 con mensaje de error
