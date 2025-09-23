# Casos de Prueba para RptReq_pba

## Caso 1: Consulta general sin filtro de sección
- **Entrada:**
  - vmerc1: 1
  - vmerc2: 2
  - vlocal1: 1
  - vlocal2: 100
  - vsecc: 'todas'
- **Acción:** POST /api/execute con eRequest=RptReqPba_getReportData
- **Esperado:**
  - Respuesta success=true
  - data contiene lista de adeudos de mercados 1 y 2
  - Campos recargos y total_gasto calculados

## Caso 2: Consulta filtrando por sección
- **Entrada:**
  - vmerc1: 1
  - vmerc2: 1
  - vlocal1: 10
  - vlocal2: 20
  - vsecc: 'A'
- **Acción:** POST /api/execute con eRequest=RptReqPba_getReportData
- **Esperado:**
  - Solo aparecen registros de sección 'A', locales 10-20, mercado 1

## Caso 3: Cálculo de recargos límite
- **Entrada:**
  - vmerc1: 1
  - vmerc2: 1
  - vlocal1: 5
  - vlocal2: 5
  - vsecc: 'B'
- **Acción:** POST /api/execute con eRequest=RptReqPba_getReportData
- **Esperado:**
  - El campo recargos nunca supera el 250% del importe
  - Si el periodo es el actual y día <= 12, recargos=0

## Caso 4: Gastos mínimos y máximos
- **Entrada:**
  - Parámetros que devuelvan registros con diferentes importes
- **Acción:** POST /api/execute con eRequest=RptReqPba_getGastos
- **Esperado:**
  - El campo gtos_requer nunca es menor que gtos_requer_anual ni mayor que gtos_requer_anual

## Caso 5: Error por parámetros inválidos
- **Entrada:**
  - vmerc1: 'abc' (no numérico)
- **Acción:** POST /api/execute con eRequest=RptReqPba_getReportData
- **Esperado:**
  - Respuesta success=false
  - Mensaje de error indicando parámetros inválidos
