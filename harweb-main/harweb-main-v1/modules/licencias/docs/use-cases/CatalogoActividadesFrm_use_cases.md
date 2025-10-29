# Casos de Uso - CatalogoActividadesFrm

**Categoría:** Form

## Caso de Uso 1: Agregar una nueva actividad al catálogo

**Descripción:** El usuario desea registrar una nueva actividad asociada a un giro existente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. Existen giros vigentes en el sistema.

**Pasos a seguir:**
- El usuario accede a la página de Catálogo de Actividades.
- Da clic en 'Agregar Actividad'.
- Llena el formulario: selecciona un giro, escribe la descripción y observaciones, selecciona 'Vigente'.
- Da clic en 'Guardar'.
- El sistema envía la petición a `/api/execute` con acción `catalogo_actividades.create` y los datos del formulario.

**Resultado esperado:**
La actividad se registra correctamente, aparece en la lista y muestra mensaje de éxito.

**Datos de prueba:**
{
  "id_giro": 1001,
  "descripcion": "Venta de alimentos preparados",
  "observaciones": "Incluye restaurantes y fondas",
  "vigente": "V"
}

---

## Caso de Uso 2: Editar una actividad existente

**Descripción:** El usuario necesita corregir la descripción de una actividad ya registrada.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. La actividad existe y está vigente.

**Pasos a seguir:**
- El usuario busca la actividad por descripción.
- Da clic en 'Editar' en la fila correspondiente.
- Modifica la descripción y observaciones.
- Da clic en 'Guardar'.
- El sistema envía la petición a `/api/execute` con acción `catalogo_actividades.update` y los datos modificados.

**Resultado esperado:**
La actividad se actualiza correctamente y la lista refleja los cambios.

**Datos de prueba:**
{
  "id": 5,
  "id_giro": 1001,
  "descripcion": "Venta de alimentos y bebidas",
  "observaciones": "Incluye restaurantes, bares y fondas",
  "vigente": "V"
}

---

## Caso de Uso 3: Eliminar (cancelar) una actividad

**Descripción:** El usuario desea dar de baja una actividad que ya no debe estar disponible.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. La actividad existe y está vigente.

**Pasos a seguir:**
- El usuario localiza la actividad en la lista.
- Da clic en 'Eliminar'.
- Confirma la acción.
- El sistema envía la petición a `/api/execute` con acción `catalogo_actividades.delete` y el ID de la actividad.

**Resultado esperado:**
La actividad cambia su estatus a 'Cancelado' y ya no puede ser editada ni eliminada nuevamente.

**Datos de prueba:**
{
  "id": 7,
  "motivo_baja": "Actividad obsoleta"
}

---

