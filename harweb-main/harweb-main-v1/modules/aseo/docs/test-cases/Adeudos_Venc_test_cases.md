# Casos de Prueba para Adeudos_Venc

## Caso 1: Consulta de Adeudos Vencidos Vigentes
- **Entrada:**
  ```json
  { "eRequest": { "action": "buscarContrato", "params": { "num_contrato": 12345, "ctrol_aseo": 9 } } }
  ```
- **Esperado:**
  - Respuesta contiene datos del contrato.
  - Posterior consulta a `getAdeudos` devuelve lista de adeudos con status 'V'.

## Caso 2: Consulta de Adeudos de Otro Periodo
- **Entrada:**
  ```json
  { "eRequest": { "action": "getAdeudos", "params": { "control_contrato": 12345, "vigencia": "O", "aso": 2023, "mes": 5 } } }
  ```
- **Esperado:**
  - Respuesta contiene lista de adeudos para el periodo 2023-05.

## Caso 3: Generación de Reporte de Adeudos Vencidos
- **Entrada:**
  ```json
  { "eRequest": { "action": "getReporte", "params": { "control_contrato": 12345, "vigencia": "V" } } }
  ```
- **Esperado:**
  - Respuesta contiene resumen de requerimientos, importe multa, gastos, recargos y total.

## Caso 4: Error por Contrato Inexistente
- **Entrada:**
  ```json
  { "eRequest": { "action": "buscarContrato", "params": { "num_contrato": 999999, "ctrol_aseo": 9 } } }
  ```
- **Esperado:**
  - Respuesta contiene error o array vacío.

## Caso 5: Error por Parámetros Faltantes
- **Entrada:**
  ```json
  { "eRequest": { "action": "getAdeudos", "params": { } } }
  ```
- **Esperado:**
  - Respuesta contiene error indicando parámetros requeridos.
