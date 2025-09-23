# Casos de Uso - constanciafrm

**Categoría:** Form

## Caso de Uso 1: Alta de nueva constancia de licencia

**Descripción:** Un usuario autorizado desea registrar una nueva constancia de licencia para un contribuyente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de captura. El folio actual está disponible en la tabla parametros.

**Pasos a seguir:**
[
  "El usuario accede a la página de constancias.",
  "Hace clic en 'Nueva Constancia'.",
  "Llena los campos requeridos: tipo, solicita, partidapago, observacion, domicilio, id_licencia, capturista.",
  "Hace clic en 'Guardar'.",
  "El frontend envía un eRequest con action 'create' y los datos.",
  "El backend valida, ejecuta el SP de creación, actualiza el folio y retorna la constancia creada.",
  "La constancia aparece en el listado."
]

**Resultado esperado:**
La constancia se registra correctamente, el folio se incrementa y la constancia aparece en el listado con estado 'Vigente'.

**Datos de prueba:**
{
  "tipo": 0,
  "solicita": "Juan Perez",
  "partidapago": "12345",
  "observacion": "N/A",
  "domicilio": "Av. Juarez 123",
  "id_licencia": 1001,
  "capturista": "usuario1"
}

---

## Caso de Uso 2: Cancelación de una constancia existente

**Descripción:** Un usuario necesita cancelar una constancia por error en la captura.

**Precondiciones:**
Existe una constancia vigente (vigente='V') con axo=2024 y folio=10.

**Pasos a seguir:**
[
  "El usuario busca la constancia en el listado.",
  "Hace clic en 'Cancelar'.",
  "Ingresa el motivo de cancelación.",
  "Confirma la cancelación.",
  "El frontend envía un eRequest con action 'cancel', axo y folio, y el motivo.",
  "El backend ejecuta el SP de cancelación y retorna la constancia con vigente='C'."
]

**Resultado esperado:**
La constancia cambia a estado 'Cancelada' y no puede ser impresa.

**Datos de prueba:**
{
  "axo": 2024,
  "folio": 10,
  "observacion": "Cancelada por error de captura"
}

---

## Caso de Uso 3: Impresión de constancia

**Descripción:** Un usuario imprime una constancia para entregarla al contribuyente.

**Precondiciones:**
Existe una constancia vigente con axo=2024 y folio=11.

**Pasos a seguir:**
[
  "El usuario localiza la constancia en el listado.",
  "Hace clic en 'Imprimir'.",
  "El frontend envía un eRequest con action 'print', axo y folio.",
  "El backend ejecuta el SP de impresión y retorna la URL o base64 del PDF.",
  "El frontend muestra el PDF en un iframe o lo descarga."
]

**Resultado esperado:**
El PDF de la constancia se genera correctamente y es accesible para el usuario.

**Datos de prueba:**
{
  "axo": 2024,
  "folio": 11
}

---

