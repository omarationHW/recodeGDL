## Casos de Prueba TitulosSin

### Caso 1: Impresión exitosa
- **Entradas:**
  - fecha: 2024-06-01
  - ofna: 1
  - caja: 'A'
  - operacion: 12345
  - folio: 1001
  - titulo: 555
  - partida: 10
  - telefono: '3331234567'
- **Acción:** Buscar ingresos y luego imprimir título
- **Esperado:** Se muestra vista previa y datos de impresión

### Caso 2: Ingreso inexistente
- **Entradas:**
  - fecha: 2024-06-01
  - ofna: 2
  - caja: 'B'
  - operacion: 99999
  - folio: 9999
- **Acción:** Buscar ingresos
- **Esperado:** Mensaje de error 'No se encontró el ingreso.'

### Caso 3: Validación de campos obligatorios
- **Entradas:**
  - fecha: 2024-06-01
  - ofna: 1
  - caja: 'A'
  - operacion: 12345
  - folio: ''
- **Acción:** Buscar ingresos
- **Esperado:** Mensaje de error 'Folio requerido.'

### Caso 4: Error de impresión sin ingreso
- **Entradas:**
  - fecha: 2024-06-01
  - ofna: 1
  - caja: 'A'
  - operacion: 12345
  - folio: 1001
  - titulo: 555
  - partida: 10
  - telefono: '3331234567'
- **Acción:** Intentar imprimir título sin haber buscado ingresos
- **Esperado:** Mensaje de error 'Datos requeridos para impresión.'

### Caso 5: Campos de teléfono y partida vacíos
- **Entradas:**
  - fecha: 2024-06-01
  - ofna: 1
  - caja: 'A'
  - operacion: 12345
  - folio: 1001
  - titulo: 555
  - partida: ''
  - telefono: ''
- **Acción:** Imprimir título
- **Esperado:** El sistema permite impresión pero los campos aparecen vacíos en el resultado
