## Casos de Prueba para Requerimientos

### Caso 1: Búsqueda de Adeudos de Mercado
- **Entrada:** mercado=1, desde=1, hasta=10, adeudo_desde=100, adeudo_hasta=1000
- **Acción:** Buscar
- **Esperado:** Tabla con resultados filtrados, sin errores.

### Caso 2: Emisión de Requerimientos de Aseo
- **Entrada:** tipo_aseo='A', desde=100, hasta=200, adeudo_desde=500, adeudo_hasta=2000
- **Acción:** Buscar y luego Emitir Requerimientos
- **Esperado:** Mensaje de éxito, folios generados en la base de datos.

### Caso 3: Error por Falta de Parámetros
- **Entrada:** mercado='', desde=1, hasta=10, adeudo_desde=100, adeudo_hasta=1000
- **Acción:** Buscar
- **Esperado:** Mensaje de error 'El mercado es obligatorio'.

### Caso 4: SQL Injection Prevention
- **Entrada:** mercado="1; DROP TABLE mercados;--"
- **Acción:** Buscar
- **Esperado:** Error controlado, sin ejecución de SQL malicioso.

### Caso 5: Emisión sin Resultados
- **Entrada:** mercado=999, desde=1, hasta=1, adeudo_desde=99999, adeudo_hasta=100000
- **Acción:** Buscar y Emitir
- **Esperado:** Mensaje 'No existen registros a requerir'.
