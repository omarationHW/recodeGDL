# Casos de Uso - RptParcVencidasConvDiversos

**Categoría:** Form

## Caso de Uso 1: Consulta de Parcialidades Vencidas Vigentes

**Descripción:** El usuario desea obtener el reporte de parcialidades vencidas de convenios diversos vigentes para la zona centro hasta una fecha específica.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. Accede a la página de Parcialidades Vencidas Convenios Diversos.
2. Selecciona Tipo: 1, Subtipo: 2, Fecha Hasta: 2024-06-30, Zona: ZC1 (Centro), Estado: A (Vigentes).
3. Presiona 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con los convenios vigentes, sus pagos al corriente, vencidos y adeudos agrupados correctamente.

**Datos de prueba:**
{ "tipo": 1, "subtipo": 2, "fechahst": "2024-06-30", "letras": "ZC1", "est": "A" }

---

## Caso de Uso 2: Exportación a Excel de Convenios Dados de Baja

**Descripción:** El usuario requiere exportar a Excel el reporte de convenios dados de baja en la zona olímpica.

**Precondiciones:**
El usuario tiene permisos de exportación.

**Pasos a seguir:**
1. Accede a la página de reporte.
2. Selecciona Tipo: 3, Subtipo: 5, Fecha Hasta: 2024-05-31, Zona: ZO2 (Olímpica), Estado: B (Baja).
3. Presiona 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos filtrados.

**Datos de prueba:**
{ "tipo": 3, "subtipo": 5, "fechahst": "2024-05-31", "letras": "ZO2", "est": "B" }

---

## Caso de Uso 3: Reporte de Convenios Pagados en Zona Minerva

**Descripción:** El usuario consulta los convenios pagados en la zona Minerva para auditoría.

**Precondiciones:**
El usuario tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de reporte.
2. Selecciona Tipo: 2, Subtipo: 4, Fecha Hasta: 2024-06-15, Zona: ZM4 (Minerva), Estado: P (Pagados).
3. Presiona 'Generar Reporte'.

**Resultado esperado:**
Se muestra el listado de convenios pagados en la zona Minerva.

**Datos de prueba:**
{ "tipo": 2, "subtipo": 4, "fechahst": "2024-06-15", "letras": "ZM4", "est": "P" }

---

