# Casos de Prueba: Adeudos Abastos 1998

## Caso 1: Consulta exitosa de adeudos
- **Entrada:** axo=1998, oficina=5, periodo=12
- **Acción:** POST /api/execute con action=get_adeudos_abastos_1998
- **Resultado esperado:**
  - Código HTTP 200
  - success=true
  - data: array con al menos un registro
  - Cada registro contiene campos: datoslocal, nombre, superficie, adeudo, meses, totmeses, renta_ea, renta_sd, recaudadora, descripcion

## Caso 2: Consulta de renta para local
- **Entrada:** vaxo=1998, vcat=2, vsec='SS', vcve=4
- **Acción:** POST /api/execute con action=get_renta_1998
- **Resultado esperado:**
  - Código HTTP 200
  - success=true
  - data: array con un registro con los campos de renta

## Caso 3: Consulta de meses de adeudo para local
- **Entrada:** vid_local=1234, vaxo=1998
- **Acción:** POST /api/execute con action=get_meses_adeudo_1998
- **Resultado esperado:**
  - Código HTTP 200
  - success=true
  - data: array con los meses y montos de adeudo

## Caso 4: Parámetros inválidos
- **Entrada:** axo=1997, oficina=5, periodo=12
- **Acción:** POST /api/execute con action=get_adeudos_abastos_1998
- **Resultado esperado:**
  - Código HTTP 200
  - success=true
  - data: array vacío

## Caso 5: Acción no soportada
- **Entrada:** action=unknown_action
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - Código HTTP 200
  - success=false
  - message: 'Acción no soportada'
