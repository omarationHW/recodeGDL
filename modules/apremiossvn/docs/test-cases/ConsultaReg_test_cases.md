# Casos de Prueba ConsultaReg

## Caso 1: Consulta exitosa de mercado
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "buscar",
      "params": {
        "tipo": 0,
        "oficina": 1,
        "num_mercado": 2,
        "seccion": "A",
        "local": 5,
        "letra_local": "B",
        "bloque": "C"
      }
    }
  }
  ```
- **Esperado:**
  - eResponse.success = true
  - eResponse.registro contiene los datos del mercado
  - eResponse.detalle contiene el detalle de requerimientos

## Caso 2: Consulta de aseo inexistente
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "buscar",
      "params": {
        "tipo": 1,
        "contrato": 99999,
        "tipo_aseo": "Z"
      }
    }
  }
  ```
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = 'Registro no encontrado'

## Caso 3: Consulta de estacionamiento público y reset
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "buscar",
      "params": {
        "tipo": 2,
        "numesta": 123
      }
    }
  }
  ```
- **Esperado:**
  - eResponse.success = true
  - eResponse.registro contiene los datos del estacionamiento público
  - eResponse.detalle contiene el detalle de requerimientos

- **Acción de reset:**
  ```json
  {
    "eRequest": { "action": "otro" }
  }
  ```
- **Esperado:**
  - eResponse.success = true
  - eResponse.reset = true
