# Casos de Prueba - RepDescImpto

## 1. Consulta básica de descuentos aplicados
- **Entrada:** tipoArchivo=aplicados, tipoFecha=0, recaudadora="", tipoDescuento=""
- **Acción:** Buscar
- **Resultado esperado:** Lista de todos los descuentos aplicados, sin filtro de fechas ni recaudadora.

## 2. Consulta por rango de fechas de alta
- **Entrada:** tipoArchivo=aplicados, tipoFecha=1, fecha1=2024-01-01, fecha2=2024-03-31
- **Acción:** Buscar
- **Resultado esperado:** Solo descuentos aplicados con fecha de alta en el rango.

## 3. Consulta de descuentos reactivados por tipo
- **Entrada:** tipoArchivo=reactivados, tipoFecha=0, tipoDescuento=5
- **Acción:** Buscar
- **Resultado esperado:** Solo descuentos reactivados del tipo 5.

## 4. Consulta con recaudadora y tipo de descuento
- **Entrada:** tipoArchivo=aplicados, recaudadora=3, tipoDescuento=7
- **Acción:** Buscar
- **Resultado esperado:** Solo descuentos aplicados de la recaudadora 3 y tipo 7.

## 5. Exportación a Excel
- **Precondición:** Hay resultados en pantalla
- **Acción:** Click en 'Exportar Excel'
- **Resultado esperado:** Descarga o impresión de la tabla de resultados.

## 6. Validación de campos obligatorios
- **Entrada:** tipoArchivo=aplicados, tipoFecha=1, fecha1="", fecha2=""
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error indicando que las fechas son obligatorias.

## 7. Seguridad - Acceso sin autenticación
- **Acción:** Llamar a /api/execute sin token (si aplica)
- **Resultado esperado:** Error de autenticación o acceso denegado.
