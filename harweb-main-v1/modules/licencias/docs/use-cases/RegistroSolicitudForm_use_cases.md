# Casos de Uso - RegistroSolicitudForm

**Categoría:** Form

## Caso de Uso 1: Registro de nueva solicitud de licencia

**Descripción:** Un usuario autorizado ingresa al sistema y registra una nueva solicitud de licencia comercial, llenando todos los campos requeridos.

**Precondiciones:**
El usuario está autenticado y tiene permisos para registrar solicitudes.

**Pasos a seguir:**
1. El usuario accede a la página de Registro de Solicitud.
2. El sistema carga los catálogos de giros, calles, colonias y fabricantes.
3. El usuario llena el formulario con los datos requeridos.
4. El usuario hace clic en 'Registrar Solicitud'.
5. El sistema valida los datos y envía la petición al endpoint `/api/execute` con action `submitSolicitud`.
6. El backend ejecuta el SP y devuelve el folio generado.

**Resultado esperado:**
La solicitud se registra correctamente y se muestra el folio generado.

**Datos de prueba:**
{
  "tipo_tramite": 1,
  "id_giro": 501,
  "actividad": "Venta de abarrotes",
  "propietario": "Juan Pérez",
  "telefono": "3312345678",
  "email": "juan@example.com",
  "calle": "AV. JUAREZ",
  "colonia": "CENTRO",
  "cp": "44100",
  "numext": "123",
  "numint": "",
  "letraext": "A",
  "letraint": "",
  "zona": 1,
  "subzona": 2,
  "sup_const": 100,
  "sup_autorizada": 80,
  "num_cajones": 2,
  "num_empleados": 3,
  "inversion": 50000,
  "rfc": "PEJJ800101XXX",
  "curp": "PEJJ800101HJCXXX09",
  "especificaciones": ""
}

---

## Caso de Uso 2: Agregar inspección a trámite existente

**Descripción:** Un usuario agrega una inspección (revisión) a un trámite ya registrado.

**Precondiciones:**
El trámite ya existe y el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario consulta el trámite existente.
2. El usuario selecciona la dependencia a inspeccionar.
3. El usuario hace clic en 'Agregar Inspección'.
4. El sistema envía la petición a `/api/execute` con action `addInspeccion`.
5. El backend ejecuta el SP y devuelve confirmación.

**Resultado esperado:**
La inspección se agrega correctamente y aparece en la lista de inspecciones del trámite.

**Datos de prueba:**
{ "id_tramite": 1234, "id_dependencia": 22 }

---

## Caso de Uso 3: Adjuntar documento a trámite

**Descripción:** El usuario adjunta un documento digital a un trámite existente.

**Precondiciones:**
El trámite existe y el usuario tiene permisos. El archivo ya fue subido y se tiene la ruta.

**Pasos a seguir:**
1. El usuario selecciona el trámite.
2. El usuario selecciona el documento y lo sube.
3. El sistema obtiene la ruta del archivo y el nombre.
4. El usuario hace clic en 'Adjuntar'.
5. El sistema envía la petición a `/api/execute` con action `addDocumento`.
6. El backend ejecuta el SP y devuelve confirmación.

**Resultado esperado:**
El documento queda registrado y aparece en la lista de documentos del trámite.

**Datos de prueba:**
{ "id_tramite": 1234, "nombre": "INE.pdf", "ruta": "/uploads/1234/INE.pdf" }

---

