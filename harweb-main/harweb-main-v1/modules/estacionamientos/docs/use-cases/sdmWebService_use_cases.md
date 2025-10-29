# Casos de Uso - sdmWebService

**Categoría:** Form

## Caso de Uso 1: Consulta exitosa de predio existente

**Descripción:** El usuario consulta un predio existente proporcionando un ID predial y opción válidos.

**Precondiciones:**
El WebService SOAP está disponible y responde correctamente. El ID predial existe.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Predio.
2. Ingresa un ID predial válido (ej: '123456') y una opción válida (ej: '1').
3. Presiona el botón 'Consultar'.
4. El sistema envía la petición al endpoint /api/execute.
5. El backend consume el WebService, procesa la respuesta y almacena los datos.
6. El frontend muestra la información del predio en la tabla de resultados.

**Resultado esperado:**
La información del predio consultado se muestra correctamente en la tabla.

**Datos de prueba:**
{ "s_idpredial": "123456", "s_opcion": "1" }

---

## Caso de Uso 2: Consulta con ID predial inexistente

**Descripción:** El usuario consulta un predio con un ID predial que no existe en el sistema.

**Precondiciones:**
El WebService SOAP está disponible. El ID predial no existe.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Predio.
2. Ingresa un ID predial inexistente (ej: '999999') y una opción válida (ej: '1').
3. Presiona el botón 'Consultar'.
4. El sistema envía la petición al endpoint /api/execute.
5. El backend consume el WebService, procesa la respuesta (vacía o con mensaje de error).

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontró información para el predio.

**Datos de prueba:**
{ "s_idpredial": "999999", "s_opcion": "1" }

---

## Caso de Uso 3: Error de validación por campos vacíos

**Descripción:** El usuario intenta consultar sin ingresar todos los campos requeridos.

**Precondiciones:**
El usuario accede a la página de Consulta de Predio.

**Pasos a seguir:**
1. El usuario deja vacío el campo ID predial o la opción.
2. Presiona el botón 'Consultar'.
3. El frontend o backend valida los campos y rechaza la petición.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los campos son obligatorios.

**Datos de prueba:**
{ "s_idpredial": "", "s_opcion": "" }

---

