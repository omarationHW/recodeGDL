# Casos de Uso - Busca

**Categoría:** Form

## Caso de Uso 1: Búsqueda de Convenio por Nombre

**Descripción:** El usuario desea buscar convenios por el nombre del contribuyente.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Convenios.
2. Selecciona 'Por Nombre' en el tipo de búsqueda.
3. Ingresa 'JUAN PEREZ' en el campo Nombre.
4. Presiona el botón 'Buscar'.
5. El sistema envía eRequest con action 'searchByNombre' y params { nombre: 'JUAN PEREZ' }.
6. El backend ejecuta el SP correspondiente y devuelve los resultados.

**Resultado esperado:**
Se muestra una tabla con los convenios cuyo nombre contiene 'JUAN PEREZ'.

**Datos de prueba:**
{ "nombre": "JUAN PEREZ" }

---

## Caso de Uso 2: Búsqueda de Convenio por Domicilio

**Descripción:** El usuario busca convenios por domicilio (calle y número exterior).

**Precondiciones:**
El usuario tiene acceso y permisos.

**Pasos a seguir:**
1. Accede a la página de Consulta Convenios.
2. Selecciona 'Por Domicilio'.
3. Ingresa 'AV. INDEPENDENCIA' en Calle y '123' en Número Exterior.
4. Presiona 'Buscar'.
5. El sistema envía eRequest con action 'searchByDomicilio' y params { calle: 'AV. INDEPENDENCIA', num_exterior: 123 }.

**Resultado esperado:**
Se muestran los convenios que coinciden con la calle y número exterior.

**Datos de prueba:**
{ "calle": "AV. INDEPENDENCIA", "num_exterior": 123 }

---

## Caso de Uso 3: Búsqueda de Convenio por Licencia de Giro

**Descripción:** El usuario busca convenios por número de licencia de giro.

**Precondiciones:**
El usuario tiene acceso y permisos.

**Pasos a seguir:**
1. Accede a la página de Consulta Convenios.
2. Selecciona 'Por Licencia de Giro'.
3. Ingresa '456789' en el campo Licencia.
4. Presiona 'Buscar'.
5. El sistema envía eRequest con action 'searchByLicencia' y params { licencia: 456789 }.

**Resultado esperado:**
Se muestran los convenios asociados a la licencia 456789.

**Datos de prueba:**
{ "licencia": 456789 }

---

