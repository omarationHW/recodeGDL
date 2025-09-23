# Casos de Prueba: Modificar Folio Apremio

## Caso 1: Modificar un Folio Vigente
- **Entrada:**
  - action: modificarFolio
  - params: { id_control: 123, modulo: 11, folio: 456, usuario: 1, importe_gastos: 500.00, observaciones: "Actualización de gastos" }
- **Esperado:**
  - status: ok
  - data: ["ok"]
  - El registro se actualiza en la base de datos y se inserta en el historial

## Caso 2: Modificar un Folio Inexistente
- **Entrada:**
  - action: modificarFolio
  - params: { id_control: 999999, modulo: 11, folio: 456, usuario: 1 }
- **Esperado:**
  - status: error
  - errors: ["No existe el folio"]

## Caso 3: Validación de Campos Obligatorios
- **Entrada:**
  - action: modificarFolio
  - params: { modulo: 11, folio: 456 }
- **Esperado:**
  - status: error
  - errors: ["id_control is required", "usuario is required"]

## Caso 4: Consulta de Folio Existente
- **Entrada:**
  - action: getFolio
  - params: { modulo: 11, folio: 456, recaudadora: 1 }
- **Esperado:**
  - status: ok
  - data: [ { ...datos del folio... } ]

## Caso 5: Consulta de Historial
- **Entrada:**
  - action: historialFolio
  - params: { id_control: 123 }
- **Esperado:**
  - status: ok
  - data: [ { fecha_actualiz, usuario, clave_mov, observaciones }, ... ]
