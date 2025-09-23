# Casos de Uso - gruposAnunciosfrm

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo grupo de anuncios y asociar anuncios

**Descripción:** El usuario crea un nuevo grupo de anuncios y agrega anuncios disponibles al grupo.

**Precondiciones:**
El usuario tiene acceso a la página de Grupos de Anuncios.

**Pasos a seguir:**
1. El usuario ingresa la descripción del nuevo grupo y hace clic en 'Agregar Grupo'.
2. El grupo aparece en la lista.
3. El usuario selecciona el grupo recién creado.
4. El usuario filtra los anuncios disponibles por giro o propietario.
5. El usuario selecciona varios anuncios y hace clic en 'Agregar a Grupo'.

**Resultado esperado:**
El grupo se crea y los anuncios seleccionados quedan asociados al grupo. Los anuncios ya no aparecen en la lista de disponibles.

**Datos de prueba:**
Descripción del grupo: 'GRUPO PRUEBA 1'. Anuncios a asociar: [1001, 1002, 1003].

---

## Caso de Uso 2: Quitar anuncios de un grupo existente

**Descripción:** El usuario elimina anuncios de un grupo de anuncios existente.

**Precondiciones:**
Existe al menos un grupo con anuncios asociados.

**Pasos a seguir:**
1. El usuario selecciona un grupo existente.
2. El usuario filtra los anuncios en el grupo si lo desea.
3. El usuario selecciona uno o más anuncios y hace clic en 'Quitar de Grupo'.

**Resultado esperado:**
Los anuncios seleccionados se eliminan del grupo y aparecen nuevamente en la lista de anuncios disponibles.

**Datos de prueba:**
Grupo: 'GRUPO PRUEBA 1'. Anuncios a quitar: [1002].

---

## Caso de Uso 3: Editar la descripción de un grupo de anuncios

**Descripción:** El usuario edita la descripción de un grupo de anuncios.

**Precondiciones:**
Existe al menos un grupo de anuncios.

**Pasos a seguir:**
1. El usuario hace clic en 'Editar' en el grupo deseado.
2. El usuario modifica la descripción y guarda los cambios.

**Resultado esperado:**
La descripción del grupo se actualiza correctamente en la base de datos y en la interfaz.

**Datos de prueba:**
Grupo original: 'GRUPO PRUEBA 1'. Nueva descripción: 'GRUPO PRUEBA EDITADO'.

---

