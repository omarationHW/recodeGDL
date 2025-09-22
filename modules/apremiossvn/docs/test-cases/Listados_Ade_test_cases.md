## Casos de Prueba Listados_Ade

### Caso 1: Consulta Mercados - Rango Válido
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "mercados",
      "params": {
        "oficina": 1,
        "num_mercado1": 1,
        "num_mercado2": 5,
        "local1": 1,
        "local2": 50,
        "seccion": "A",
        "axo": 2024,
        "mes": 6
      }
    }
  }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.data es array no vacío
  - Cada registro tiene campos: id_local, oficina, num_mercado, ...

### Caso 2: Consulta Aseo - Contrato Inexistente
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "aseo",
      "params": {
        "tipo_aseo": "Z",
        "contrato1": 9999,
        "contrato2": 9999,
        "id_rec": 1,
        "axo": 2022,
        "mes": 1
      }
    }
  }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.data es array vacío

### Caso 3: Consulta Públicos - Parámetros Inválidos
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "publicos",
      "params": {
        "numesta1": null,
        "numesta2": null,
        "axo": null,
        "mes": null,
        "impd": null,
        "imph": null,
        "id_rec": null
      }
    }
  }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.error indica error de parámetros

### Caso 4: Consulta Exclusivos - Sin Resultados
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "exclusivos",
      "params": {
        "no_exclusivo1": 9999,
        "no_exclusivo2": 9999,
        "axo": 2024,
        "mes": 6,
        "impd": 10000,
        "imph": 20000,
        "id_rec": 1
      }
    }
  }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.data es array vacío

### Caso 5: Consulta Infracciones - Error de SP
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "infracciones",
      "params": {
        "propietario": "",
        "placa": "",
        "axo1": 2024,
        "axo2": 2020,
        "impd": 0,
        "imph": 0,
        "tipo": null,
        "id_rec": 1
      }
    }
  }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.error indica error de rango de años
