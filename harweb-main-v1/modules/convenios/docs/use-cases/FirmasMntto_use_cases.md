# Casos de Uso - FirmasMntto

**Categoría:** Form

## Caso de Uso 1: Alta de Firma de Recaudadora

**Descripción:** Un usuario con permisos de administrador desea registrar una nueva firma para una recaudadora.

**Precondiciones:**
El usuario está autenticado y tiene permisos de mantenimiento de catálogos.

**Pasos a seguir:**
1. El usuario accede a la página de Mantenimiento de Firmas.
2. Hace clic en 'Agregar Firma'.
3. Llena todos los campos obligatorios del formulario.
4. Hace clic en 'Guardar'.
5. El sistema valida los datos y envía la petición a /api/execute con action=firmas.create.

**Resultado esperado:**
La firma es registrada correctamente y aparece en el listado. Se muestra mensaje de éxito.

**Datos de prueba:**
{
  "recaudadora": 2,
  "titular": "LUIS MARTINEZ",
  "cargotitular": "JEFE DE RECAUDACION",
  "recaudador": "CARLOS SANCHEZ",
  "cargorecaudador": "RECAUDADOR",
  "testigo1": "JORGE DIAZ",
  "testigo2": "LAURA MORA",
  "letras": "ZO2"
}

---

## Caso de Uso 2: Modificación de Firma Existente

**Descripción:** El usuario necesita actualizar el nombre del titular de una recaudadora.

**Precondiciones:**
Existe una firma registrada para la recaudadora 2.

**Pasos a seguir:**
1. El usuario localiza la firma en el listado.
2. Hace clic en 'Editar'.
3. Cambia el campo 'Titular' y hace clic en 'Guardar'.
4. El sistema envía la petición a /api/execute con action=firmas.update.

**Resultado esperado:**
La información se actualiza correctamente y se muestra mensaje de éxito.

**Datos de prueba:**
{
  "recaudadora": 2,
  "titular": "LUIS M. MARTINEZ",
  "cargotitular": "JEFE DE RECAUDACION",
  "recaudador": "CARLOS SANCHEZ",
  "cargorecaudador": "RECAUDADOR",
  "testigo1": "JORGE DIAZ",
  "testigo2": "LAURA MORA",
  "letras": "ZO2"
}

---

## Caso de Uso 3: Eliminación de Firma

**Descripción:** El usuario desea eliminar una firma de recaudadora que ya no es válida.

**Precondiciones:**
Existe una firma registrada para la recaudadora 2.

**Pasos a seguir:**
1. El usuario localiza la firma en el listado.
2. Hace clic en 'Eliminar'.
3. El sistema solicita confirmación.
4. El usuario confirma.
5. El sistema envía la petición a /api/execute con action=firmas.delete.

**Resultado esperado:**
La firma es eliminada del sistema y se muestra mensaje de éxito.

**Datos de prueba:**
{ "recaudadora": 2 }

---

