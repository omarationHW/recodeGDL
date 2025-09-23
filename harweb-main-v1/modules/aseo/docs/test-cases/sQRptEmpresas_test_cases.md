# Casos de Prueba: Catálogo de Tipos de Empresas

## Caso 1: Consulta por Número de Empresa
- **Entrada:**
  - eRequest: getEmpresasReport
  - params: { opcion: 1 }
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con empresas ordenadas por num_empresa ascendente.

## Caso 2: Consulta por Tipo de Empresa
- **Entrada:**
  - eRequest: getEmpresasReport
  - params: { opcion: 2 }
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con empresas agrupadas y ordenadas por tipo_empresa, luego num_empresa.

## Caso 3: Consulta por Nombre
- **Entrada:**
  - eRequest: getEmpresasReport
  - params: { opcion: 3 }
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con empresas ordenadas por descripcion (nombre), luego num_empresa.

## Caso 4: Consulta por Representante
- **Entrada:**
  - eRequest: getEmpresasReport
  - params: { opcion: 4 }
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con empresas ordenadas por representante, luego num_empresa.

## Caso 5: Sin datos en la base
- **Precondición:** Tablas vacías.
- **Acción:**
  - Realizar cualquier consulta.
- **Resultado esperado:**
  - Respuesta JSON con data vacía (array vacío), success=true.

## Caso 6: Parámetro inválido
- **Entrada:**
  - eRequest: getEmpresasReport
  - params: { opcion: 99 }
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con data vacía o sin error, success=true.

## Caso 7: eRequest desconocido
- **Entrada:**
  - eRequest: unknownRequest
- **Acción:**
  - Realizar POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con success=false y mensaje de error.
