# Casos de Prueba: AdeudosLocales

## Caso 1: Consulta exitosa de adeudos
- **Entrada:** { "action": "getAdeudosLocales", "params": { "axo": 2023, "oficina": 2, "periodo": 5 } }
- **Esperado:**
  - success: true
  - data: lista no vacía
  - Cada fila contiene los campos requeridos

## Caso 2: Consulta con parámetros inválidos
- **Entrada:** { "action": "getAdeudosLocales", "params": { "axo": "", "oficina": null, "periodo": null } }
- **Esperado:**
  - success: false
  - message: error de validación o parámetros faltantes

## Caso 3: Exportación a Excel sin datos
- **Entrada:** { "action": "exportExcel", "params": {} }
- **Esperado:**
  - success: false o true (según implementación)
  - message: 'No hay datos para exportar' o similar

## Caso 4: Consulta de meses de adeudo
- **Entrada:** { "action": "getMesesAdeudo", "params": { "id_local": 123, "axo": 2023 } }
- **Esperado:**
  - success: true
  - data: lista de meses de adeudo para el local

## Caso 5: Consulta de renta
- **Entrada:** { "action": "getRenta", "params": { "axo": 2023, "categoria": 1, "seccion": "SS", "clave_cuota": 2 } }
- **Esperado:**
  - success: true
  - data: información de renta correspondiente
