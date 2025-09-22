# Casos de Uso - NotificacionesMes

**Categoría:** Form

## Caso de Uso 1: Consulta de Notificaciones por Mes para un Año y Rango de Fechas

**Descripción:** El usuario desea obtener un reporte de notificaciones emitidas, practicadas, canceladas y pagadas para el año 2024, con pagos realizados entre el 1 de enero y el 31 de marzo.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. Ingresar '2024' en Año de Practicado y Año de Emisión.
2. Seleccionar '2024-01-01' como Fecha Pago Desde y '2024-03-31' como Fecha Pago Hasta.
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los totales agrupados por módulo, mes, año y ejecutor, mostrando asignados, practicados, cancelados, pagados y recaudado.

**Datos de prueba:**
{ "axo_pract": 2024, "axo_emi": 2024, "fecha_desde": "2024-01-01", "fecha_hasta": "2024-03-31" }

---

## Caso de Uso 2: Exportar Reporte de Notificaciones a Excel

**Descripción:** El usuario desea exportar el reporte consultado a un archivo Excel (CSV) para análisis externo.

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en pantalla.

**Pasos a seguir:**
1. Hacer clic en el botón 'Exportar Excel'.
2. El navegador descarga un archivo CSV con los datos mostrados.

**Resultado esperado:**
El archivo CSV contiene las mismas columnas y datos que la tabla mostrada.

**Datos de prueba:**
Usar los resultados de la consulta anterior.

---

## Caso de Uso 3: Validación de Parámetros Obligatorios

**Descripción:** El usuario intenta consultar el reporte sin ingresar todos los campos obligatorios.

**Precondiciones:**
El usuario accede a la página pero deja algún campo vacío.

**Pasos a seguir:**
1. Dejar vacío el campo 'Año de Practicado'.
2. Hacer clic en 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo es obligatorio y no realiza la consulta.

**Datos de prueba:**
{ "axo_pract": "", "axo_emi": 2024, "fecha_desde": "2024-01-01", "fecha_hasta": "2024-03-31" }

---

