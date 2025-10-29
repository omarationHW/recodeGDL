## Casos de Prueba para Listados

### Caso 1: Consulta básica de Mercados
- **Entrada:**
  - id_rec: 1
  - modulo: 11
  - folio_desde: 100
  - folio_hasta: 200
  - clave: 'P'
  - vigencia: '1'
  - fecha_prac_desde: null
  - fecha_prac_hasta: null
- **Esperado:**
  - Respuesta success true
  - Al menos un registro con estado 'VIG' y clave_practicado 'P'

### Caso 2: Consulta con clave y vigencia 'todas'
- **Entrada:**
  - id_rec: 2
  - modulo: 24
  - folio_desde: 500
  - folio_hasta: 600
  - clave: 'todas'
  - vigencia: 'todas'
- **Esperado:**
  - Respuesta success true
  - Registros de folios de Estacionamientos Públicos en ese rango

### Caso 3: Consulta con filtro de fecha de practicado
- **Entrada:**
  - id_rec: 3
  - modulo: 16
  - folio_desde: 300
  - folio_hasta: 350
  - clave: 'P'
  - vigencia: '2'
  - fecha_prac_desde: '2024-01-01'
  - fecha_prac_hasta: '2024-03-31'
- **Esperado:**
  - Respuesta success true
  - Todos los registros tienen fecha_practicado entre 2024-01-01 y 2024-03-31

### Caso 4: Error por parámetros faltantes
- **Entrada:**
  - id_rec: null
  - modulo: 11
  - folio_desde: 1
  - folio_hasta: 10
- **Esperado:**
  - Respuesta success false
  - Mensaje de error indicando parámetro faltante

### Caso 5: Exportar Excel sin resultados
- **Entrada:**
  - Acción: exportExcel
  - Sin resultados previos
- **Esperado:**
  - Mensaje de funcionalidad no implementada
