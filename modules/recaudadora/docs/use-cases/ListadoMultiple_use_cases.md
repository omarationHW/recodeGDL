# Casos de Uso - ListadoMultiple

**Categoría:** Form

## Caso de Uso 1: Consulta de Convenios de Empresas por Año

**Descripción:** El usuario consulta todos los convenios de empresas emitidos en un año específico y a partir de una fecha dada.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página Listado Múltiple.
2. Ingresa el año (ej: 2024) y la fecha de emisión (ej: 2024-06-01).
3. Presiona el botón 'Buscar Convenios'.
4. El sistema envía un eRequest con action 'getConveniosEmpresas' y los parámetros.
5. El backend ejecuta el stored procedure y devuelve los resultados.

**Resultado esperado:**
Se muestra una tabla con los convenios de empresas emitidos en el año y fecha seleccionados.

**Datos de prueba:**
{ "year": 2024, "fecha": "2024-06-01" }

---

## Caso de Uso 2: Consulta de Pagos de Convenios por Empresa y Rango de Fechas

**Descripción:** El usuario consulta los pagos realizados por una empresa ejecutora en un rango de fechas de trabajo y pago.

**Precondiciones:**
El usuario está autenticado y existen ejecutores y pagos registrados.

**Pasos a seguir:**
1. El usuario accede a la sección de pagos de convenios.
2. Selecciona un ejecutor de la lista.
3. Ingresa la fecha de trabajo y el rango de fechas de pago.
4. Presiona el botón 'Buscar Pagos'.
5. El sistema envía un eRequest con action 'getPagosConveniosEmpresas' y los parámetros.
6. El backend ejecuta el stored procedure y devuelve los resultados.

**Resultado esperado:**
Se muestra una tabla con los pagos realizados por el ejecutor en el rango de fechas especificado.

**Datos de prueba:**
{ "ejecutor": 123, "ftrab": "2024-06-01", "fpagod": "2024-06-01", "fpagoh": "2024-06-30" }

---

## Caso de Uso 3: Exportación de Convenios a Excel

**Descripción:** El usuario exporta el listado de convenios de empresas a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una búsqueda de convenios y hay resultados en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar a Excel' en la tabla de convenios.
2. El sistema genera el archivo Excel y lo descarga o muestra un enlace de descarga.

**Resultado esperado:**
El usuario obtiene un archivo Excel con los datos de los convenios mostrados.

**Datos de prueba:**
Resultados de la búsqueda de convenios (ver caso 1).

---

