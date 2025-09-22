# Casos de Uso - RptAdeudosConvDiversosSaldoAnt

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de convenios diversos vigentes en zona OBLATOS

**Descripción:** El usuario desea obtener el reporte de convenios diversos vigentes en la zona OBLATOS, subtipo 1, para el periodo del 1 de enero al 30 de junio de 2024.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Ingresa a la página de reporte de convenios diversos saldo anterior.
2. Selecciona Tipo: 3, Subtipo: 1, Letras: ZO3, Estado: A, Fecha Desde: 2024-01-01, Fecha Hasta: 2024-06-30.
3. Presiona 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con los convenios vigentes en zona OBLATOS, mostrando saldo anterior, pagos y saldo actual.

**Datos de prueba:**
{ "tipo": 3, "subtipo": 1, "letras": "ZO3", "estado": "A", "fechadsd": "2024-01-01", "fechahst": "2024-06-30" }

---

## Caso de Uso 2: Exportación de reporte a CSV

**Descripción:** El usuario desea exportar el reporte generado a un archivo CSV para su análisis en Excel.

**Precondiciones:**
El usuario ya generó un reporte con resultados.

**Pasos a seguir:**
1. Después de ver la tabla de resultados, presiona el botón 'Exportar CSV'.

**Resultado esperado:**
Se descarga un archivo CSV con los datos del reporte.

**Datos de prueba:**
Usar los datos del caso de uso anterior.

---

## Caso de Uso 3: Consulta de saldo anterior de un convenio específico

**Descripción:** El usuario requiere conocer el saldo anterior de un convenio antes de una fecha dada.

**Precondiciones:**
El usuario conoce el id_conv_diver, tipo, subtipo y fecha desde.

**Pasos a seguir:**
1. Realiza una petición a la API con acción 'getSaldoAnterior' y los parámetros requeridos.

**Resultado esperado:**
La API retorna el saldo anterior calculado correctamente.

**Datos de prueba:**
{ "tipo": 3, "subtipo": 1, "id_conv_diver": 12345, "fechadsd": "2024-01-01" }

---

