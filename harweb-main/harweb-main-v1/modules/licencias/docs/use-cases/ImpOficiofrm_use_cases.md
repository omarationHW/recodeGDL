# Casos de Uso - ImpOficiofrm

**Categoría:** Form

## Caso de Uso 1: Registrar decisión de impresión de oficio improcedente

**Descripción:** El usuario encuentra un trámite improcedente y decide registrar el tipo de oficio a imprimir.

**Precondiciones:**
El usuario está autenticado y tiene acceso al trámite improcedente.

**Pasos a seguir:**
1. El usuario accede a la página del trámite improcedente.
2. Selecciona 'M24BIS' como tipo de oficio.
3. Escribe 'Falta documentación' en observaciones.
4. Hace clic en 'Aceptar'.

**Resultado esperado:**
La decisión queda registrada en la bitácora y el usuario recibe confirmación.

**Datos de prueba:**
{ "tramite_id": 123, "oficio_type": 3, "usuario_id": 45, "observaciones": "Falta documentación" }

---

## Caso de Uso 2: Cancelar registro de oficio improcedente

**Descripción:** El usuario decide no registrar ningún oficio para el trámite improcedente.

**Precondiciones:**
El usuario está autenticado y en la página del trámite.

**Pasos a seguir:**
1. El usuario accede a la página del trámite improcedente.
2. Hace clic en 'Cancelar'.

**Resultado esperado:**
El usuario es redirigido a la lista de trámites sin registrar ningún oficio.

**Datos de prueba:**
N/A

---

## Caso de Uso 3: Consultar información de trámite antes de registrar oficio

**Descripción:** El sistema muestra información básica del trámite antes de registrar la decisión.

**Precondiciones:**
El trámite existe en la base de datos.

**Pasos a seguir:**
1. El frontend solicita la información del trámite usando el ID.
2. El backend responde con los datos del trámite.

**Resultado esperado:**
La información del trámite se muestra correctamente en pantalla.

**Datos de prueba:**
{ "tramite_id": 123 }

---

