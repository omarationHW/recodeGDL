# Casos de Uso - ReqTrans

**Categoría:** Form

## Caso de Uso 1: Captura de nuevo requerimiento de transmisión patrimonial

**Descripción:** Un usuario autorizado ingresa un nuevo requerimiento de transmisión patrimonial usando el formulario web.

**Precondiciones:**
El usuario está autenticado y tiene permisos de captura. El catálogo de ejecutores está cargado.

**Pasos a seguir:**
- El usuario accede a la página de 'Captura Requerimientos Transmisiones Patrimoniales'.
- Llena todos los campos obligatorios del formulario.
- Presiona 'Guardar'.
- El sistema valida los datos y envía la petición al endpoint `/api/execute` con action 'create'.
- El backend ejecuta el stored procedure de alta y responde con el id generado.

**Resultado esperado:**
El registro es guardado correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "folioreq": 20240001,
  "tipo": "N",
  "cvecta": 123456,
  "cveejec": 12,
  "fecemi": "2024-06-10",
  "importe": 1000.00,
  "recargos": 50.00,
  "multas_ex": 0.00,
  "multas_otr": 0.00,
  "gastos": 100.00,
  "gastos_req": 0.00,
  "total": 1150.00,
  "observ": "Test requerimiento",
  "usu_act": "admin"
}

---

## Caso de Uso 2: Consulta de requerimiento por folio

**Descripción:** Un usuario consulta los datos de un requerimiento de transmisión patrimonial existente por folio.

**Precondiciones:**
El requerimiento existe en la base de datos.

**Pasos a seguir:**
- El usuario accede a la página y utiliza el buscador de folio.
- Ingresa el número de folio y presiona 'Buscar'.
- El sistema envía la petición al endpoint `/api/execute` con action 'list'.
- El backend devuelve los datos del requerimiento.

**Resultado esperado:**
Se muestran los datos del requerimiento correspondiente al folio.

**Datos de prueba:**
{ "folio": 20240001 }

---

## Caso de Uso 3: Actualización de requerimiento existente

**Descripción:** Un usuario autorizado actualiza los datos de un requerimiento de transmisión patrimonial.

**Precondiciones:**
El requerimiento existe y el usuario tiene permisos de edición.

**Pasos a seguir:**
- El usuario busca el requerimiento y edita los campos necesarios.
- Presiona 'Guardar'.
- El sistema valida y envía la petición al endpoint `/api/execute` con action 'update'.
- El backend ejecuta el stored procedure de actualización.

**Resultado esperado:**
El registro es actualizado correctamente.

**Datos de prueba:**
{
  "id": 55,
  "folioreq": 20240001,
  "tipo": "R",
  "cvecta": 123456,
  "cveejec": 12,
  "fecemi": "2024-06-11",
  "importe": 1200.00,
  "recargos": 60.00,
  "multas_ex": 0.00,
  "multas_otr": 0.00,
  "gastos": 120.00,
  "gastos_req": 0.00,
  "total": 1280.00,
  "observ": "Actualización de requerimiento",
  "usu_act": "admin"
}

---

