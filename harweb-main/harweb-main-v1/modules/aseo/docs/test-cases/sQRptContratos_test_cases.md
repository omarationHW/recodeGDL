## Casos de Prueba para Reporte de Contratos

### Caso 1: Consulta general sin filtros
- **Entrada:**
  - seleccion: 1
  - Ofna: 0
  - Rep: 0
  - opcion: 1
  - Num_emp: 0
  - Ctrol_Aseo: 0
  - Vigencia: 'T'
- **Esperado:**
  - Respuesta HTTP 200
  - eResponse.success = true
  - eResponse.data.contratos contiene todos los contratos (excepto status 'Z')
  - Totales correctos

### Caso 2: Filtro por empresa
- **Entrada:**
  - seleccion: 2
  - Num_emp: 3
  - Ofna: 0
  - Rep: 0
  - opcion: 2
  - Ctrol_Aseo: 0
  - Vigencia: 'T'
- **Esperado:**
  - Solo contratos de la empresa 3
  - Totales corresponden a esa empresa

### Caso 3: Contratos cancelados de tipo de aseo específico
- **Entrada:**
  - seleccion: 1
  - Ofna: 0
  - Rep: 0
  - opcion: 3
  - Num_emp: 0
  - Ctrol_Aseo: 5
  - Vigencia: 'C'
- **Esperado:**
  - Solo contratos cancelados con Ctrol_Aseo=5
  - Totales correctos

### Caso 4: Sin resultados
- **Entrada:**
  - seleccion: 2
  - Num_emp: 9999 (empresa inexistente)
  - Ofna: 0
  - Rep: 0
  - opcion: 1
  - Ctrol_Aseo: 0
  - Vigencia: 'T'
- **Esperado:**
  - eResponse.data.contratos es array vacío
  - Totales en cero

### Caso 5: Error de parámetros
- **Entrada:**
  - eRequest: 'RptContratos'
  - params: { seleccion: 'abc' } (valor inválido)
- **Esperado:**
  - eResponse.success = false
  - Mensaje de error adecuado
