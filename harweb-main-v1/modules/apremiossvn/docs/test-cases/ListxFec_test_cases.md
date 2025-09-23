## Casos de Prueba para ListxFec

### Caso 1: Reporte por fecha de practicado (Mercados)
- **Entrada:**
  - rec: 2
  - modulo: 11
  - tipo_fecha: 2
  - fecha1: 2024-01-01
  - fecha2: 2024-01-31
  - vigencia: 'todas'
  - ejecutor: 'todos'
- **Esperado:**
  - Tabla con folios practicados en ese rango, datos completos.

### Caso 2: Reporte filtrado por ejecutor y vigencia (Aseo)
- **Entrada:**
  - rec: 3
  - modulo: 16
  - tipo_fecha: 1
  - fecha1: 2024-02-01
  - fecha2: 2024-02-28
  - vigencia: '1'
  - ejecutor: '5'
- **Esperado:**
  - Solo folios vigentes del ejecutor 5.

### Caso 3: Reporte de pagos (Estacionamientos Públicos)
- **Entrada:**
  - rec: 4
  - modulo: 24
  - tipo_fecha: 4
  - fecha1: 2024-03-01
  - fecha2: 2024-03-31
  - vigencia: '2'
  - ejecutor: 'todos'
- **Esperado:**
  - Folios pagados en ese rango.

### Caso 4: Validación de fechas incorrectas
- **Entrada:** fecha1 > fecha2
- **Esperado:** Error en frontend y no se realiza consulta.

### Caso 5: Sin resultados
- **Entrada:** Rango de fechas sin datos
- **Esperado:** Tabla vacía, mensaje 'No hay resultados'.
