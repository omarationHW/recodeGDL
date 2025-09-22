# Casos de Prueba para Estado de Cuenta de Adeudos Vencidos

## Caso 1: Consulta exitosa de adeudos vencidos
- **Entrada:** control_contrato = 1228
- **Acción:** Consultar sin periodo
- **Esperado:**
  - Se muestra la empresa asociada
  - Se listan los adeudos vencidos
  - Se calculan y muestran los recargos
  - Los totales son correctos

## Caso 2: Consulta con periodo límite
- **Entrada:** control_contrato = 1228, periodo = '2024-06'
- **Acción:** Consultar
- **Esperado:**
  - Se muestran solo los adeudos hasta el periodo 2024-06
  - Recargos y totales corresponden a los adeudos filtrados

## Caso 3: Contrato sin adeudos vencidos
- **Entrada:** control_contrato = 9999
- **Acción:** Consultar
- **Esperado:**
  - Se muestra mensaje "No se encontraron adeudos vencidos para este contrato."

## Caso 4: Contrato inexistente
- **Entrada:** control_contrato = 0
- **Acción:** Consultar
- **Esperado:**
  - Se muestra mensaje de error o "No se encontraron adeudos vencidos para este contrato."

## Caso 5: Validación de campos obligatorios
- **Entrada:** control_contrato vacío
- **Acción:** Consultar
- **Esperado:**
  - Se muestra mensaje "Debe ingresar el número de contrato."

## Caso 6: Cálculo correcto de recargos
- **Entrada:** control_contrato con adeudos de diferentes tipos y periodos
- **Acción:** Consultar
- **Esperado:**
  - El importe de recargo para cada adeudo corresponde a la suma de porc_recargo según el periodo calculado

## Caso 7: Consulta con error de conexión
- **Simulación:** API no responde
- **Esperado:**
  - Se muestra mensaje de error de red o conexión
