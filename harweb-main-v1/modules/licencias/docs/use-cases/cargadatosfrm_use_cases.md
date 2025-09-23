# Casos de Uso - cargadatosfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de datos catastrales por clave

**Descripción:** El usuario ingresa una clave catastral y obtiene toda la información de ubicación, propietario, avalúos, construcciones y área cartográfica.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce una clave catastral válida.

**Pasos a seguir:**
1. El usuario accede a la página /cargadatos.
2. Ingresa la clave catastral en el formulario.
3. Presiona 'Buscar'.
4. El sistema consulta el backend vía /api/execute con action 'getCargadatos'.
5. El backend retorna los datos principales.
6. El frontend muestra la información y consulta los avalúos, construcciones y área cartográfica.

**Resultado esperado:**
Se muestra toda la información relacionada a la clave catastral, incluyendo avalúos y construcciones.

**Datos de prueba:**
{ "cvecatnva": "D65J1345001" }

---

## Caso de Uso 2: Consulta de avalúos y construcciones

**Descripción:** El usuario, tras consultar una clave catastral, navega a la sección de avalúos y visualiza los detalles y construcciones asociadas.

**Precondiciones:**
El usuario ya realizó una consulta de clave catastral válida.

**Pasos a seguir:**
1. El usuario visualiza la sección de avalúos.
2. El sistema consulta /api/execute con action 'getAvaluos'.
3. El usuario selecciona un avalúo y el sistema consulta /api/execute con action 'getConstrucciones'.

**Resultado esperado:**
Se muestran los avalúos y las construcciones asociadas al avalúo seleccionado.

**Datos de prueba:**
{ "cvecatnva": "D65J1345001", "subpredio": 0 }

---

## Caso de Uso 3: Actualización de datos principales de la cuenta

**Descripción:** El usuario actualiza los datos del propietario y domicilio de una cuenta catastral.

**Precondiciones:**
El usuario tiene permisos de edición y una clave catastral válida.

**Pasos a seguir:**
1. El usuario accede a la página de edición de datos.
2. Modifica los campos requeridos.
3. Presiona 'Guardar'.
4. El frontend envía los datos a /api/execute con action 'saveCargadatos'.
5. El backend actualiza los datos y retorna confirmación.

**Resultado esperado:**
Los datos de la cuenta se actualizan correctamente en la base de datos.

**Datos de prueba:**
{ "cvecatnva": "D65J1345001", "nombre_completo": "Juan Pérez", "rfc": "PEPJ800101XXX", ... }

---

