# Casos de Uso - IndividualDiversos

**Categoría:** Form

## Caso de Uso 1: Consulta de Convenio Diverso por Manzana/Lote/Letra

**Descripción:** El usuario desea consultar el estado de cuenta de un convenio diverso de regularización de predios, usando los datos de manzana, lote y letra.

**Precondiciones:**
El convenio existe en la base de datos y el usuario tiene acceso al sistema.

**Pasos a seguir:**
[
  "El usuario accede a la página de Consulta de Convenios Diversos.",
  "Selecciona el tipo '14' (Regularización de Predios) y el subtipo correspondiente.",
  "Ingresa la manzana, lote y letra del predio.",
  "Presiona el botón 'Buscar Convenio'.",
  "El sistema muestra los datos del convenio.",
  "El usuario puede ver los adeudos, pagos y referencias asociados."
]

**Resultado esperado:**
Se muestran correctamente los datos del convenio, la lista de adeudos, pagos y referencias.

**Datos de prueba:**
{
  "tipo": 14,
  "subtipo": 1,
  "manzana": "MZ-123",
  "lote": 5,
  "letra": "A"
}

---

## Caso de Uso 2: Consulta de Convenio Diverso por Expediente

**Descripción:** El usuario consulta un convenio diverso usando letras de oficio, folio y año.

**Precondiciones:**
El convenio existe y está vigente.

**Pasos a seguir:**
[
  "El usuario accede a la página de Consulta de Convenios Diversos.",
  "Selecciona el tipo y subtipo correspondiente (no 14).",
  "Ingresa las letras de oficio, folio y año.",
  "Presiona 'Buscar Convenio'.",
  "El sistema muestra los datos del convenio y permite ver adeudos, pagos y referencias."
]

**Resultado esperado:**
El convenio se localiza y se muestran todos los datos asociados.

**Datos de prueba:**
{
  "tipo": 3,
  "subtipo": 1,
  "letras_exp": "ZC1",
  "numero_exp": 1234,
  "axo_exp": 2022
}

---

## Caso de Uso 3: Visualización de Referencias y Detalle de Adeudos

**Descripción:** El usuario explora las referencias asociadas a un convenio y revisa el desglose de adeudos.

**Precondiciones:**
El convenio tiene referencias y adeudos registrados.

**Pasos a seguir:**
[
  "El usuario busca un convenio existente.",
  "Hace clic en 'Ver Referencias'.",
  "El sistema muestra la tabla de referencias con periodos, importes, recargos, gastos y multas.",
  "El usuario hace clic en 'Ver Adeudos'.",
  "El sistema muestra la lista de parcialidades con importes, intereses y recargos."
]

**Resultado esperado:**
Las referencias y los adeudos se muestran correctamente, con los cálculos de totales y periodos.

**Datos de prueba:**
{
  "id_conv_resto": 1001
}

---

