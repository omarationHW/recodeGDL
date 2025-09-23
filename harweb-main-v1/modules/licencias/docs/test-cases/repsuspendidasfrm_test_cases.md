## Casos de Prueba para Reporte de Licencias Suspendidas

### Caso 1: Consulta por año
- **Entrada:** year=2022, date_from=null, date_to=null, tipo_suspension=0
- **Acción:** Enviar petición a /api/execute con eRequest='repsuspendidas_report'.
- **Esperado:** Respuesta eResponse='ok', data con registros de 2022, total > 0.

### Caso 2: Consulta por rango de fechas y tipo
- **Entrada:** year=0, date_from='2024-03-01', date_to='2024-03-10', tipo_suspension=1
- **Acción:** Enviar petición a /api/execute con eRequest='repsuspendidas_report'.
- **Esperado:** Respuesta eResponse='ok', data solo con registros entre esas fechas y bloqueado=1.

### Caso 3: Validación de campos requeridos
- **Entrada:** year=0, date_from=null, date_to=null, tipo_suspension=0
- **Acción:** Enviar petición a /api/execute con eRequest='repsuspendidas_report'.
- **Esperado:** Respuesta eResponse='error', mensaje 'Debes indicar el año o las fechas de las licencias ...'.

### Caso 4: Consulta sin resultados
- **Entrada:** year=1999, date_from=null, date_to=null, tipo_suspension=0
- **Acción:** Enviar petición a /api/execute con eRequest='repsuspendidas_report'.
- **Esperado:** Respuesta eResponse='ok', data vacía, mensaje 'No se encontraron licencias con esas condiciones ...'.

### Caso 5: Consulta por fecha exacta
- **Entrada:** year=0, date_from='2024-04-15', date_to=null, tipo_suspension=3
- **Acción:** Enviar petición a /api/execute con eRequest='repsuspendidas_report'.
- **Esperado:** Respuesta eResponse='ok', data solo con registros de esa fecha y bloqueado=3.
