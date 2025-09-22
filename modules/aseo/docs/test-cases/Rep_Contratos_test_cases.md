# Casos de Prueba para Rep_Contratos

## Caso 1: Reporte Empresa-Contratos (Todos)
- **Entrada:**
  - empresa_id: null
  - tipo_aseo_id: null
  - vigencia: 'V'
  - recaudadora_id: null
  - tipoReporte: 'empresa_contratos'
  - orden: 'ctrol_emp,num_empresa'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.reporte contiene empresas y contratos vigentes, ordenados por tipo de empresa y número de empresa.

## Caso 2: Búsqueda por Nombre de Empresa
- **Entrada:**
  - action: 'buscar_empresas'
  - nombre: 'ALFA'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.empresas contiene empresas cuyo nombre incluye 'ALFA'.

## Caso 3: Reporte Solo Contratos, Filtro por Tipo de Aseo y Recaudadora
- **Entrada:**
  - empresa_id: null
  - tipo_aseo_id: 4
  - vigencia: 'T'
  - recaudadora_id: 1
  - tipoReporte: 'solo_contratos'
  - orden: 'ctrol_aseo,num_contrato'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.reporte contiene solo contratos de tipo aseo 4 y recaudadora 1.

## Caso 4: Error de Acción No Soportada
- **Entrada:**
  - action: 'accion_inexistente'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.error indica 'Acción no soportada'.

## Caso 5: Empresa sin Contratos
- **Entrada:**
  - empresa_id: 9999 (empresa sin contratos)
  - tipoReporte: 'solo_contratos'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.reporte es un arreglo vacío.
