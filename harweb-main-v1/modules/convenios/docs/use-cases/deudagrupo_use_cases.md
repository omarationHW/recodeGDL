# Casos de Uso - deudagrupo

**Categoría:** Form

## Caso de Uso 1: Consulta de Deuda de Contratos por Año de Obra

**Descripción:** El usuario desea consultar todos los contratos con adeudo y recargos para el año de obra 2023, calculando los recargos al 1 de junio de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar deuda de grupo.

**Pasos a seguir:**
1. Accede a la página 'Deuda de Contratos con Recargos'.
2. Selecciona el año de obra '2023'.
3. Selecciona la fecha '2024-06-01' para calcular recargos.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los contratos con adeudo para el año 2023, mostrando los recargos calculados al 1 de junio de 2024.

**Datos de prueba:**
{ "axo": 2023, "fecha_recargo": "2024-06-01" }

---

## Caso de Uso 2: Exportación de Resultados a Excel

**Descripción:** El usuario desea exportar la relación de adeudos de convenios a Excel para el año de obra 2022.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para exportar datos.

**Pasos a seguir:**
1. Accede a la página 'Deuda de Contratos con Recargos'.
2. Selecciona el año de obra '2022'.
3. Selecciona la fecha '2024-06-01' para calcular recargos.
4. Presiona el botón 'Exportar'.

**Resultado esperado:**
El sistema genera un archivo Excel con la información mostrada en la tabla y lo descarga o muestra un enlace de descarga.

**Datos de prueba:**
{ "axo": 2022, "fecha_recargo": "2024-06-01" }

---

## Caso de Uso 3: Consulta sin Resultados

**Descripción:** El usuario consulta un año de obra para el cual no existen contratos con adeudo.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Accede a la página 'Deuda de Contratos con Recargos'.
2. Selecciona el año de obra '1990'.
3. Selecciona la fecha '2024-06-01'.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra el mensaje 'No hay resultados' en la tabla.

**Datos de prueba:**
{ "axo": 1990, "fecha_recargo": "2024-06-01" }

---

