# Casos de Uso - RptPadronLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Locales por Recaudadora y Mercado

**Descripción:** El usuario desea consultar el padrón de locales de una recaudadora y un mercado específico.

**Precondiciones:**
El usuario está autenticado y tiene acceso al sistema. Existen recaudadoras y mercados registrados.

**Pasos a seguir:**
[
  "El usuario accede a la página 'Padrón de Locales'.",
  "Selecciona una recaudadora de la lista.",
  "Selecciona un mercado asociado a la recaudadora.",
  "Hace clic en 'Consultar'.",
  "El sistema muestra la tabla de locales con sus datos y totales."
]

**Resultado esperado:**
Se muestra la lista de locales del mercado seleccionado, con totales de superficie y renta.

**Datos de prueba:**
{
  "oficina": 1,
  "mercado": 5
}

---

## Caso de Uso 2: Validación de Parámetros Faltantes

**Descripción:** El usuario intenta consultar el padrón sin seleccionar recaudadora o mercado.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
[
  "El usuario accede a la página 'Padrón de Locales'.",
  "No selecciona recaudadora o mercado.",
  "Hace clic en 'Consultar'."
]

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los parámetros son requeridos.

**Datos de prueba:**
{
  "oficina": null,
  "mercado": null
}

---

## Caso de Uso 3: Cálculo Correcto de Totales

**Descripción:** El sistema debe calcular correctamente el total de superficie y renta de los locales mostrados.

**Precondiciones:**
Existen locales con diferentes superficies y rentas en el mercado consultado.

**Pasos a seguir:**
[
  "El usuario consulta el padrón de un mercado.",
  "El sistema suma la columna 'superficie' y 'renta' de todos los locales mostrados.",
  "Se muestran los totales al pie de la tabla."
]

**Resultado esperado:**
Los totales de superficie y renta coinciden con la suma de los valores individuales.

**Datos de prueba:**
{
  "oficina": 2,
  "mercado": 10
}

---

