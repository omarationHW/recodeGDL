## Casos de Prueba para Reportes_Folios

### Caso 1: Consulta exitosa de folios de adeudos para una infracción
- **Entrada:** tipo_solicitud=1, cve_infraccion=5, fecha_inicio=2024-05-01, fecha_fin=2024-05-31
- **Acción:** Ejecutar reporte
- **Esperado:** Respuesta eResponse.success=true, data contiene al menos un folio con cve_infraccion=5

### Caso 2: Consulta de descuentos otorgados sin resultados
- **Entrada:** tipo_solicitud=6, fecha_inicio=2023-01-01, fecha_fin=2023-01-02 (periodo sin datos)
- **Acción:** Ejecutar reporte
- **Esperado:** Respuesta eResponse.success=true, data es array vacío

### Caso 3: Error por fecha inválida
- **Entrada:** tipo_solicitud=2, cve_infraccion=0, fecha_inicio='2024-06-31', fecha_fin='2024-06-10'
- **Acción:** Ejecutar reporte
- **Esperado:** Respuesta eResponse.success=false, message indica error de fecha inválida

### Caso 4: Consulta de todos los folios pagados en el día actual
- **Entrada:** tipo_solicitud=2, cve_infraccion=0, fecha_inicio=2024-06-10, fecha_fin=2024-06-10
- **Acción:** Ejecutar reporte
- **Esperado:** Respuesta eResponse.success=true, data contiene folios pagados del día

### Caso 5: Consulta de infracciones para el combo
- **Entrada:** action=getInfracciones
- **Acción:** Cargar página
- **Esperado:** Respuesta eResponse.success=true, data contiene lista de infracciones
