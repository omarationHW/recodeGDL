# Casos de Prueba para GAdeudos_OpcMult_RA

## Caso 1: Consulta exitosa por expediente
- **Entrada:**
  - eRequest: get_datos_concesion
  - params: { par_tab: 2, par_control: 'ABCD12345' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data[0].status != -1
  - eResponse.data[0].concesionario no vacío

## Caso 2: Consulta exitosa por local y letra
- **Entrada:**
  - eRequest: get_datos_concesion
  - params: { par_tab: 3, par_control: '10-B' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data[0].status != -1
  - eResponse.data[0].ubicacion no vacío

## Caso 3: Consulta con expediente inexistente
- **Entrada:**
  - eRequest: get_datos_concesion
  - params: { par_tab: 2, par_control: 'ZZZZ99999' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data[0].status == -1
  - Mensaje de error mostrado en frontend

## Caso 4: Validación de campos vacíos
- **Entrada:**
  - eRequest: get_datos_concesion
  - params: { par_tab: 3, par_control: '' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data vacío o status == -1
  - Mensaje de error mostrado en frontend

## Caso 5: Consulta de catálogo de recaudadoras
- **Entrada:**
  - eRequest: get_recaudadoras
  - params: { }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es array con al menos un elemento

## Caso 6: Consulta de pagos realizados
- **Entrada:**
  - eRequest: get_pagados
  - params: { p_Control: 123 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es array (puede estar vacío si no hay pagos)
