# Casos de Uso - ModuloBD

**Categoría:** Form

## Caso de Uso 1: Agregar una nueva Categoría

**Descripción:** El usuario desea agregar una nueva categoría al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Categorías.
2. Hace clic en 'Agregar Categoría'.
3. Ingresa la descripción 'Especial'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La nueva categoría aparece en la lista con la descripción 'ESPECIAL'.

**Datos de prueba:**
{ "descripcion": "Especial" }

---

## Caso de Uso 2: Editar una Categoría existente

**Descripción:** El usuario desea modificar la descripción de una categoría.

**Precondiciones:**
Existe una categoría con ID 2 y el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario accede a la página de Categorías.
2. Hace clic en 'Editar' en la fila de la categoría con ID 2.
3. Cambia la descripción a 'Comercial'.
4. Hace clic en 'Actualizar'.

**Resultado esperado:**
La categoría con ID 2 muestra la descripción 'COMERCIAL'.

**Datos de prueba:**
{ "categoria": 2, "descripcion": "Comercial" }

---

## Caso de Uso 3: Listar todas las Categorías

**Descripción:** El usuario desea ver el listado completo de categorías.

**Precondiciones:**
Existen al menos 3 categorías en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Categorías.
2. El sistema muestra la tabla con todas las categorías.

**Resultado esperado:**
Se muestran todas las categorías existentes.

**Datos de prueba:**
N/A

---

