# Casos de Prueba: Estadísticas de Periodos

## Caso 1: Consulta exitosa con detalle
- **Entrada:** axo=2024, adeudo=10000, opc=1
- **Acción:** POST /api/execute con eRequest.action=getEstadisticasPeriodos
- **Verifica:**
  - Respuesta HTTP 200
  - eResponse.success == true
  - eResponse.data es array con al menos un elemento
  - Cada elemento tiene campos: plazo, desc_plazo, axo_firma, costo, parc_pagos, saldo_real, estado, colonia, calle, folio

## Caso 2: Consulta solo totales
- **Entrada:** axo=2023, adeudo=0, opc=2
- **Acción:** POST /api/execute con eRequest.action=getEstadisticasPeriodos
- **Verifica:**
  - Respuesta HTTP 200
  - eResponse.success == true
  - eResponse.data es array
  - Los elementos NO incluyen colonia, calle, folio

## Caso 3: Consulta sin resultados
- **Entrada:** axo=1990, adeudo=0, opc=1
- **Acción:** POST /api/execute con eRequest.action=getEstadisticasPeriodos
- **Verifica:**
  - Respuesta HTTP 200
  - eResponse.success == true
  - eResponse.data es array vacío
  - Mensaje indica que no hay resultados

## Caso 4: Exportación a Excel
- **Entrada:** axo=2024, adeudo=5000, opc=1
- **Acción:** POST /api/execute con eRequest.action=exportEstadisticasPeriodos
- **Verifica:**
  - Respuesta HTTP 200
  - eResponse.success == true
  - eResponse.data.download_url existe y es válida

## Caso 5: Error por falta de año de obra
- **Entrada:** adeudo=10000, opc=1 (sin axo)
- **Acción:** POST /api/execute con eRequest.action=getEstadisticasPeriodos
- **Verifica:**
  - Respuesta HTTP 200
  - eResponse.success == false
  - eResponse.message indica que el año de obra es requerido
