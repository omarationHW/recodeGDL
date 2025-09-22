# Casos de Prueba: Estadísticas de Adeudos

## Caso 1: Consulta Global
- **Entrada:**
  - action: getEstadisticasGlobal
  - params: { year: 2024, month: 6 }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: array con columnas [oficina, num_mercado, local_count, adeudo, descripcion]

## Caso 2: Consulta por Importe
- **Entrada:**
  - action: getEstadisticasImporte
  - params: { year: 2024, month: 6, importe: 3000 }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: array solo con mercados con adeudo >= 3000

## Caso 3: Desglose por Importe
- **Entrada:**
  - action: getDesgloceAdeudosPorImporte
  - params: { year: 2024, month: 5, importe: 5000 }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: array con columnas [id_local, oficina, mercado, categoria, seccion, local, letra, bloque, nombre, descripcion, ade_ant, ade_2004, ade_2005, ade_2006, ade_2007, ade_2008, tot_ade]

## Caso 4: Parámetros Inválidos
- **Entrada:**
  - action: getEstadisticasImporte
  - params: { year: 2024, month: 6 }
- **Esperado:**
  - HTTP 200
  - success: false
  - message: error de parámetros

## Caso 5: Acción No Soportada
- **Entrada:**
  - action: getFooBar
  - params: {}
- **Esperado:**
  - HTTP 200
  - success: false
  - message: 'Acción no soportada'
