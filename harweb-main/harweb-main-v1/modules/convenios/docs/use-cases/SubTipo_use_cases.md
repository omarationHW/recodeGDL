# Casos de Uso - SubTipo

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo SubTipo de Convenio

**Descripción:** El usuario desea agregar un nuevo subtipo para un tipo de convenio existente.

**Precondiciones:**
El usuario tiene permisos de escritura y conoce el tipo al que desea agregar el subtipo.

**Pasos a seguir:**
- El usuario ingresa a la página de SubTipos.
- Hace clic en 'Agregar SubTipo'.
- Completa los campos: Tipo (por ejemplo, 1), SubTipo (por ejemplo, 3), Descripción, Cuenta Ingreso, ID Usuario.
- Presiona 'Guardar'.
- El sistema envía la petición a `/api/execute` con acción `create_subtipo`.
- El backend ejecuta el stored procedure y retorna el nuevo registro.

**Resultado esperado:**
El nuevo subtipo aparece en la lista y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "tipo": 1,
  "subtipo": 3,
  "desc_subtipo": "Convenio especial",
  "cuenta_ingreso": 123456,
  "id_usuario": 5
}

---

## Caso de Uso 2: Edición de un SubTipo existente

**Descripción:** El usuario necesita modificar la descripción y cuenta de ingreso de un subtipo existente.

**Precondiciones:**
Existe un subtipo con tipo=1 y subtipo=3.

**Pasos a seguir:**
- El usuario localiza el subtipo en la lista.
- Hace clic en 'Editar'.
- Modifica la descripción y la cuenta de ingreso.
- Presiona 'Guardar'.
- El sistema envía la petición a `/api/execute` con acción `update_subtipo`.

**Resultado esperado:**
El subtipo se actualiza correctamente y se refleja en la lista.

**Datos de prueba:**
{
  "tipo": 1,
  "subtipo": 3,
  "desc_subtipo": "Convenio modificado",
  "cuenta_ingreso": 654321,
  "id_usuario": 5
}

---

## Caso de Uso 3: Eliminación de un SubTipo

**Descripción:** El usuario desea eliminar un subtipo que ya no se utiliza.

**Precondiciones:**
Existe un subtipo con tipo=1 y subtipo=3.

**Pasos a seguir:**
- El usuario localiza el subtipo en la lista.
- Hace clic en 'Eliminar'.
- Confirma la eliminación.
- El sistema envía la petición a `/api/execute` con acción `delete_subtipo`.

**Resultado esperado:**
El subtipo desaparece de la lista y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "tipo": 1,
  "subtipo": 3
}

---

