# Casos de Uso - consultausuariosfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de usuario por nombre de usuario exacto

**Descripción:** El usuario desea buscar información de un usuario específico ingresando su nombre de usuario exacto.

**Precondiciones:**
El usuario conoce el nombre de usuario exacto y existe en la base de datos.

**Pasos a seguir:**
1. Navegar a la página 'Consulta por Usuario'.
2. Ingresar el nombre de usuario (por ejemplo, 'jdoe') en el campo correspondiente.
3. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con la información del usuario 'jdoe', incluyendo dependencia, departamento, teléfono, fechas y vigencia.

**Datos de prueba:**
usuario: 'jdoe'

---

## Caso de Uso 2: Consulta de usuarios por prefijo de nombre

**Descripción:** El usuario desea buscar todos los usuarios cuyo nombre inicia con un texto dado.

**Precondiciones:**
Existen usuarios cuyos nombres inician con el texto proporcionado.

**Pasos a seguir:**
1. Navegar a la página 'Consulta por Nombre'.
2. Ingresar el prefijo del nombre (por ejemplo, 'JUAN') en el campo correspondiente.
3. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los usuarios cuyos nombres inician con 'JUAN'.

**Datos de prueba:**
nombre: 'JUAN'

---

## Caso de Uso 3: Consulta de usuarios por dependencia y departamento

**Descripción:** El usuario desea buscar todos los usuarios de un departamento específico dentro de una dependencia.

**Precondiciones:**
Existen dependencias y departamentos registrados en la base de datos.

**Pasos a seguir:**
1. Navegar a la página 'Consulta por Departamento'.
2. Seleccionar una dependencia de la lista desplegable.
3. Seleccionar un departamento de la lista desplegable.
4. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los usuarios del departamento seleccionado.

**Datos de prueba:**
id_dependencia: 2, cvedepto: 5

---

