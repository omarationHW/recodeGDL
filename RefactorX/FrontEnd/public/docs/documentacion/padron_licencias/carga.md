# Documentación Técnica: carga

## Análisis Técnico

# Documentación Técnica: Migración Formulario Cartografía Predial (carga.pas) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8.1+), PostgreSQL 13+
- **Frontend:** Vue.js 3 (SPA, router, axios)
- **API:** Unificada, endpoint único `/api/execute` (POST), patrón eRequest/eResponse
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures
- **Cartografía:** La integración GIS se simula vía JSON (en producción, se recomienda microservicio GIS)

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "nombre_accion",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```
- **Acciones soportadas:**
  - `getPredioByClaveCatastral`
  - `getPredioByCuenta`
  - `getCartografia`
  - `getNumerosOficiales`
  - `getCondominio`
  - `getAvaluo`
  - `getConstrucciones`

## 3. Controlador Laravel
- Un solo método `execute(Request $request)`
- Valida acción y parámetros
- Llama al stored procedure correspondiente vía DB::select
- Devuelve resultado en `eResponse` o error

## 4. Componente Vue.js
- Página independiente (NO tabs)
- Formulario para buscar predio por clave catastral/subpredio
- Muestra datos del predio y botones para consultar cartografía, números oficiales, condominio
- Cada consulta llama a `/api/execute` con la acción y parámetros adecuados
- Manejo de errores y estados
- Filtros para formato de moneda

## 5. Stored Procedures PostgreSQL
- Cada consulta relevante encapsulada en una función SQL
- Todas devuelven TABLE o JSON según el caso
- Nombres: `get_predio_by_clave_catastral`, `get_predio_by_cuenta`, etc.
- Simulación de cartografía (en producción, integrar GIS real)

## 6. Seguridad
- Se recomienda proteger `/api/execute` con autenticación JWT o session
- Validar parámetros en backend

## 7. Extensibilidad
- Para agregar nuevas acciones, crear el SP y añadir el case en el controlador
- El frontend puede extenderse con nuevos botones/vistas

## 8. Integración GIS
- Actualmente simulado
- Para producción, se recomienda microservicio GIS (GeoServer, PostGIS, etc.) y consumir vía REST

## 9. Pruebas
- Casos de uso y pruebas incluidas abajo

# Notas de Migración
- El formulario Delphi usaba componentes visuales y lógica de eventos; en Vue.js se traduce a métodos y estados reactivos
- La lógica de acceso a archivos shape/cartografía se simula; en producción debe integrarse con GIS real
- El acceso a la base de datos se realiza exclusivamente vía stored procedures
- El endpoint es único y desacoplado de la UI

## Casos de Prueba

# Casos de Prueba para Formulario Cartografía Predial

## Caso 1: Consulta exitosa de predio por clave catastral
- **Entrada:** cvecatnva = 'A1234567', subpredio = 0
- **Acción:** getPredioByClaveCatastral
- **Esperado:** Devuelve datos completos del predio (cuenta, propietario, ubicación, valores, etc.)

## Caso 2: Consulta de predio inexistente
- **Entrada:** cvecatnva = 'ZZZZZZZZ', subpredio = 0
- **Acción:** getPredioByClaveCatastral
- **Esperado:** eResponse.error indica 'No se encontró el predio.'

## Caso 3: Consulta de cartografía predial
- **Entrada:** cvecatnva = 'A1234567'
- **Acción:** getCartografia
- **Esperado:** Devuelve JSON con layers ['predios', 'construcciones', 'calles', 'numeros_oficiales'] y status 'ok'

## Caso 4: Consulta de números oficiales
- **Entrada:** cvemanz = 'A1234567'
- **Acción:** getNumerosOficiales
- **Esperado:** Devuelve lista de números oficiales asociados a la manzana

## Caso 5: Consulta de condominio
- **Entrada:** cvecatnva = 'A1234567'
- **Acción:** getCondominio
- **Esperado:** Devuelve datos del condominio si existe, o lista vacía si no existe

## Caso 6: Consulta de avalúo
- **Entrada:** cvecatnva = 'A1234567'
- **Acción:** getAvaluo
- **Esperado:** Devuelve datos de avalúo (superficie, valores, etc.)

## Caso 7: Consulta de construcciones
- **Entrada:** cvecatnva = 'A1234567'
- **Acción:** getConstrucciones
- **Esperado:** Devuelve lista de construcciones asociadas al predio

## Casos de Uso

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

