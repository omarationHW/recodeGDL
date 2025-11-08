# Casos de Uso - privilegios

**Categoría:** Form

## Caso de Uso 1: Consulta de usuarios con privilegios

**Descripción:** El usuario administrador desea ver la lista de todos los usuarios con privilegios, filtrando por nombre.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Acceder a la página de Privilegios.
2. Ingresar un texto en el campo de búsqueda (por ejemplo, 'juan').
3. Visualizar la tabla de usuarios filtrada.

**Resultado esperado:**
Se muestra la lista de usuarios cuyo nombre o usuario contiene 'juan'.

**Datos de prueba:**
Filtro: 'juan'

---

## Caso de Uso 2: Consulta de permisos y auditoría de un usuario

**Descripción:** El usuario selecciona un usuario específico para ver sus permisos actuales y la bitácora de auditoría.

**Precondiciones:**
El usuario está autenticado y la tabla de usuarios está cargada.

**Pasos a seguir:**
1. Hacer clic en un usuario de la tabla.
2. Visualizar la tabla de permisos actuales.
3. Visualizar la tabla de auditoría de permisos.

**Resultado esperado:**
Se muestran correctamente los permisos y la bitácora del usuario seleccionado.

**Datos de prueba:**
Usuario: 'jlopez'

---

## Caso de Uso 3: Paginación de usuarios

**Descripción:** El usuario navega entre páginas de la lista de usuarios.

**Precondiciones:**
Existen más de 20 usuarios con privilegios.

**Pasos a seguir:**
1. Acceder a la página de Privilegios.
2. Cambiar a la página 2 de la tabla de usuarios.

**Resultado esperado:**
Se muestran los usuarios correspondientes a la página 2.

**Datos de prueba:**
page: 2, perPage: 20

---

