# Casos de Uso - TiposMntto

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Tipo

**Descripción:** El usuario desea agregar un nuevo tipo al catálogo.

**Precondiciones:**
El usuario tiene acceso a la página de TiposMntto.

**Pasos a seguir:**
1. El usuario ingresa el número de tipo (ej: 5) y la descripción (ej: 'TIPO DE PRUEBA').
2. Presiona el botón 'Agregar'.
3. El sistema envía un eRequest con action 'create' y los datos.
4. El backend ejecuta el stored procedure de inserción.
5. El frontend muestra mensaje de éxito y refresca la tabla.

**Resultado esperado:**
El nuevo tipo aparece en la tabla y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "tipo": 5, "descripcion": "TIPO DE PRUEBA" }

---

## Caso de Uso 2: Modificación de un Tipo existente

**Descripción:** El usuario desea modificar la descripción de un tipo existente.

**Precondiciones:**
Existe un tipo con clave 5.

**Pasos a seguir:**
1. El usuario localiza el tipo 5 en la tabla y presiona 'Editar'.
2. Cambia la descripción a 'TIPO MODIFICADO'.
3. Presiona 'Actualizar'.
4. El sistema envía un eRequest con action 'update' y los datos.
5. El backend ejecuta el stored procedure de actualización.
6. El frontend muestra mensaje de éxito y refresca la tabla.

**Resultado esperado:**
La descripción del tipo 5 se actualiza y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "tipo": 5, "descripcion": "TIPO MODIFICADO" }

---

## Caso de Uso 3: Consulta de todos los Tipos

**Descripción:** El usuario desea ver el listado completo de tipos.

**Precondiciones:**
Existen registros en el catálogo de tipos.

**Pasos a seguir:**
1. El usuario accede a la página de TiposMntto.
2. El frontend ejecuta fetchTipos() al montar la página.
3. El backend ejecuta el stored procedure de listado.
4. El frontend muestra la tabla con todos los tipos.

**Resultado esperado:**
Se muestra la tabla con todos los tipos existentes.

**Datos de prueba:**
{}

---

