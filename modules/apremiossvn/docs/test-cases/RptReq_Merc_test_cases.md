# Casos de Prueba: RptReq_Merc

## Caso 1: Consulta exitosa de reporte
- **Entrada:** ofna=1, folio1=100, folio2=105
- **Acción:** POST /api/execute con action=getRptReqMerc
- **Resultado esperado:** eResponse.success=true, eResponse.data contiene registros, eResponse.error=null

## Caso 2: Consulta de recaudadora
- **Entrada:** reca=1
- **Acción:** POST /api/execute con action=getRecaudadoraInfo
- **Resultado esperado:** eResponse.success=true, eResponse.data contiene datos de recaudadora, eResponse.error=null

## Caso 3: Rango de folios inválido
- **Entrada:** ofna=1, folio1=200, folio2=100
- **Acción:** POST /api/execute con action=getRptReqMerc
- **Resultado esperado:** eResponse.success=false, eResponse.data=null, eResponse.error contiene mensaje de error

## Caso 4: Sin resultados para rango válido
- **Entrada:** ofna=1, folio1=9999, folio2=10000
- **Acción:** POST /api/execute con action=getRptReqMerc
- **Resultado esperado:** eResponse.success=true, eResponse.data es array vacío, eResponse.error=null

## Caso 5: Error de parámetros faltantes
- **Entrada:** ofna=1, folio1=100 (falta folio2)
- **Acción:** POST /api/execute con action=getRptReqMerc
- **Resultado esperado:** eResponse.success=false, eResponse.error indica parámetro faltante

## Caso 6: Acción no soportada
- **Entrada:** action='accionInexistente'
- **Acción:** POST /api/execute
- **Resultado esperado:** eResponse.success=false, eResponse.error='Acción no soportada'
