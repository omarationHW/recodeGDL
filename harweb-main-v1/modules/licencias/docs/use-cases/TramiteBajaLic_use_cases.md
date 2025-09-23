# Casos de Uso - TramiteBajaLic

**Categoría:** Form

## Caso de Uso 1: Consulta de Licencia para Baja

**Descripción:** El usuario busca una licencia para iniciar el trámite de baja.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el número de licencia.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia en el formulario.
2. Presiona el botón 'Buscar'.
3. El sistema consulta la base de datos y muestra los datos de la licencia, adeudos y trámites realizados.

**Resultado esperado:**
Se muestran correctamente los datos de la licencia, los adeudos actuales y los trámites de baja previos.

**Datos de prueba:**
{ "licencia": 123456 }

---

## Caso de Uso 2: Tramitar Baja de Licencia

**Descripción:** El usuario realiza el trámite de baja de una licencia vigente.

**Precondiciones:**
La licencia existe, está vigente y no tiene bloqueos que impidan la baja.

**Pasos a seguir:**
1. El usuario consulta la licencia.
2. Llena el motivo de la baja y la fecha administrativa.
3. Presiona el botón 'Tramitar Baja'.
4. El sistema valida los datos, calcula importes y registra el trámite.

**Resultado esperado:**
El trámite de baja se registra, se genera un folio y se actualiza la lista de trámites realizados.

**Datos de prueba:**
{ "licencia": 123456, "motivo": "Cierre de negocio", "baja_admva": "2024-07-01", "usuario": "jlopezv" }

---

## Caso de Uso 3: Recalcular Proporcional de Adeudos

**Descripción:** El usuario solicita el recálculo de los saldos proporcionales de la licencia antes de tramitar la baja.

**Precondiciones:**
La licencia existe y tiene adeudos calculados.

**Pasos a seguir:**
1. El usuario consulta la licencia.
2. Presiona el botón 'Recalcular Proporcional'.
3. El sistema ejecuta el SP de recálculo y actualiza los importes.

**Resultado esperado:**
Los saldos proporcionales se recalculan y se muestran los nuevos importes en pantalla.

**Datos de prueba:**
{ "licencia": 123456 }

---

