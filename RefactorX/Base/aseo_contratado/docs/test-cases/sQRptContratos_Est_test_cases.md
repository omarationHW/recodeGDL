# Casos de Prueba: Estadística General de Contratos

## Caso 1: Consulta General Todos los Tipos
- **Entrada:** cve_aseo='T', aso_in=2023, mes_in=1, aso_fin=2023, mes_fin=12
- **Esperado:** Respuesta success=true, data con al menos 3 filas (O, H, C), totales > 0

## Caso 2: Consulta Ordinarios Periodo Parcial
- **Entrada:** cve_aseo='O', aso_in=2023, mes_in=1, aso_fin=2023, mes_fin=6
- **Esperado:** Respuesta success=true, data con 1 fila tipo_aseo='O', totales > 0

## Caso 3: Periodo Inválido
- **Entrada:** cve_aseo='T', aso_in=2025, mes_in=1, aso_fin=2023, mes_fin=12
- **Esperado:** success=false, message='Acción no soportada' o mensaje de error de validación

## Caso 4: Sin Datos
- **Entrada:** cve_aseo='Z', aso_in=2020, mes_in=1, aso_fin=2020, mes_fin=1
- **Esperado:** success=true, data vacía o totales en cero

## Caso 5: SQL Injection
- **Entrada:** cve_aseo="O'; DROP TABLE ta_16_contratos; --", aso_in=2023, mes_in=1, aso_fin=2023, mes_fin=1
- **Esperado:** success=false, message de error, sin afectar la base de datos
