# Casos de Prueba: Padron de Contratos

| # | Descripción | Parámetros | Resultado Esperado |
|---|-------------|------------|--------------------|
| 1 | Consulta todos los contratos vigentes, ordenados por número de contrato | vigencia: 'V', ofna: 0, opcion: 2, num_emp: null | Tabla con contratos vigentes, ordenados por número de contrato. Resumen correcto. |
| 2 | Consulta contratos cancelados de recaudadora 5 | vigencia: 'C', ofna: 5, opcion: 1, num_emp: null | Solo contratos cancelados de recaudadora 5. Resumen correcto. |
| 3 | Consulta todos los contratos por domicilio | vigencia: 'T', ofna: 0, opcion: 8, num_emp: null | Contratos agrupados por domicilio, todos los estados de vigencia. |
| 4 | Consulta con recaudadora inexistente | vigencia: 'V', ofna: 9999, opcion: 1, num_emp: null | Tabla vacía, resumen con totales en 0. |
| 5 | Consulta con combinación inválida (vigencia 'Z') | vigencia: 'Z', ofna: 0, opcion: 1, num_emp: null | Tabla vacía, resumen con totales en 0. |
| 6 | Consulta con número de empleado específico | vigencia: 'V', ofna: 0, opcion: 1, num_emp: 123 | Solo contratos asociados al empleado 123 (si existen). |

**Notas:**
- Validar que los totales de resumen coincidan con los datos mostrados.
- Probar la navegación y recarga de filtros.
- Verificar formato de fechas y labels de vigencia.