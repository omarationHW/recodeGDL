# Casos de Prueba para Adeudos_EdoCta

## Caso 1: Consulta Vigente Exitosa
- **Entrada:** contrato=12345, ctrol_aseo=9, vigencia=V
- **Acción:** procesarAdeudos
- **Esperado:**
  - HTTP 200
  - eResponse.resultados contiene al menos un contrato
  - Cada contrato tiene detPagos y detPagosSum

## Caso 2: Consulta Otro Periodo Exitosa
- **Entrada:** contrato=12345, ctrol_aseo=9, vigencia=A, ejercicio=2023, mes=03
- **Acción:** procesarAdeudos
- **Esperado:**
  - HTTP 200
  - eResponse.resultados contiene al menos un contrato
  - detPagos corresponde al periodo solicitado

## Caso 3: Contrato Inexistente
- **Entrada:** contrato=99999, ctrol_aseo=9, vigencia=V
- **Acción:** procesarAdeudos
- **Esperado:**
  - HTTP 200
  - eResponse.error == 'No existen contratos con estos datos'

## Caso 4: Validación de Campos Obligatorios
- **Entrada:** contrato='', ctrol_aseo='', vigencia='V'
- **Acción:** procesarAdeudos
- **Esperado:**
  - HTTP 200
  - eResponse.error indica campos obligatorios faltantes

## Caso 5: SQL Injection Prevention
- **Entrada:** contrato="12345; DROP TABLE ta_16_contratos;--", ctrol_aseo=9, vigencia=V
- **Acción:** procesarAdeudos
- **Esperado:**
  - HTTP 200
  - eResponse.error (no ejecuta SQL malicioso)
