## Casos de Prueba para Listado de Diferencias

### Caso 1: Consulta básica sin filtro de vigencia
- **Entrada:** fecha1 = '2024-06-01', fecha2 = '2024-06-30', vigencia = ''
- **Acción:** Buscar
- **Esperado:** Se muestran todos los registros entre las fechas, sin filtrar por vigencia. El total de registros y suma total son correctos.

### Caso 2: Consulta solo vigentes
- **Entrada:** fecha1 = '2024-06-01', fecha2 = '2024-06-30', vigencia = 'V'
- **Acción:** Buscar
- **Esperado:** Solo se muestran registros con vigencia = 'V'.

### Caso 3: Consulta sin resultados
- **Entrada:** fecha1 = '1990-01-01', fecha2 = '1990-01-31', vigencia = ''
- **Acción:** Buscar
- **Esperado:** Se muestra mensaje 'No se encontraron resultados.'

### Caso 4: Exportación a Excel
- **Entrada:** fecha1 = '2024-06-01', fecha2 = '2024-06-30', vigencia = 'P'
- **Acción:** Exportar Excel
- **Esperado:** Se genera archivo Excel con los datos filtrados.

### Caso 5: Error de parámetros
- **Entrada:** fecha1 = '', fecha2 = '', vigencia = ''
- **Acción:** Buscar
- **Esperado:** Se muestra mensaje de error de validación.

### Caso 6: Error de backend
- **Simulación:** El stored procedure lanza una excepción.
- **Esperado:** Se muestra mensaje de error técnico en el frontend.
