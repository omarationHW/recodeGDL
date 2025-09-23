# Casos de Uso - RprtListaxRegMer

**Categoría:** Form

## Caso de Uso 1: Consulta de registros de mercado vigentes por oficina y mercado

**Descripción:** El usuario desea obtener el listado de registros de mercados con requerimientos vigentes para una oficina y mercado específicos.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el número de oficina y mercado.

**Pasos a seguir:**
1. Ingresar a la página 'Listado de Registros de Mercados'.
2. Ingresar el número de oficina (ej. 5).
3. Ingresar el número de mercado (ej. 1).
4. Seleccionar 'Vigente' en el filtro de vigencia.
5. Dejar 'Clave Practicado' en 'todas'.
6. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los registros vigentes para la oficina y mercado seleccionados, incluyendo totales y detalles.

**Datos de prueba:**
{ "oficina": 5, "num_mercado": 1, "vigencia": "1", "clave_practicado": "todas" }

---

## Caso de Uso 2: Consulta de registros pagados o en proceso para un mercado

**Descripción:** El usuario desea ver todos los registros pagados o en proceso ('P') para un mercado específico.

**Precondiciones:**
El usuario tiene acceso y conoce el número de oficina y mercado.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Ingresar el número de oficina (ej. 3).
3. Ingresar el número de mercado (ej. 2).
4. Seleccionar 'Pagado' en el filtro de vigencia.
5. Dejar 'Clave Practicado' en 'todas'.
6. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestran los registros con vigencia '2' o 'P' para los filtros seleccionados.

**Datos de prueba:**
{ "oficina": 3, "num_mercado": 2, "vigencia": "2", "clave_practicado": "todas" }

---

## Caso de Uso 3: Filtrar por clave_practicado específica

**Descripción:** El usuario necesita ver los registros de un mercado filtrando por una clave_practicado específica.

**Precondiciones:**
El usuario conoce la clave_practicado a buscar.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Ingresar el número de oficina (ej. 7).
3. Ingresar el número de mercado (ej. 4).
4. Seleccionar 'Todas' en vigencia.
5. Escribir la clave_practicado deseada (ej. 'A123').
6. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestran únicamente los registros que coinciden con la clave_practicado indicada.

**Datos de prueba:**
{ "oficina": 7, "num_mercado": 4, "vigencia": "todas", "clave_practicado": "A123" }

---

