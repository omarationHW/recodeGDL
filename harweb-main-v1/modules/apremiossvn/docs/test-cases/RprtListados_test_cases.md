# Casos de Prueba para RprtListados

## Caso 1: Consulta básica sin filtros adicionales
- **Descripción:** Consulta de folios para Mercados, zona 1, folios 100-120, sin filtro de clave ni vigencia.
- **Entrada:**
  ```json
  {
    "eRequest": "getRprtListados",
    "params": {
      "vrec": 1,
      "vmod": 11,
      "vfol1": 100,
      "vfol2": 120,
      "vcve": "todas",
      "vvig": "todas",
      "vfdsd": null,
      "vfhst": null
    }
  }
  ```
- **Esperado:**
  - Respuesta `success: true`.
  - `data` contiene registros con folios 100-120, módulo 11, zona 1.
  - El campo `datos` tiene formato "oficina-num_mercado-categoria-seccion-local-letra_local-bloque" o 'S/R'.

## Caso 2: Consulta filtrada por clave 'P' y fechas
- **Descripción:** Consulta de Aseo, zona 2, folios 200-210, clave 'P', fechas 2024-01-01 a 2024-01-31.
- **Entrada:**
  ```json
  {
    "eRequest": "getRprtListados",
    "params": {
      "vrec": 2,
      "vmod": 16,
      "vfol1": 200,
      "vfol2": 210,
      "vcve": "P",
      "vvig": "todas",
      "vfdsd": "2024-01-01",
      "vfhst": "2024-01-31"
    }
  }
  ```
- **Esperado:**
  - Solo registros con clave_practicado = 'P' y fecha_practicado entre 2024-01-01 y 2024-01-31.
  - El campo `datos` tiene formato "tipo_aseo-num_contrato" o 'S/R'.

## Caso 3: Consulta con vigencia '2' (Pagada)
- **Descripción:** Consulta de Estacionamientos Exclusivos, zona 3, folios 300-305, vigencia '2'.
- **Entrada:**
  ```json
  {
    "eRequest": "getRprtListados",
    "params": {
      "vrec": 3,
      "vmod": 28,
      "vfol1": 300,
      "vfol2": 305,
      "vcve": "todas",
      "vvig": "2",
      "vfdsd": null,
      "vfhst": null
    }
  }
  ```
- **Esperado:**
  - Solo registros con vigencia = '2' o 'P'.
  - El campo `datos` tiene formato "EXC. no_exclusivo" o 'S/R'.

## Caso 4: Consulta sin resultados
- **Descripción:** Consulta con parámetros que no existen en la base de datos.
- **Entrada:**
  ```json
  {
    "eRequest": "getRprtListados",
    "params": {
      "vrec": 99,
      "vmod": 99,
      "vfol1": 9999,
      "vfol2": 10000,
      "vcve": "todas",
      "vvig": "todas",
      "vfdsd": null,
      "vfhst": null
    }
  }
  ```
- **Esperado:**
  - Respuesta `success: true`.
  - `data` es un arreglo vacío.

## Caso 5: Error por parámetros faltantes
- **Descripción:** Envío de petición sin parámetros requeridos.
- **Entrada:**
  ```json
  {
    "eRequest": "getRprtListados",
    "params": {}
  }
  ```
- **Esperado:**
  - Respuesta `success: false`.
  - Mensaje de error indicando parámetros faltantes o inválidos.
