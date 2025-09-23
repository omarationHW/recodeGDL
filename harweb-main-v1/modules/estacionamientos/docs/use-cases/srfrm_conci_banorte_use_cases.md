# Casos de Uso - srfrm_conci_banorte

**Categoría:** Form

## Caso de Uso 1: Consulta de Conciliación por Folio

**Descripción:** El usuario desea consultar los pagos conciliados de Banorte para un folio y año específicos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página 'Conciliación Banorte por Folio'.
2. Ingresa el año y folio deseados.
3. Presiona el botón 'Buscar'.
4. El sistema consulta la API con eRequest 'searchConciliadosByFolio'.
5. El sistema muestra la lista de registros encontrados y el historial asociado.

**Resultado esperado:**
Se muestran los registros conciliados y el historial correspondiente al folio y año ingresados.

**Datos de prueba:**
{ axo: 2023, folio: 123456 }

---

## Caso de Uso 2: Cambio de Placa Capturada por Banco

**Descripción:** El usuario detecta un error en la placa capturada por el banco y desea corregirla.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. Existe un registro conciliado con error de placa.

**Pasos a seguir:**
1. El usuario accede a la página de consulta por folio y busca el registro.
2. Selecciona 'Cambiar Placa' en el registro deseado.
3. Ingresa la nueva placa y confirma.
4. El sistema envía la petición a la API con eRequest 'cambiarPlaca'.
5. El sistema muestra un mensaje de éxito o error.

**Resultado esperado:**
La placa es actualizada correctamente en la base de datos y se muestra un mensaje de confirmación.

**Datos de prueba:**
{ control: 789, idbanco: 456, axo: 2023, folio: 123456, placa: 'ABC1234', id_usuario: 1 }

---

## Caso de Uso 3: Cambio de Folio (Folio Existente)

**Descripción:** El usuario necesita reasignar un folio a un registro conciliado, seleccionando la opción de folio existente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. El folio de destino existe.

**Pasos a seguir:**
1. El usuario accede a la página de consulta por folio y busca el registro.
2. Selecciona 'Cambiar Folio' en el registro deseado.
3. Ingresa el nuevo año y folio, marca 'Existe Folio' y confirma.
4. El sistema envía la petición a la API con eRequest 'cambiarFolio' y opcion=2.
5. El sistema muestra un mensaje de éxito o error.

**Resultado esperado:**
El folio es reasignado correctamente y se muestra un mensaje de confirmación.

**Datos de prueba:**
{ control: 789, idbanco: 456, axo: 2023, folio: 654321, placa: 'XYZ9876', id_usuario: 1, opcion: 2 }

---

