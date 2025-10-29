# Casos de Prueba BuscaRegistroModulo

## Caso 1: Búsqueda de Multa Municipal
- **Entrada:**
  - tipo: multas
  - abrevia: MM
  - axo_acta: 2023
  - num_acta: 12345
- **Esperado:**
  - Se retorna un registro con control, calcregistro, nombre, ubicación.

## Caso 2: Consulta de Licencia de Construcción
- **Entrada:**
  - tipo: lic_construccion
  - segmento1: 0M
  - segmento2: 0190
  - segmento3: 2018
- **Esperado:**
  - Se retorna la información de la licencia correspondiente.

## Caso 3: Búsqueda de Local de Mercado
- **Entrada:**
  - tipo: mercados
  - oficina: 1
  - num_mercado: 2
  - categoria: 3
  - seccion: A
  - local: 10
  - letra_local: B
  - bloque: 1
- **Esperado:**
  - Se retorna la información del local de mercado.

## Caso 4: Error por parámetros faltantes
- **Entrada:**
  - tipo: mercados
  - oficina: 1
  - num_mercado: 2
  - categoria: 3
  - seccion: ""
  - local: 10
  - letra_local: ""
  - bloque: ""
- **Esperado:**
  - El sistema retorna error de validación o lista vacía.

## Caso 5: Búsqueda sin resultados
- **Entrada:**
  - tipo: predial
  - recaud: "999"
  - urbrus: "ZZZ"
  - cuenta: "000000"
- **Esperado:**
  - El sistema retorna lista vacía.
