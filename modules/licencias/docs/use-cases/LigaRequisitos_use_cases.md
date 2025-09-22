# Casos de Uso - LigaRequisitos

**Categoría:** Form

## Caso de Uso 1: Agregar un requisito a un giro

**Descripción:** El usuario desea asignar un nuevo requisito/documento a un giro comercial específico.

**Precondiciones:**
El usuario tiene permisos de edición y el requisito no está ya ligado al giro.

**Pasos a seguir:**
1. El usuario accede a la página de Liga de Requisitos a Giros.
2. Busca y selecciona el giro deseado.
3. En la lista de requisitos disponibles, localiza el requisito a agregar.
4. Da clic en 'Agregar'.
5. El sistema envía la petición a la API.
6. El backend ejecuta el stored procedure de alta.
7. El frontend actualiza ambas listas.

**Resultado esperado:**
El requisito aparece en la lista de requisitos ligados y desaparece de la lista de disponibles. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "id_giro": 1201, "req": 7 }

---

## Caso de Uso 2: Quitar un requisito de un giro

**Descripción:** El usuario necesita eliminar un requisito previamente asignado a un giro.

**Precondiciones:**
El requisito está actualmente ligado al giro.

**Pasos a seguir:**
1. El usuario selecciona el giro.
2. En la lista de requisitos ligados, localiza el requisito a quitar.
3. Da clic en 'Quitar'.
4. El sistema envía la petición a la API.
5. El backend ejecuta el stored procedure de baja.
6. El frontend actualiza ambas listas.

**Resultado esperado:**
El requisito desaparece de la lista de ligados y aparece en la lista de disponibles. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "id_giro": 1201, "req": 7 }

---

## Caso de Uso 3: Buscar giros y requisitos por descripción

**Descripción:** El usuario quiere filtrar la lista de giros o requisitos por texto.

**Precondiciones:**
Existen giros y requisitos en el catálogo.

**Pasos a seguir:**
1. El usuario escribe parte de la descripción en el campo de búsqueda.
2. El sistema filtra la lista en tiempo real usando la API.

**Resultado esperado:**
Solo se muestran los registros que coinciden con el texto buscado.

**Datos de prueba:**
{ "descripcion": "ALIMENTOS" }

---

