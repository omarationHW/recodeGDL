# Casos de Uso - ElaboraConvenios

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo responsable de elaboración de convenio

**Descripción:** El usuario desea registrar un nuevo responsable de elaboración de convenios para una recaudadora específica.

**Precondiciones:**
El usuario tiene permisos de alta y conoce los IDs de recaudadora y usuarios.

**Pasos a seguir:**
1. El usuario accede a la página 'Quien elabora convenios'.
2. Hace clic en 'Agregar'.
3. Llena el formulario con los datos requeridos (ID recaudadora, ID usuario titular, iniciales titular, ID usuario elabora, iniciales elabora).
4. Hace clic en 'Guardar'.
5. El sistema valida y guarda el registro.

**Resultado esperado:**
El nuevo registro aparece en la tabla y puede ser editado o eliminado.

**Datos de prueba:**
{
  "id_rec": 2,
  "id_usu_titular": 101,
  "iniciales_titular": "JSM",
  "id_usu_elaboro": 102,
  "iniciales_elaboro": "LPR"
}

---

## Caso de Uso 2: Modificación de un registro existente

**Descripción:** El usuario necesita actualizar las iniciales del usuario que elabora el convenio.

**Precondiciones:**
Existe al menos un registro en la tabla.

**Pasos a seguir:**
1. El usuario localiza el registro a modificar en la tabla.
2. Hace clic en 'Editar'.
3. Cambia el campo 'Iniciales Elabora'.
4. Hace clic en 'Guardar'.
5. El sistema actualiza el registro.

**Resultado esperado:**
El registro muestra las nuevas iniciales en la columna correspondiente.

**Datos de prueba:**
{
  "id_control": 5,
  "id_rec": 2,
  "id_usu_titular": 101,
  "iniciales_titular": "JSM",
  "id_usu_elaboro": 102,
  "iniciales_elaboro": "LPR2"
}

---

## Caso de Uso 3: Eliminación de un registro

**Descripción:** El usuario elimina un registro de responsable de elaboración de convenio.

**Precondiciones:**
Existe al menos un registro en la tabla.

**Pasos a seguir:**
1. El usuario localiza el registro a eliminar en la tabla.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.
4. El sistema elimina el registro.

**Resultado esperado:**
El registro desaparece de la tabla.

**Datos de prueba:**
{
  "id_control": 5
}

---

