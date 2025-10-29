# Casos de Prueba: Adeudos de Energía Eléctrica

## Caso 1: Consulta exitosa de adeudos
- **Entrada:** oficina=3, mercado=15, axo=2024, mes=6
- **Acción:** getAdeudosEnergia
- **Esperado:** Respuesta contiene lista de adeudos, sin error.

## Caso 2: Consulta con oficina inexistente
- **Entrada:** oficina=99, mercado=15, axo=2024, mes=6
- **Acción:** getAdeudosEnergia
- **Esperado:** Respuesta contiene lista vacía o error indicando oficina no encontrada.

## Caso 3: Consulta con parámetros faltantes
- **Entrada:** oficina=3, mercado=null, axo=2024, mes=6
- **Acción:** getAdeudosEnergia
- **Esperado:** Respuesta contiene error de validación.

## Caso 4: Visualización de meses de adeudo
- **Entrada:** id_energia=12345, axo=2024, mes=6
- **Acción:** getMesesAdeudoEnergia
- **Esperado:** Respuesta contiene lista de meses y montos, sin error.

## Caso 5: Exportación a Excel
- **Entrada:** oficina=3, mercado=15, axo=2024, mes=6
- **Acción:** exportExcel
- **Esperado:** Respuesta contiene mensaje de éxito o archivo descargable.

## Caso 6: Seguridad - usuario no autenticado
- **Entrada:** Sin token de autenticación
- **Acción:** getAdeudosEnergia
- **Esperado:** Respuesta HTTP 401 Unauthorized.
