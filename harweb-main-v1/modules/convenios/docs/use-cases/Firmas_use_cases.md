# Casos de Uso - Firmas

**Categoría:** Form

## Caso de Uso 1: Alta de nueva firma de convenio

**Descripción:** El usuario desea agregar una nueva firma para una recaudadora específica.

**Precondiciones:**
El usuario tiene permisos de administrador y está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Firmas.
2. Da clic en 'Agregar'.
3. Llena todos los campos del formulario (recaudadora, titular, cargos, testigos, letras).
4. Da clic en 'Guardar'.

**Resultado esperado:**
La firma se almacena en la base de datos y aparece en el listado.

**Datos de prueba:**
{
  "recaudadora": 2,
  "titular": "Luis Gómez",
  "cargotitular": "Director General",
  "recaudador": "Marta Sánchez",
  "cargorecaudador": "Jefa de Oficina",
  "testigo1": "Pedro Torres",
  "testigo2": "Lucía Méndez",
  "letras": "ZO2"
}

---

## Caso de Uso 2: Edición de firma existente

**Descripción:** El usuario necesita actualizar el nombre del titular y el cargo de una firma ya registrada.

**Precondiciones:**
Existe una firma registrada para la recaudadora 2.

**Pasos a seguir:**
1. El usuario selecciona la fila correspondiente a la recaudadora 2.
2. Da clic en 'Editar'.
3. Modifica el campo 'titular' y 'cargotitular'.
4. Da clic en 'Guardar'.

**Resultado esperado:**
La firma se actualiza correctamente y los cambios se reflejan en el listado.

**Datos de prueba:**
{
  "recaudadora": 2,
  "titular": "Luis Gómez Ramírez",
  "cargotitular": "Director Ejecutivo",
  "recaudador": "Marta Sánchez",
  "cargorecaudador": "Jefa de Oficina",
  "testigo1": "Pedro Torres",
  "testigo2": "Lucía Méndez",
  "letras": "ZO2"
}

---

## Caso de Uso 3: Eliminación de firma

**Descripción:** El usuario elimina una firma de una recaudadora que ya no es necesaria.

**Precondiciones:**
Existe una firma registrada para la recaudadora 2.

**Pasos a seguir:**
1. El usuario selecciona la fila de la recaudadora 2.
2. Da clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La firma desaparece del listado y se elimina de la base de datos.

**Datos de prueba:**
{ "recaudadora": 2 }

---

