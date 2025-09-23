# Casos de Uso - ConsultaSAndres

**Categoría:** Form

## Caso de Uso 1: Consulta completa de registros de Cementerio San Andrés

**Descripción:** El usuario accede a la página de consulta y visualiza todos los registros disponibles en la base de datos de San Andrés.

**Precondiciones:**
El usuario tiene acceso a la aplicación y la base de datos contiene registros.

**Pasos a seguir:**
1. El usuario navega a la ruta '/consulta-sandres'.
2. El componente Vue realiza una petición POST a '/api/execute' con acción 'consultar_sanandres_paginated'.
3. El backend ejecuta el stored procedure y devuelve los primeros 20 registros.
4. El usuario visualiza la tabla con los datos.

**Resultado esperado:**
Se muestra una tabla con los primeros 20 registros de la base de datos de San Andrés.

**Datos de prueba:**
Base de datos con al menos 25 registros en la tabla 'datos'.

---

## Caso de Uso 2: Navegación por páginas de resultados

**Descripción:** El usuario navega entre páginas de resultados usando la paginación.

**Precondiciones:**
El usuario está en la página de consulta y hay más de 20 registros.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Siguiente' de la paginación.
2. El componente Vue envía una petición con 'page': 2.
3. El backend devuelve los registros correspondientes a la página 2.
4. El usuario visualiza la nueva página de resultados.

**Resultado esperado:**
La tabla muestra los registros de la página seleccionada.

**Datos de prueba:**
Base de datos con 45 registros en la tabla 'datos'.

---

## Caso de Uso 3: Manejo de error de conexión a la base de datos

**Descripción:** El usuario intenta consultar los registros pero la base de datos está caída.

**Precondiciones:**
La base de datos PostgreSQL está detenida o inaccesible.

**Pasos a seguir:**
1. El usuario accede a la página de consulta.
2. El componente Vue realiza la petición al backend.
3. El backend intenta ejecutar el stored procedure y falla.
4. El backend responde con success: false y un mensaje de error.
5. El frontend muestra el mensaje de error.

**Resultado esperado:**
El usuario ve un mensaje de error indicando que no se pudo consultar la base de datos.

**Datos de prueba:**
Base de datos detenida o credenciales incorrectas.

---

