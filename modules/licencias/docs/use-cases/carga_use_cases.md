# Casos de Uso - carga

**Categoría:** Form

## Caso de Uso 1: Consulta de Predio por Clave Catastral

**Descripción:** El usuario ingresa la clave catastral y subpredio para consultar los datos completos del predio.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce la clave catastral.

**Pasos a seguir:**
1. El usuario accede a la página de Cartografía Predial.
2. Ingresa la clave catastral y subpredio.
3. Presiona 'Buscar'.
4. El sistema envía la petición a /api/execute con action 'getPredioByClaveCatastral'.
5. El backend ejecuta el SP y devuelve los datos del predio.
6. El frontend muestra los datos en pantalla.

**Resultado esperado:**
Se muestran todos los datos del predio consultado.

**Datos de prueba:**
{ "cvecatnva": "A1234567", "subpredio": 0 }

---

## Caso de Uso 2: Visualización de Cartografía Predial

**Descripción:** El usuario, tras consultar un predio, solicita ver la cartografía asociada.

**Precondiciones:**
El usuario ya consultó un predio y tiene la clave catastral.

**Pasos a seguir:**
1. El usuario hace clic en 'Ver Cartografía'.
2. El sistema envía la petición a /api/execute con action 'getCartografia'.
3. El backend ejecuta el SP y devuelve la información cartográfica (simulada).
4. El frontend muestra la cartografía (en JSON o integración GIS real).

**Resultado esperado:**
Se muestra la información cartográfica asociada al predio.

**Datos de prueba:**
{ "cvecatnva": "A1234567" }

---

## Caso de Uso 3: Consulta de Números Oficiales de una Manzana

**Descripción:** El usuario consulta los números oficiales asociados a la manzana del predio.

**Precondiciones:**
El usuario ya consultó un predio y tiene la clave catastral.

**Pasos a seguir:**
1. El usuario hace clic en 'Números Oficiales'.
2. El sistema envía la petición a /api/execute con action 'getNumerosOficiales'.
3. El backend ejecuta el SP y devuelve los números oficiales.
4. El frontend muestra la lista de números oficiales.

**Resultado esperado:**
Se muestran los números oficiales de la manzana.

**Datos de prueba:**
{ "cvemanz": "A1234567" }

---

