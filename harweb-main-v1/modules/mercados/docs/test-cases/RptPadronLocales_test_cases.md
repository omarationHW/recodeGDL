# Casos de Prueba para RptPadronLocales

## Caso 1: Consulta exitosa de padrón
- **Input:** oficina=1, mercado=5
- **Acción:** POST /api/execute { action: 'getPadronLocales', params: { oficina: 1, mercado: 5 } }
- **Resultado esperado:** success=true, data contiene array de locales, message=''
- **Validar:**
  - El array no está vacío
  - Cada local tiene los campos: id_local, datosmercado, vigdescripcion, renta, etc.

## Caso 2: Parámetros faltantes
- **Input:** oficina=null, mercado=null
- **Acción:** POST /api/execute { action: 'getPadronLocales', params: { oficina: null, mercado: null } }
- **Resultado esperado:** success=false, data=null, message contiene 'Parámetros requeridos'

## Caso 3: Totales correctos
- **Input:** oficina=2, mercado=10
- **Acción:** POST /api/execute { action: 'getPadronLocales', params: { oficina: 2, mercado: 10 } }
- **Resultado esperado:** success=true, data contiene array de locales
- **Validar:**
  - Sumar superficie y renta de todos los locales y comparar con los totales mostrados en frontend

## Caso 4: Consulta de recaudadora
- **Input:** oficina=1
- **Acción:** POST /api/execute { action: 'getRecaudadora', params: { oficina: 1 } }
- **Resultado esperado:** success=true, data contiene info de recaudadora

## Caso 5: Consulta de mercados
- **Input:** oficina=1
- **Acción:** POST /api/execute { action: 'getMercado', params: { oficina: 1 } }
- **Resultado esperado:** success=true, data contiene array de mercados

## Caso 6: Consulta de renta
- **Input:** axo=2024, categoria=1, seccion='SS', clave_cuota=2
- **Acción:** POST /api/execute { action: 'getRenta', params: { axo:2024, categoria:1, seccion:'SS', clave_cuota:2 } }
- **Resultado esperado:** success=true, data contiene info de cuota
