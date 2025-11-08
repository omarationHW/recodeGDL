# Casos de Uso - Menu

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Energía por Oficina y Mercado

**Descripción:** El usuario desea consultar todos los adeudos de energía eléctrica para una oficina y mercado específicos en un año y mes determinados.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de consulta.

**Pasos a seguir:**
[
  "El usuario accede a la página de Adeudos de Energía.",
  "Selecciona la oficina recaudadora de la lista.",
  "Selecciona el mercado correspondiente.",
  "Ingresa el año y el mes de consulta.",
  "Presiona el botón 'Buscar'."
]

**Resultado esperado:**
Se muestra una tabla con los adeudos de energía eléctrica para los locales del mercado seleccionado en el periodo indicado.

**Datos de prueba:**
{
  "oficina": 3,
  "mercado": 15,
  "axo": 2024,
  "mes": 6
}

---

## Caso de Uso 2: Visualización de Meses de Adeudo por Local

**Descripción:** El usuario desea ver el detalle de los meses de adeudo de energía eléctrica para un local específico.

**Precondiciones:**
El usuario debe haber realizado una consulta de adeudos y tener la tabla de resultados visible.

**Pasos a seguir:**
[
  "El usuario localiza el local de interés en la tabla de adeudos.",
  "Presiona el botón 'Ver' en la columna 'Periodo de Adeudo' correspondiente al local.",
  "Se abre un modal con el detalle de los meses y montos adeudados."
]

**Resultado esperado:**
El modal muestra una lista de meses y los importes adeudados para el local seleccionado.

**Datos de prueba:**
{
  "id_energia": 12345,
  "axo": 2024,
  "mes": 6
}

---

## Caso de Uso 3: Exportación de Adeudos a Excel

**Descripción:** El usuario desea exportar el listado de adeudos de energía eléctrica a un archivo Excel.

**Precondiciones:**
El usuario debe haber realizado una consulta de adeudos y tener resultados visibles.

**Pasos a seguir:**
[
  "El usuario presiona el botón 'Exportar a Excel'.",
  "El sistema genera el archivo Excel y lo descarga al equipo del usuario."
]

**Resultado esperado:**
El usuario obtiene un archivo Excel con el listado de adeudos consultados.

**Datos de prueba:**
{
  "oficina": 3,
  "mercado": 15,
  "axo": 2024,
  "mes": 6
}

---

