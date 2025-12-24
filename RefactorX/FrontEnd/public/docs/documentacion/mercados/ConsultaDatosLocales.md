# ConsultaDatosLocales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica - ConsultaDatosLocales

## Descripción General
Este módulo permite consultar los datos generales de los locales comerciales registrados en el sistema. Permite filtrar por criterios como recaudadora, mercado, sección, local, letra, bloque o buscar por nombre. Además, permite consultar el detalle individual de un local.

## Arquitectura
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación y búsqueda.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato**: `{ action: 'nombreAccion', params: { ... } }`
- **Acciones soportadas**:
  - `getCatalogos`: Devuelve recaudadoras y secciones
  - `getMercadosPorOficina`: Devuelve mercados de una recaudadora
  - `buscarLocales`: Busca locales por filtros
  - `buscarPorNombre`: Busca locales por nombre
  - `getLocalIndividual`: Devuelve detalle de un local

## Stored Procedures
- Todos los queries están encapsulados en funciones PostgreSQL.
- Los procedimientos devuelven tablas (TABLE) para fácil consumo desde Laravel.

## Seguridad
- Validación de parámetros en el backend.
- Sanitización de entradas en el frontend.
- El endpoint puede ser protegido por middleware de autenticación Laravel.

## Flujo de Uso
1. El usuario accede a la página de consulta.
2. Selecciona "Local" o "Nombre" como criterio de búsqueda.
3. Si elige "Local", selecciona recaudadora, mercado, sección, etc.
4. Si elige "Nombre", ingresa el nombre o parte del nombre.
5. Al hacer clic en "Buscar", se envía la petición al endpoint unificado.
6. Se muestran los resultados en una tabla.
7. Puede consultar el detalle individual de un local.

## Consideraciones
- El frontend es completamente independiente y funcional como página.
- No se usan tabs ni componentes tabulares.
- El backend es desacoplado y puede ser reutilizado por otros clientes.

## Extensibilidad
- Se pueden agregar más filtros o columnas fácilmente.
- El endpoint puede crecer para soportar más acciones.

## Ejemplo de eRequest
```json
{
  "action": "buscarLocales",
  "params": {
    "oficina": 1,
    "num_mercado": 12,
    "categoria": 2,
    "seccion": "A",
    "local": 101,
    "letra_local": "B",
    "bloque": "C"
  }
}
```

## Ejemplo de eResponse
```json
{
  "success": true,
  "data": [
    { "id_local": 123, "oficina": 1, ... }
  ]
}
```


## Casos de Uso

# Casos de Uso - ConsultaDatosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Locales por Filtros

**Descripción:** El usuario desea buscar todos los locales de la recaudadora 1, mercado 12, sección 'A', local 101.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en la base.

**Pasos a seguir:**
1. Accede a la página de Consulta de Datos Locales.
2. Selecciona la opción 'Local'.
3. Selecciona recaudadora 1, mercado 12, sección 'A', local 101.
4. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los locales que cumplen los filtros.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 12, "categoria": null, "seccion": "A", "local": 101, "letra_local": null, "bloque": null }

---

## Caso de Uso 2: Consulta de Locales por Nombre

**Descripción:** El usuario busca todos los locales cuyo nombre comienza con 'JUAN'.

**Precondiciones:**
El usuario tiene acceso y existen locales con nombre 'JUAN'.

**Pasos a seguir:**
1. Accede a la página de Consulta de Datos Locales.
2. Selecciona la opción 'Nombre'.
3. Escribe 'JUAN' en el campo nombre.
4. Presiona 'Buscar'.

**Resultado esperado:**
Se listan todos los locales cuyo nombre inicia con 'JUAN'.

**Datos de prueba:**
{ "nombre": "JUAN" }

---

## Caso de Uso 3: Consulta Individual de Local

**Descripción:** El usuario quiere ver el detalle de un local específico.

**Precondiciones:**
El usuario ya realizó una búsqueda y tiene el id_local.

**Pasos a seguir:**
1. En la tabla de resultados, hace clic en 'Ver' en el local deseado.

**Resultado esperado:**
Se muestra el detalle completo del local seleccionado.

**Datos de prueba:**
{ "id_local": 123 }

---



## Casos de Prueba

# Casos de Prueba - ConsultaDatosLocales

## Caso 1: Búsqueda por filtros completos
- **Entrada**: oficina=1, num_mercado=12, categoria=2, seccion='A', local=101, letra_local='B', bloque='C'
- **Acción**: POST /api/execute { action: 'buscarLocales', params: {...} }
- **Resultado esperado**: Lista de locales que cumplen exactamente esos filtros.

## Caso 2: Búsqueda por nombre parcial
- **Entrada**: nombre='JUAN'
- **Acción**: POST /api/execute { action: 'buscarPorNombre', params: { nombre: 'JUAN' } }
- **Resultado esperado**: Lista de locales cuyo nombre inicia con 'JUAN'.

## Caso 3: Consulta individual
- **Entrada**: id_local=123
- **Acción**: POST /api/execute { action: 'getLocalIndividual', params: { id_local: 123 } }
- **Resultado esperado**: Objeto con todos los datos del local 123.

## Caso 4: Catálogos
- **Entrada**: action: 'getCatalogos'
- **Acción**: POST /api/execute { action: 'getCatalogos' }
- **Resultado esperado**: Listado de recaudadoras y secciones.

## Caso 5: Mercados por oficina
- **Entrada**: oficina=1
- **Acción**: POST /api/execute { action: 'getMercadosPorOficina', params: { oficina: 1 } }
- **Resultado esperado**: Lista de mercados de la oficina 1.



