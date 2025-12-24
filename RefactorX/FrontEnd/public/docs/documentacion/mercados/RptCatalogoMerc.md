# RptCatalogoMerc

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Catálogo de Mercados Municipales

## Descripción General
Este módulo permite la gestión completa del catálogo de mercados municipales, incluyendo alta, edición, eliminación, consulta y generación de reportes PDF. La solución está compuesta por:

- **Backend Laravel**: Un controlador con endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend Vue.js**: Página independiente para la administración del catálogo.
- **Stored Procedures PostgreSQL**: Toda la lógica de acceso y manipulación de datos se realiza mediante SPs.
- **API Unificada**: Todas las operaciones se realizan mediante el endpoint `/api/execute`.

## Arquitectura

- **API**: `/api/execute` (POST)
  - Recibe `{ action: string, params: object }`
  - Devuelve `{ success: bool, data: any, message: string }`
- **Acciones soportadas**:
  - `getCatalogoMercados`: Listado de mercados
  - `createCatalogoMercado`: Alta
  - `updateCatalogoMercado`: Edición
  - `deleteCatalogoMercado`: Eliminación
  - `getCatalogoMercadosReporte`: Generación de PDF

## Flujo de Datos
1. El usuario navega a la página de Catálogo de Mercados.
2. Vue.js solicita el listado vía `/api/execute` con `action: getCatalogoMercados`.
3. El backend ejecuta el SP correspondiente y retorna los datos.
4. Para crear/editar/eliminar, Vue.js envía los datos del formulario y la acción correspondiente.
5. Para reporte, Vue.js solicita la generación y obtiene la URL del PDF.

## Seguridad
- Todas las operaciones requieren autenticación (no incluida aquí, pero debe integrarse con Laravel Auth).
- Los SPs validan los parámetros y sólo permiten operaciones válidas.

## Integración de Reportes
- El SP `sp_reporte_catalogo_mercados` debe integrarse con una función de generación de PDF (puede ser una extensión en PostgreSQL, un microservicio, o lógica en Laravel que consuma los datos y genere el PDF).

## Consideraciones
- El frontend es una página independiente, sin tabs ni componentes tabulares.
- El endpoint `/api/execute` es único para todas las operaciones.
- El patrón eRequest/eResponse permite fácil integración con otros módulos.

## Estructura de la Tabla `ta_11_mercados`
- oficina (smallint)
- num_mercado_nvo (smallint)
- categoria (smallint)
- descripcion (varchar)
- cuenta_ingreso (integer)
- cuenta_energia (integer)
- id_zona (smallint)
- tipo_emision (varchar)
- id_usuario (integer)
- fecha_alta (timestamp)
- fecha_modificacion (timestamp)

## Ejemplo de Petición
```json
{
  "action": "createCatalogoMercado",
  "params": {
    "oficina": 1,
    "num_mercado_nvo": 10,
    "categoria": 2,
    "descripcion": "Mercado Juárez",
    "cuenta_ingreso": 44501,
    "cuenta_energia": 12345,
    "id_zona": 3,
    "tipo_emision": "M",
    "usuario_id": 5
  }
}
```

## Ejemplo de Respuesta
```json
{
  "success": true,
  "data": null,
  "message": ""
}
```

## Errores Comunes
- Parámetros faltantes o inválidos: el backend retorna `success: false` y un mensaje de error.
- Operación no soportada: mensaje de error.

## Extensibilidad
- Se pueden agregar nuevas acciones y SPs siguiendo el mismo patrón.
- El frontend puede ser extendido para incluir filtros, exportación, etc.


## Casos de Uso

# Casos de Uso - RptCatalogoMerc

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Mercado Municipal

**Descripción:** Un usuario autorizado desea registrar un nuevo mercado municipal en el sistema.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta.

**Pasos a seguir:**
1. El usuario ingresa a la página de Catálogo de Mercados.
2. Hace clic en 'Agregar Mercado'.
3. Llena el formulario con los datos requeridos.
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con action 'createCatalogoMercado'.
6. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
El nuevo mercado aparece en el listado y está disponible para futuras operaciones.

**Datos de prueba:**
{ "oficina": 2, "num_mercado_nvo": 20, "categoria": 1, "descripcion": "Mercado San Juan", "cuenta_ingreso": 44502, "cuenta_energia": 0, "id_zona": 2, "tipo_emision": "M", "usuario_id": 1 }

---

## Caso de Uso 2: Edición de un Mercado Existente

**Descripción:** Un usuario necesita actualizar la descripción y cuenta de ingreso de un mercado existente.

**Precondiciones:**
El mercado existe y el usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario localiza el mercado en el listado.
2. Hace clic en 'Editar'.
3. Modifica la descripción y cuenta de ingreso.
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con action 'updateCatalogoMercado'.
6. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
Los cambios se reflejan en el listado.

**Datos de prueba:**
{ "oficina": 2, "num_mercado_nvo": 20, "categoria": 1, "descripcion": "Mercado San Juan Actualizado", "cuenta_ingreso": 44503, "cuenta_energia": 0, "id_zona": 2, "tipo_emision": "M", "usuario_id": 1 }

---

## Caso de Uso 3: Generación de Reporte PDF del Catálogo

**Descripción:** El usuario desea obtener un reporte PDF actualizado del catálogo de mercados.

**Precondiciones:**
Existen mercados registrados.

**Pasos a seguir:**
1. El usuario hace clic en 'Generar Reporte PDF'.
2. El sistema envía la petición a /api/execute con action 'getCatalogoMercadosReporte'.
3. El backend ejecuta el SP y retorna la URL del PDF.

**Resultado esperado:**
El usuario puede descargar el PDF generado.

**Datos de prueba:**
{}

---



## Casos de Prueba

# Casos de Prueba: Catálogo de Mercados Municipales

## Caso 1: Alta de Mercado
- **Entrada:**
  - oficina: 2
  - num_mercado_nvo: 20
  - categoria: 1
  - descripcion: "Mercado San Juan"
  - cuenta_ingreso: 44502
  - cuenta_energia: 0
  - id_zona: 2
  - tipo_emision: "M"
  - usuario_id: 1
- **Acción:** createCatalogoMercado
- **Esperado:**
  - Respuesta: success: true
  - El mercado aparece en el listado

## Caso 2: Edición de Mercado
- **Entrada:**
  - oficina: 2
  - num_mercado_nvo: 20
  - categoria: 1
  - descripcion: "Mercado San Juan Actualizado"
  - cuenta_ingreso: 44503
  - cuenta_energia: 0
  - id_zona: 2
  - tipo_emision: "M"
  - usuario_id: 1
- **Acción:** updateCatalogoMercado
- **Esperado:**
  - Respuesta: success: true
  - El mercado muestra los datos actualizados

## Caso 3: Eliminación de Mercado
- **Entrada:**
  - oficina: 2
  - num_mercado_nvo: 20
- **Acción:** deleteCatalogoMercado
- **Esperado:**
  - Respuesta: success: true
  - El mercado ya no aparece en el listado

## Caso 4: Consulta de Listado
- **Entrada:**
  - (sin parámetros)
- **Acción:** getCatalogoMercados
- **Esperado:**
  - Respuesta: success: true
  - Se retorna un array de mercados

## Caso 5: Generación de Reporte
- **Entrada:**
  - (sin parámetros)
- **Acción:** getCatalogoMercadosReporte
- **Esperado:**
  - Respuesta: success: true
  - data.pdf_url contiene la URL del PDF

## Caso 6: Error por parámetros faltantes
- **Entrada:**
  - (parámetros incompletos)
- **Acción:** createCatalogoMercado
- **Esperado:**
  - Respuesta: success: false
  - Mensaje de error indicando parámetros faltantes



