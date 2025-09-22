# Casos de Uso - RptAdeudosConvDiversos

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Vigentes por Zona Centro

**Descripción:** El usuario desea obtener el listado de adeudos de convenios diversos de tipo Predial Urbano, zona centro, vigentes al día de hoy.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. Acceder a la página de 'Adeudos Convenios Diversos'.
2. Seleccionar Tipo: Predial (1).
3. Seleccionar Subtipo: Urbano (1).
4. Seleccionar Zona: ZC1 (Zona Centro).
5. Seleccionar Estado: A (Vigentes).
6. Seleccionar Fecha: Hoy.
7. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los convenios diversos de predial urbano, zona centro, vigentes, mostrando convenio, nombre, domicilio, costo, pagos, saldo y recargos.

**Datos de prueba:**
{ "tipo": 1, "subtipo": 1, "letras": "ZC1", "estado": "A", "fecha": "2024-06-30" }

---

## Caso de Uso 2: Exportación de Reporte a CSV

**Descripción:** El usuario requiere exportar el reporte de adeudos de convenios diversos a un archivo CSV para análisis externo.

**Precondiciones:**
El usuario ya realizó una consulta y tiene resultados en pantalla.

**Pasos a seguir:**
1. Realizar una consulta de adeudos con los filtros deseados.
2. Hacer clic en el botón 'Exportar CSV'.

**Resultado esperado:**
Se descarga un archivo CSV con los datos del reporte, incluyendo columnas de convenio, nombre, domicilio, costo, pagos, saldo, recargos y oficio.

**Datos de prueba:**
Usar los datos del caso de uso 1.

---

## Caso de Uso 3: Detalle de Pagos de un Convenio Diverso

**Descripción:** El usuario desea ver el detalle de pagos y parcialidades de un convenio específico.

**Precondiciones:**
El usuario tiene el ID del convenio diverso.

**Pasos a seguir:**
1. Acceder a la página de detalle (o hacer clic en un convenio en el reporte).
2. El sistema solicita el ID del convenio diverso.
3. Se consulta el detalle usando el endpoint con acción 'getRptAdeudosConvDiversosDetalle'.

**Resultado esperado:**
Se muestra una tabla con los pagos realizados, fechas, importes y parcialidades del convenio seleccionado.

**Datos de prueba:**
{ "id_conv_diver": 12345 }

---

