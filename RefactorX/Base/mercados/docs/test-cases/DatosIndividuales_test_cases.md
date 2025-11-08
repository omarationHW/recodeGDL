# Casos de Prueba para DatosIndividuales

## Caso 1: Consulta exitosa de datos individuales
- **Input:**
  - action: getDatosIndividuales
  - params: { id_local: 123 }
- **Expected:**
  - success: true
  - data: objeto con todos los campos del local
  - message: ""

## Caso 2: Consulta de adeudos con local inexistente
- **Input:**
  - action: getAdeudos
  - params: { id_local: 999999 }
- **Expected:**
  - success: true
  - data: [] (lista vacía)
  - message: ""

## Caso 3: Consulta de requerimientos sin parámetro obligatorio
- **Input:**
  - action: getRequerimientos
  - params: { }
- **Expected:**
  - success: false
  - data: null
  - message: "id_local es requerido"

## Caso 4: Consulta de movimientos con error de base de datos
- **Simulación:** Forzar error en SP o conexión
- **Expected:**
  - success: false
  - data: null
  - message: "Error ..."

## Caso 5: Consulta de datos de tianguis para local con num_mercado=214
- **Input:**
  - action: getTianguis
  - params: { folio: 555 }
- **Expected:**
  - success: true
  - data: objeto con campos de tianguis
  - message: ""
