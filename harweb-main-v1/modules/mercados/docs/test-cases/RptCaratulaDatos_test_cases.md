# Casos de Prueba para RptCaratulaDatos

## Caso 1: Consulta exitosa de carátula con adeudos
- **Entrada:** id_local=1001, renta=1200.00, adeudo=600.00, recargos=60.00, gastos=20.00, multa=0.00, total=680.00, folios="1234,1235,", leyenda="Desc. pronto pago"
- **Acción:** POST /api/execute { action: 'getRptCaratulaDatos', params: ... }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: objeto con datos del local y arreglo de adeudos
  - Los recargos y leyenda calculados correctamente

## Caso 2: Consulta de local sin adeudos
- **Entrada:** id_local=2002, renta=900.00, adeudo=0.00, recargos=0.00, gastos=0.00, multa=0.00, total=900.00, folios="", leyenda=""
- **Acción:** POST /api/execute { action: 'getRptCaratulaDatos', params: ... }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: objeto con datos del local y arreglo de adeudos vacío

## Caso 3: Error por parámetro faltante
- **Entrada:** id_local=""
- **Acción:** POST /api/execute { action: 'getRptCaratulaDatos', params: ... }
- **Resultado esperado:**
  - HTTP 200
  - success: false
  - message: "ID Local es requerido" o mensaje similar

## Caso 4: Error de base de datos
- **Simulación:** Forzar error en SP (por ejemplo, id_local inexistente)
- **Resultado esperado:**
  - HTTP 200
  - success: false
  - message: error SQL o mensaje amigable
