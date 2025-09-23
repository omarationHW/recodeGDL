# Casos de Prueba: impreqCvecat

## Caso 1: Búsqueda y asignación exitosa
- **Entrada:** recaud=1, folioini=100, foliofin=110, fecha=2024-06-01, ejecutor=5, usuario=admin
- **Acción:** listar → asignar
- **Esperado:** Los folios 100-110 quedan asignados al ejecutor 5

## Caso 2: Asignación con folios inexistentes
- **Entrada:** recaud=1, folioini=9999, foliofin=10010, fecha=2024-06-01, ejecutor=5, usuario=admin
- **Acción:** listar → asignar
- **Esperado:** Error: No existen folios en ese rango

## Caso 3: Impresión de folios
- **Entrada:** recaud=1, folioini=100, foliofin=105, usuario=admin
- **Acción:** imprimir
- **Esperado:** Los folios 100-105 quedan marcados como impresos

## Caso 4: Listar ejecutores
- **Entrada:** recaud=1, fecha=2024-06-01
- **Acción:** ejecutores
- **Esperado:** Lista de ejecutores disponibles

## Caso 5: Calcular máximo de impresiones
- **Entrada:** recaud=1
- **Acción:** max_impresiones
- **Esperado:** Devuelve el número máximo de impresiones posibles

## Caso 6: Generar reporte PDF
- **Entrada:** recaud=1, folioini=100, foliofin=110
- **Acción:** reporte
- **Esperado:** Devuelve URL de PDF generado
