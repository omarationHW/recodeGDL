# Casos de Uso - frmMetrometers

**Categoría:** Form

## Caso de Uso 1: Consulta de datos de MetroMeter por año y folio

**Descripción:** El usuario busca los datos de un MetroMeter específico ingresando el año y el folio.

**Precondiciones:**
El registro debe existir en la tabla ta14_adicional_mmeters.

**Pasos a seguir:**
1. El usuario accede a la página MetroMeters.
2. Ingresa el año (axo) y el folio.
3. Presiona el botón 'Buscar'.
4. El sistema consulta la base de datos y muestra los datos encontrados.

**Resultado esperado:**
Se muestran los datos completos del MetroMeter correspondiente.

**Datos de prueba:**
{ "axo": 2023, "folio": 123456 }

---

## Caso de Uso 2: Actualización de datos de MetroMeter

**Descripción:** El usuario edita los datos de un MetroMeter y guarda los cambios.

**Precondiciones:**
El registro debe existir y haber sido consultado previamente.

**Pasos a seguir:**
1. El usuario busca un MetroMeter existente.
2. Modifica los campos 'marca', 'motivo' y 'direccion'.
3. Presiona el botón 'Actualizar'.
4. El sistema actualiza el registro en la base de datos.

**Resultado esperado:**
El registro se actualiza correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "axo": 2023, "folio": 123456, "direccion": "NUEVA DIRECCION", "marca": "NUEVA MARCA", "motivo": "NUEVO MOTIVO" }

---

## Caso de Uso 3: Visualización de foto asociada al MetroMeter

**Descripción:** El usuario visualiza la foto 1 o 2 asociada al folio del MetroMeter.

**Precondiciones:**
El registro debe existir y tener fotos asociadas en el sistema externo.

**Pasos a seguir:**
1. El usuario busca un MetroMeter existente.
2. Presiona el botón 'Ver Foto 1'.
3. El sistema consulta el servicio externo y muestra la imagen.

**Resultado esperado:**
La foto se muestra correctamente en la interfaz.

**Datos de prueba:**
{ "folio": "123456", "photo_number": 1 }

---

