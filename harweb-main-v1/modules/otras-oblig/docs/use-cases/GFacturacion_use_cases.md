# Casos de Uso - GFacturacion

**Categoría:** Form

## Caso de Uso 1: Consulta de Facturación del Periodo Actual

**Descripción:** El usuario consulta la facturación general del periodo actual para la tabla 'Rastro', incluyendo adeudos y pagos con recargos.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de facturación para el periodo actual.

**Pasos a seguir:**
[
  "El usuario ingresa a la página de Facturación General.",
  "Selecciona la tabla 'Rastro'.",
  "Deja seleccionado 'Periodo Actual'.",
  "Selecciona 'Adeudos y Pagos' como tipo de consulta.",
  "Activa la opción 'Adeudos con recargos'.",
  "Hace clic en 'Consultar'."
]

**Resultado esperado:**
Se muestra una tabla con los registros de facturación del periodo actual, incluyendo el total de importes.

**Datos de prueba:**
{
  "par_Tab": "3",
  "par_Ade": "A",
  "Par_Rcgo": "S",
  "par_Axo": 2024,
  "par_Mes": 6
}

---

## Caso de Uso 2: Consulta de Solo Pagados de un Periodo Anterior

**Descripción:** El usuario consulta únicamente los registros pagados de un periodo anterior para la tabla 'Rastro'.

**Precondiciones:**
Existen registros pagados en el periodo anterior.

**Pasos a seguir:**
[
  "El usuario ingresa a la página de Facturación General.",
  "Selecciona la tabla 'Rastro'.",
  "Selecciona 'Otro Periodo'.",
  "Ingresa año 2023 y mes 12.",
  "Selecciona 'Solo Pagados' como tipo de consulta.",
  "Hace clic en 'Consultar'."
]

**Resultado esperado:**
Se muestran únicamente los registros pagados del periodo 2023-12.

**Datos de prueba:**
{
  "par_Tab": "3",
  "par_Ade": "C",
  "Par_Rcgo": "N",
  "par_Axo": 2023,
  "par_Mes": 12
}

---

## Caso de Uso 3: Consulta de Solo Adeudos sin Recargos

**Descripción:** El usuario consulta solo los adeudos (sin pagos) y sin recargos para el periodo actual.

**Precondiciones:**
Existen adeudos sin recargos en el periodo actual.

**Pasos a seguir:**
[
  "El usuario ingresa a la página de Facturación General.",
  "Selecciona la tabla 'Rastro'.",
  "Deja seleccionado 'Periodo Actual'.",
  "Selecciona 'Solo Adeudos' como tipo de consulta.",
  "Desactiva la opción 'Adeudos con recargos'.",
  "Hace clic en 'Consultar'."
]

**Resultado esperado:**
Se muestran únicamente los registros de adeudos sin recargos del periodo actual.

**Datos de prueba:**
{
  "par_Tab": "3",
  "par_Ade": "B",
  "Par_Rcgo": "N",
  "par_Axo": 2024,
  "par_Mes": 6
}

---

