# Casos de Prueba para ConsultaLicenciafrm

## 1. Consulta por Número de Licencia
- **Entrada**: licencia = '123456'
- **Acción**: Buscar
- **Esperado**: Se muestra la licencia 123456 con todos sus datos.

## 2. Consulta por Ubicación
- **Entrada**: ubicacion = 'AV. JUAREZ'
- **Acción**: Buscar
- **Esperado**: Se muestran todas las licencias con ubicación que contiene 'AV. JUAREZ'.

## 3. Consulta por Contribuyente
- **Entrada**: propietario = 'JUAN PEREZ'
- **Acción**: Buscar
- **Esperado**: Se muestran todas las licencias cuyo propietario contiene 'JUAN PEREZ'.

## 4. Consulta por Trámite
- **Entrada**: id_tramite = '7890'
- **Acción**: Buscar
- **Esperado**: Se muestran las licencias asociadas al trámite 7890.

## 5. Visualización de Pagos
- **Entrada**: Seleccionar licencia 123456
- **Acción**: Ver Pagos
- **Esperado**: Se muestran los pagos asociados a la licencia.

## 6. Visualización de Adeudos
- **Entrada**: Seleccionar licencia 123456
- **Acción**: Ver Adeudos
- **Esperado**: Se muestran los adeudos por año de la licencia.

## 7. Bloqueo de Licencia
- **Entrada**: Seleccionar licencia 123456
- **Acción**: Bloquear (motivo: 'Prueba')
- **Esperado**: La licencia aparece como bloqueada.

## 8. Desbloqueo de Licencia
- **Entrada**: Seleccionar licencia 123456
- **Acción**: Desbloquear (motivo: 'Prueba')
- **Esperado**: La licencia aparece como no bloqueada.

## 9. Exportación a Excel
- **Entrada**: Realizar búsqueda por ubicación 'AV. JUAREZ'
- **Acción**: Exportar a Excel
- **Esperado**: Se descarga un archivo Excel con los resultados.

## 10. Error por Faltante de Parámetro
- **Entrada**: Buscar sin ingresar ningún campo
- **Acción**: Buscar
- **Esperado**: Se muestra un mensaje de error indicando que falta un parámetro.
