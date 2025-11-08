# Casos de Prueba para DatosMovimientos

## Caso 1: Consulta exitosa de movimientos
- **Entrada:** id_local = 12345
- **Acción:** POST /api/execute { action: 'get_movimientos_by_local', params: { id_local: 12345 } }
- **Resultado esperado:** Respuesta success=true, data contiene lista de movimientos, cada uno con campos completos.

## Caso 2: Catálogo de claves de movimiento
- **Entrada:** POST /api/execute { action: 'get_clave_movimientos' }
- **Resultado esperado:** success=true, data contiene lista de claves de movimiento.

## Caso 3: Catálogo de claves de cuota
- **Entrada:** POST /api/execute { action: 'get_cve_cuotas' }
- **Resultado esperado:** success=true, data contiene lista de claves de cuota.

## Caso 4: Cálculo de descripción de vigencia
- **Entrada:** POST /api/execute { action: 'calc_vigencia_descripcion', params: { vigencia: 'C' } }
- **Resultado esperado:** success=true, data='BAJA POR ACUERDO'

## Caso 5: Cálculo de renta sección 'PS', clave_cuota=2
- **Entrada:** POST /api/execute { action: 'calc_renta', params: { superficie: 10, importe_cuota: 100, seccion: 'PS', clave_cuota: 2 } }
- **Resultado esperado:** success=true, data=30000

## Caso 6: Consulta de movimientos para local inexistente
- **Entrada:** id_local = 999999
- **Acción:** POST /api/execute { action: 'get_movimientos_by_local', params: { id_local: 999999 } }
- **Resultado esperado:** success=true, data=[]
