# Casos de Uso - SGCv2

**Categoría:** Form

## Caso de Uso 1: Alta de Trámite de Licencia

**Descripción:** El usuario da de alta un trámite de licencia nueva, ingresando todos los datos requeridos.

**Precondiciones:**
El usuario está autenticado y tiene permisos para alta de trámites.

**Pasos a seguir:**
[
  "El usuario navega a la página de Alta de Licencia.",
  "Llena el formulario con los datos del propietario, giro, domicilio, etc.",
  "Presiona 'Guardar'.",
  "El frontend envía un eRequest con acción 'altaTramiteLicencia' y los datos.",
  "El backend ejecuta el SP correspondiente.",
  "El sistema retorna el id_tramite generado y status 'ok'."
]

**Resultado esperado:**
El trámite se registra correctamente y se muestra el número de folio generado.

**Datos de prueba:**
{
  "tipo_tramite": 1,
  "id_giro": 123,
  "propietario": "Juan Perez",
  "rfc": "PEJJ800101XXX",
  "curp": "PEJJ800101HJCXXX01",
  "domicilio": "Av. Juarez 123",
  "telefono_prop": "3331234567",
  "email": "juan.perez@email.com"
}

---

## Caso de Uso 2: Bloqueo de Licencia

**Descripción:** El usuario bloquea una licencia por motivo administrativo.

**Precondiciones:**
El usuario tiene permisos de bloqueo.

**Pasos a seguir:**
[
  "El usuario navega a la página de Bloqueo de Licencia.",
  "Ingresa el número de licencia y el motivo.",
  "Presiona 'Bloquear'.",
  "El frontend envía un eRequest con acción 'bloquearLicencia'.",
  "El backend ejecuta el SP de bloqueo.",
  "El sistema retorna status 'bloqueada'."
]

**Resultado esperado:**
La licencia queda bloqueada y se registra el motivo.

**Datos de prueba:**
{
  "licencia": 456,
  "motivo": "Falta de pago",
  "usuario": "admin"
}

---

## Caso de Uso 3: Consulta de Licencia

**Descripción:** El usuario consulta los datos de una licencia existente.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
[
  "El usuario navega a la página de Consulta de Licencia.",
  "Ingresa el número de licencia.",
  "Presiona 'Buscar'.",
  "El frontend envía un eRequest con acción 'consultaLicencia'.",
  "El backend ejecuta el SP de consulta.",
  "El sistema retorna los datos de la licencia."
]

**Resultado esperado:**
Se muestran todos los datos de la licencia consultada.

**Datos de prueba:**
{
  "licencia": 456
}

---

