# Casos de Prueba para Contratos

| Caso | Acción | Parámetros | Resultado Esperado |
|------|--------|------------|--------------------|
| 1 | Listar contratos vigentes de Zona Centro | { tipo: 'C', vigencia: 'V' } | Lista de contratos con status_contrato = 'V' y tipo_aseo = 'C' |
| 2 | Exportar contratos hospitalarios cancelados | { tipo: 'H', vigencia: 'C' } | Archivo Excel descargado con los datos correspondientes |
| 3 | Buscar contrato específico | { contrato: 12345, tipo: 'T', vigencia: 'T' } | Contrato con num_contrato = 12345 mostrado |
| 4 | Listar todos los contratos | { tipo: 'T', vigencia: 'T' } | Lista completa de contratos |
| 5 | Buscar con parámetros inválidos | { tipo: 'X', vigencia: 'Z' } | Mensaje de error o lista vacía |

## Pruebas de Seguridad
- Intentar acceder al endpoint sin autenticación: debe ser rechazado.
- Inyectar SQL en los parámetros: debe ser bloqueado y no ejecutar código malicioso.

## Pruebas de UI
- Cambiar filtros y verificar que la tabla se actualiza correctamente.
- Probar exportación a Excel con diferentes filtros.
