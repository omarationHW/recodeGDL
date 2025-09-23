# Casos de Prueba: Lista_Eje

## Caso 1: Consulta de todos los ejecutores
- **Entrada:**
  - action: get_lista_eje
  - params: { rec: 1, rec1: 9, vigentes: false }
- **Esperado:**
  - status: success
  - data: Array con todos los ejecutores entre rec 1 y 9

## Caso 2: Consulta de ejecutores vigentes
- **Entrada:**
  - action: get_lista_eje
  - params: { rec: 1, rec1: 9, vigentes: true }
- **Esperado:**
  - status: success
  - data: Solo ejecutores con vigencia 'A'

## Caso 3: Exportación a Excel
- **Entrada:**
  - action: export_lista_eje_excel
  - params: { rec: 1, rec1: 9, vigentes: true }
- **Esperado:**
  - status: success
  - message: Exportación a Excel generada (simulada)

## Caso 4: Acción no soportada
- **Entrada:**
  - action: unknown_action
  - params: {}
- **Esperado:**
  - status: error
  - message: Acción no soportada

## Caso 5: Error de base de datos
- **Simulación:**
  - Forzar error en el SP (por ejemplo, rec > rec1)
- **Esperado:**
  - status: error
  - message: Mensaje de error de la base de datos
