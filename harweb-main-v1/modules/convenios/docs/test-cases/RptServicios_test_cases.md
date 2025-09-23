# Casos de Prueba para RptServicios

## Caso 1: Consulta exitosa del catálogo
- **Precondición:** Existen 3 registros en ta_17_servicios.
- **Acción:** POST /api/execute { eRequest: 'RptServicios.getAll', params: {} }
- **Resultado esperado:**
  - success: true
  - data: Array de 3 objetos con campos servicio, descripcion, serv_obra94
  - error: null

## Caso 2: Conteo correcto de servicios
- **Precondición:** Existen 7 registros en ta_17_servicios.
- **Acción:** POST /api/execute { eRequest: 'RptServicios.count', params: {} }
- **Resultado esperado:**
  - success: true
  - data: 7
  - error: null

## Caso 3: Error por tabla inexistente
- **Precondición:** La tabla ta_17_servicios no existe.
- **Acción:** POST /api/execute { eRequest: 'RptServicios.getAll', params: {} }
- **Resultado esperado:**
  - success: false
  - data: null
  - error: Mensaje de error indicando que la tabla no existe

## Caso 4: eRequest desconocido
- **Precondición:** Sistema operativo normalmente.
- **Acción:** POST /api/execute { eRequest: 'RptServicios.unknown', params: {} }
- **Resultado esperado:**
  - success: false
  - data: null
  - error: 'Unknown eRequest: RptServicios.unknown'

## Caso 5: Visualización en frontend
- **Precondición:** Existen 2 servicios en la base.
- **Acción:** El usuario navega a '/rpt-servicios'.
- **Resultado esperado:**
  - Se muestra una tabla con 2 filas y el total indica 2.
  - El logo y los encabezados se visualizan correctamente.
