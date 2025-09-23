# Casos de Uso - observafrm

**Categoría:** Form

## Caso de Uso 1: Agregar una nueva observación a una transmisión patrimonial

**Descripción:** El usuario desea registrar una observación sobre una transmisión patrimonial específica.

**Precondiciones:**
El usuario está autenticado y conoce el número de cuenta catastral.

**Pasos a seguir:**
1. El usuario ingresa el número de cuenta catastral en el campo correspondiente.
2. El usuario llena el formulario de observación (folio opcional, texto de observación, usuario, marca si es global).
3. El usuario presiona 'Agregar'.
4. El sistema valida los datos y guarda la observación.

**Resultado esperado:**
La observación se almacena en la base de datos y aparece en el historial.

**Datos de prueba:**
{
  "cvecuenta": 123456,
  "folio": 789,
  "observacion": "SE DETECTÓ INCONSISTENCIA EN DOCUMENTOS",
  "usuario": "jlopez",
  "es_global": false
}

---

## Caso de Uso 2: Editar una observación existente

**Descripción:** El usuario necesita corregir el texto de una observación ya registrada.

**Precondiciones:**
Existe al menos una observación registrada para la cuenta.

**Pasos a seguir:**
1. El usuario selecciona la observación a editar en el historial.
2. El usuario modifica el texto de la observación.
3. El usuario presiona 'Actualizar'.
4. El sistema valida y actualiza la observación.

**Resultado esperado:**
La observación se actualiza correctamente y el historial refleja el cambio.

**Datos de prueba:**
{
  "id": 5,
  "observacion": "DOCUMENTACIÓN COMPLETA, SIN OBSERVACIONES",
  "usuario": "jlopez"
}

---

## Caso de Uso 3: Eliminar una observación

**Descripción:** El usuario decide eliminar una observación incorrecta.

**Precondiciones:**
Existe al menos una observación registrada.

**Pasos a seguir:**
1. El usuario presiona el botón 'Eliminar' junto a la observación deseada.
2. El sistema solicita confirmación.
3. El usuario confirma.
4. El sistema elimina la observación.

**Resultado esperado:**
La observación desaparece del historial.

**Datos de prueba:**
{
  "id": 5
}

---

