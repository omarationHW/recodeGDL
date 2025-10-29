# Casos de Uso - LicenciaMicrogeneradorEcologia

**Categoría:** Form

## Caso de Uso 1: Autorizar Licencia como Microgenerador

**Descripción:** El usuario desea autorizar una licencia vigente como microgenerador de ecología.

**Precondiciones:**
La licencia existe y no está registrada como microgenerador vigente.

**Pasos a seguir:**
1. El usuario selecciona 'Licencia' en el formulario y captura el número de licencia.
2. Presiona 'Consultar'.
3. El sistema muestra los datos de la licencia y el botón 'Autorizar como Microgenerador'.
4. El usuario presiona 'Autorizar como Microgenerador'.
5. El sistema ejecuta el SP y muestra mensaje de éxito.

**Resultado esperado:**
La licencia queda registrada como microgenerador y el mensaje 'Alta exitosa, Licencia registrada como microgenerador.' se muestra.

**Datos de prueba:**
tipo: 'L', id: 12345

---

## Caso de Uso 2: Cancelar Microgenerador de un Trámite

**Descripción:** El usuario desea cancelar el registro de microgenerador para un trámite.

**Precondiciones:**
El trámite está registrado como microgenerador vigente.

**Pasos a seguir:**
1. El usuario selecciona 'Trámite' y captura el ID de trámite.
2. Presiona 'Consultar'.
3. El sistema muestra los datos y el botón 'Cancelar Microgenerador'.
4. El usuario presiona 'Cancelar Microgenerador'.
5. El sistema ejecuta el SP y muestra mensaje de éxito.

**Resultado esperado:**
El trámite queda cancelado como microgenerador y el mensaje 'Cancelación exitosa, Trámite cancelado como microgenerador.' se muestra.

**Datos de prueba:**
tipo: 'T', id: 54321

---

## Caso de Uso 3: Intentar Autorizar Microgenerador ya Existente

**Descripción:** El usuario intenta autorizar como microgenerador una licencia que ya está vigente como microgenerador.

**Precondiciones:**
La licencia ya está registrada como microgenerador vigente.

**Pasos a seguir:**
1. El usuario selecciona 'Licencia' y captura el número de licencia.
2. Presiona 'Consultar'.
3. El sistema muestra que ya es microgenerador y el botón 'Cancelar Microgenerador'.
4. El usuario presiona 'Autorizar como Microgenerador'.
5. El sistema muestra mensaje de error.

**Resultado esperado:**
El sistema muestra el mensaje 'Licencia ya es microgenerador vigente.' y no realiza ninguna acción.

**Datos de prueba:**
tipo: 'L', id: 12345

---

