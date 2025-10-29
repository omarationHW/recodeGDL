# Casos de Uso - constanciaNoOficialfrm

**Categoría:** Form

## Caso de Uso 1: Alta de Solicitud de Número Oficial

**Descripción:** Un usuario autorizado crea una nueva solicitud de número oficial para un predio.

**Precondiciones:**
El usuario está autenticado y tiene permisos para crear solicitudes.

**Pasos a seguir:**
[
  "El usuario accede a la página de solicitudes.",
  "Hace clic en 'Nueva'.",
  "Llena los campos: Propietario, Actividad, Ubicación, Zona, Subzona.",
  "Hace clic en 'Aceptar'.",
  "El sistema valida los datos y llama a la API con acción 'create'.",
  "La API responde con la solicitud creada (incluyendo año y folio asignados)."
]

**Resultado esperado:**
La solicitud se crea correctamente, aparece en la lista y puede ser seleccionada.

**Datos de prueba:**
{
  "propietario": "JUAN PEREZ",
  "actividad": "COMERCIO",
  "ubicacion": "AV. JUAREZ 123",
  "zona": 1,
  "subzona": 2
}

---

## Caso de Uso 2: Cancelación de Solicitud Vigente

**Descripción:** Un usuario cancela una solicitud vigente seleccionada.

**Precondiciones:**
Existe al menos una solicitud vigente en la lista.

**Pasos a seguir:**
[
  "El usuario selecciona una solicitud vigente en la tabla.",
  "Hace clic en 'Cancelar Solicitud'.",
  "Confirma la cancelación.",
  "El sistema llama a la API con acción 'cancel'.",
  "La API responde con éxito y la solicitud cambia a estado 'C'."
]

**Resultado esperado:**
La solicitud aparece como cancelada y no puede ser modificada.

**Datos de prueba:**
{
  "axo": 2024,
  "folio": 5
}

---

## Caso de Uso 3: Impresión de Solicitud

**Descripción:** El usuario imprime una solicitud seleccionada.

**Precondiciones:**
Existe una solicitud seleccionada.

**Pasos a seguir:**
[
  "El usuario selecciona una solicitud.",
  "Hace clic en 'Imprimir'.",
  "El sistema llama a la API con acción 'print'.",
  "La API responde con la URL del PDF.",
  "El navegador abre el PDF en una nueva pestaña."
]

**Resultado esperado:**
El PDF de la solicitud se muestra correctamente.

**Datos de prueba:**
{
  "axo": 2024,
  "folio": 5
}

---

