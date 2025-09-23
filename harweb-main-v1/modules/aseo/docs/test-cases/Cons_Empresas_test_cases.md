# Casos de Prueba: Consulta de Empresas

## Caso 1: Consulta por número y tipo
- **Entrada:**
  - action: byNumber
  - params: { num_empresa: 123, ctrol_emp: 9 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene exactamente una empresa con num_empresa=123 y ctrol_emp=9

## Caso 2: Consulta por nombre parcial
- **Entrada:**
  - action: byName
  - params: { nombre: "ACME" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene una o más empresas cuyo campo descripcion incluye "ACME"

## Caso 3: Consulta de todas las empresas
- **Entrada:**
  - action: all
  - params: { }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene todas las empresas existentes

## Caso 4: Exportar empresas
- **Entrada:**
  - action: export
  - params: { }
- **Esperado:**
  - eResponse.success = true
  - eResponse.export = true
  - eResponse.data contiene todas las empresas

## Caso 5: Listar tipos de empresa
- **Entrada:**
  - action: listTiposEmp
  - params: { }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene todos los tipos de empresa

## Caso 6: Error por parámetros faltantes
- **Entrada:**
  - action: byNumber
  - params: { num_empresa: 123 }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica error de parámetros
