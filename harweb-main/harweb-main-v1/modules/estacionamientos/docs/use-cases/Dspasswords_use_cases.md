# Casos de Uso - Dspasswords

**Categoría:** Form

## Caso de Uso 1: Consulta de passwords por usuario

**Descripción:** Un administrador desea consultar los registros de passwords asociados a un usuario específico.

**Precondiciones:**
El usuario debe existir en la tabla ta_12_passwords.

**Pasos a seguir:**
1. Ingresar el nombre de usuario en el campo de búsqueda.
2. Presionar el botón 'Buscar'.
3. El sistema muestra la lista de passwords asociados a ese usuario.

**Resultado esperado:**
Se muestran todos los registros de passwords del usuario especificado.

**Datos de prueba:**
{ "usuario": "admin" }

---

## Caso de Uso 2: Alta de un nuevo password

**Descripción:** Un operador necesita registrar un nuevo usuario con su password y nivel de acceso.

**Precondiciones:**
El usuario a registrar no debe existir previamente.

**Pasos a seguir:**
1. Hacer clic en 'Nuevo'.
2. Completar los campos requeridos (usuario, nombre, estado, id_rec, nivel).
3. Presionar 'Guardar'.

**Resultado esperado:**
El nuevo registro se almacena y aparece en la lista.

**Datos de prueba:**
{ "usuario": "jdoe", "nombre": "John Doe", "estado": "A", "id_rec": 1, "nivel": 2 }

---

## Caso de Uso 3: Eliminación de un registro de password

**Descripción:** Un administrador elimina un registro de password que ya no es necesario.

**Precondiciones:**
El registro debe existir en la base de datos.

**Pasos a seguir:**
1. Buscar el registro por usuario o ID.
2. Hacer clic en 'Eliminar'.
3. Confirmar la eliminación.

**Resultado esperado:**
El registro es eliminado y ya no aparece en la lista.

**Datos de prueba:**
{ "id_usuario": 5 }

---

