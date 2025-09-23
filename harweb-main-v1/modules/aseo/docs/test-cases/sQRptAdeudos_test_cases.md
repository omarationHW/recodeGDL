# Casos de Prueba para Reporte de Adeudos Generales

## Caso 1: Consulta general sin filtros
- **Entrada**:
  - sel_emp: 1
  - num_emp: 0
  - sel_cont: 1
  - num_cont: 0
  - sel_ctrol_aseo: 0
  - vig_cont: 'T'
  - vig_adeudos: 'T'
  - ofna: 0
  - opcion: 1
- **Esperado**: Se listan todos los adeudos existentes en la base de datos.

## Caso 2: Consulta por empresa y contratos vigentes
- **Entrada**:
  - sel_emp: 2
  - num_emp: 123
  - sel_cont: 1
  - num_cont: 0
  - sel_ctrol_aseo: 0
  - vig_cont: 'V'
  - vig_adeudos: 'T'
  - ofna: 0
  - opcion: 1
- **Esperado**: Sólo se muestran los adeudos de la empresa 123 y contratos vigentes.

## Caso 3: Consulta por tipo de aseo y recaudadora
- **Entrada**:
  - sel_emp: 1
  - num_emp: 0
  - sel_cont: 1
  - num_cont: 0
  - sel_ctrol_aseo: 5
  - vig_cont: 'T'
  - vig_adeudos: 'T'
  - ofna: 2
  - opcion: 1
- **Esperado**: Sólo se muestran los adeudos con tipo de aseo 5 y recaudadora 2.

## Caso 4: Consulta por contrato específico y vigencia cancelada
- **Entrada**:
  - sel_emp: 1
  - num_emp: 0
  - sel_cont: 2
  - num_cont: 456
  - sel_ctrol_aseo: 0
  - vig_cont: 'C'
  - vig_adeudos: 'T'
  - ofna: 0
  - opcion: 1
- **Esperado**: Sólo se muestran los adeudos del contrato 456 con contratos cancelados.

## Caso 5: Consulta por vigencia de adeudos pagados
- **Entrada**:
  - sel_emp: 1
  - num_emp: 0
  - sel_cont: 1
  - num_cont: 0
  - sel_ctrol_aseo: 0
  - vig_cont: 'T'
  - vig_adeudos: 'P'
  - ofna: 0
  - opcion: 1
- **Esperado**: Sólo se muestran los adeudos con status_vigencia_1 = 'P' (pagados).
