# Casos de Prueba para GConsulta2

## Caso 1: Consulta por Control Existente
- **Entrada:**
  - action: gconsulta2.buscarCoincide
  - params: { par_tab: 3, tipo_busqueda: 1, dato_busqueda: 'SP/1' }
- **Esperado:**
  - Lista con al menos un control ('SP/1')
  - Al seleccionar, los datos principales y adeudos se muestran correctamente

## Caso 2: Consulta por Nombre Comercial Inexistente
- **Entrada:**
  - action: gconsulta2.buscarCoincide
  - params: { par_tab: 3, tipo_busqueda: 4, dato_busqueda: 'NOEXISTE' }
- **Esperado:**
  - Lista vacía
  - No se muestran datos ni adeudos

## Caso 3: Visualización de Totales y Apremios
- **Entrada:**
  - action: gconsulta2.buscarTotales
  - params: { par_tabla: 3, par_id_datos: 12345, par_aso: 2024, par_mes: 12 }
- **Esperado:**
  - Se listan los totales
  - Si algún concepto es 'Gastos' o 'Multas', el botón de Apremios se habilita

## Caso 4: Consulta de Pagos Realizados
- **Entrada:**
  - action: gconsulta2.buscarPagados
  - params: { p_Control: 12345 }
- **Esperado:**
  - Se listan los pagos realizados para el control

## Caso 5: Error de Parámetros Faltantes
- **Entrada:**
  - action: gconsulta2.buscarCont
  - params: { par_tab: 3 }
- **Esperado:**
  - success: false
  - message: error indicando parámetro faltante
