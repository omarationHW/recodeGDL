# Casos de Prueba: Catálogo de Recaudadoras

## Caso 1: Consulta por defecto (opcion=1)
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 1 }
- **Acción:**
  - POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con lista de recaudadoras ordenadas por id_rec ascendente.

## Caso 2: Consulta por nombre (opcion=2)
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 2 }
- **Acción:**
  - POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con lista de recaudadoras ordenadas alfabéticamente por recaudadora.

## Caso 3: Consulta por domicilio (opcion=3)
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 3 }
- **Acción:**
  - POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con lista de recaudadoras ordenadas alfabéticamente por domicilio.

## Caso 4: Consulta por sector y recaudadora (opcion=4)
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 4 }
- **Acción:**
  - POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con lista de recaudadoras agrupadas por sector y ordenadas por id_rec dentro de cada sector.

## Caso 5: Consulta sin registros
- **Preparación:**
  - Vaciar la tabla ta_12_recaudadoras.
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 1 }
- **Resultado esperado:**
  - Respuesta JSON con data vacía ([]).

## Caso 6: Error de parámetro
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 99 }
- **Resultado esperado:**
  - Respuesta JSON con data vacía o error manejado.

## Caso 7: eRequest desconocido
- **Entrada:**
  - eRequest: unknownRequest
- **Resultado esperado:**
  - Respuesta JSON con error 400 y mensaje 'Unknown eRequest: unknownRequest'.
