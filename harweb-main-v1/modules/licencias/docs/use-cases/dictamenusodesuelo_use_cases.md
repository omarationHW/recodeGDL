# Casos de Uso - dictamenusodesuelo

**Categoría:** Form

## Caso de Uso 1: Alta de nueva constancia de uso de suelo

**Descripción:** El usuario registra una nueva constancia (dictamen) de uso de suelo para una licencia existente.

**Precondiciones:**
El usuario está autenticado y tiene permisos. Existe la licencia a la que se liga la constancia.

**Pasos a seguir:**
- El usuario accede a la página de Dictamen de Uso de Suelo.
- Da clic en 'Nueva Constancia'.
- Llena los campos requeridos (Solicita, Partida de Pago, Observación, Domicilio, Licencia, Tipo).
- Da clic en 'Guardar'.
- El sistema valida y envía la petición a `/api/execute` con acción `create`.
- El backend incrementa el folio, guarda la constancia y responde éxito.

**Resultado esperado:**
La constancia queda registrada, aparece en el listado y puede ser impresa.

**Datos de prueba:**
{
  "solicita": "Juan Pérez",
  "partidapago": "12345",
  "observacion": "Para trámite de licencia",
  "domicilio": "Av. Juárez 123",
  "id_licencia": 1001,
  "capturista": "admin",
  "tipo": 0
}

---

## Caso de Uso 2: Cancelación de una constancia vigente

**Descripción:** El usuario cancela una constancia que aún está vigente.

**Precondiciones:**
Existe una constancia con vigente = 'V'.

**Pasos a seguir:**
- El usuario busca la constancia en el listado.
- Da clic en 'Cancelar'.
- Confirma la cancelación.
- El sistema envía la petición a `/api/execute` con acción `cancel`.
- El backend actualiza la constancia a vigente = 'C' y guarda el motivo.

**Resultado esperado:**
La constancia aparece como cancelada y ya no puede ser impresa.

**Datos de prueba:**
{ "axo": 2024, "folio": 123, "motivo": "Cancelada por error" }

---

## Caso de Uso 3: Impresión de constancia

**Descripción:** El usuario imprime una constancia vigente.

**Precondiciones:**
Existe una constancia con vigente = 'V'.

**Pasos a seguir:**
- El usuario localiza la constancia en el listado.
- Da clic en 'Imprimir'.
- El sistema envía la petición a `/api/execute` con acción `print`.
- El backend genera el PDF y devuelve la URL/base64.
- El frontend abre el PDF en una nueva ventana.

**Resultado esperado:**
El usuario visualiza el PDF de la constancia.

**Datos de prueba:**
{ "axo": 2024, "folio": 123 }

---

