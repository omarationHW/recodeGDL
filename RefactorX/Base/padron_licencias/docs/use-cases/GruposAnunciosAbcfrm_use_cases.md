# Casos de Uso - GruposAnunciosAbcfrm

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo grupo de anuncio

**Descripción:** El usuario desea crear un nuevo grupo de anuncio con la descripción 'PUBLICIDAD EXTERIOR'.

**Precondiciones:**
El usuario tiene acceso a la página de Grupos de Anuncios y permisos de escritura.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Agregar'.
2. Se muestra el formulario de alta.
3. El usuario ingresa 'PUBLICIDAD EXTERIOR' en el campo Descripción.
4. El usuario hace clic en 'Aceptar'.
5. El sistema envía la petición eRequest 'anuncios_grupos_insert' al endpoint.
6. El backend inserta el registro y retorna el nuevo grupo.

**Resultado esperado:**
El grupo se agrega a la lista, se muestra un mensaje de éxito y el formulario se limpia.

**Datos de prueba:**
{ "descripcion": "PUBLICIDAD EXTERIOR" }

---

## Caso de Uso 2: Modificar la descripción de un grupo existente

**Descripción:** El usuario desea cambiar la descripción del grupo con id=3 a 'ANUNCIOS DIGITALES'.

**Precondiciones:**
Existe un grupo con id=3. El usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario localiza el grupo con id=3 en la lista.
2. Hace clic en 'Modificar'.
3. Cambia la descripción a 'ANUNCIOS DIGITALES'.
4. Hace clic en 'Aceptar'.
5. El sistema envía eRequest 'anuncios_grupos_update' con los datos.

**Resultado esperado:**
La descripción del grupo se actualiza y se muestra mensaje de éxito.

**Datos de prueba:**
{ "id": 3, "descripcion": "ANUNCIOS DIGITALES" }

---

## Caso de Uso 3: Buscar grupos de anuncios por descripción parcial

**Descripción:** El usuario desea filtrar la lista de grupos para ver sólo aquellos que contienen la palabra 'EXTERIOR'.

**Precondiciones:**
Existen varios grupos de anuncios en la base de datos.

**Pasos a seguir:**
1. El usuario escribe 'EXTERIOR' en el campo de búsqueda.
2. El sistema envía eRequest 'anuncios_grupos_list' con el parámetro de filtro.
3. Se actualiza la tabla con los resultados filtrados.

**Resultado esperado:**
Sólo se muestran los grupos cuya descripción contiene 'EXTERIOR'.

**Datos de prueba:**
{ "descripcion": "EXTERIOR" }

---

