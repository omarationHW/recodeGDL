# Documentación Técnica: Cons_Tipos_Aseo

## Análisis

# Documentación Técnica: Consulta de Tipos de Aseo (Cons_Tipos_Aseo)

## Descripción General
Este módulo permite consultar el catálogo de Tipos de Aseo desde la base de datos PostgreSQL, mostrando los resultados en una tabla ordenable y permitiendo la exportación a Excel. La arquitectura sigue el patrón API unificada (eRequest/eResponse) y desacopla completamente el frontend (Vue.js) del backend (Laravel).

## Arquitectura
- **Backend:** Laravel Controller (ConsTiposAseoController)
- **Frontend:** Vue.js Single Page Component (ConsTiposAseoPage.vue)
- **Base de datos:** PostgreSQL, con stored procedures para lógica de negocio
- **API:** Endpoint único `/api/execute` que recibe eRequest y retorna eResponse

## Flujo de Datos
1. El usuario accede a la página de consulta de Tipos de Aseo.
2. El componente Vue envía una petición POST a `/api/execute` con el action `cons_tipos_aseo_list` y el campo de ordenamiento.
3. El backend ejecuta el stored procedure `sp_cons_tipos_aseo_list` y retorna los datos en formato JSON.
4. El usuario puede cambiar el orden y volver a consultar, o exportar a Excel (acción que puede ser implementada como descarga de archivo).

## API eRequest/eResponse
- **eRequest:**
  - `action`: Nombre de la acción (ej: `cons_tipos_aseo_list`)
  - `params`: Parámetros para la acción (ej: `{ order: 'descripcion' }`)
- **eResponse:**
  - `success`: true/false
  - `data`: Datos devueltos (array de objetos)
  - `message`: Mensaje de error o información

## Seguridad
- El controlador valida el campo de ordenamiento para evitar SQL Injection.
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## Stored Procedures
- Toda la lógica de consulta y exportación está en stored procedures PostgreSQL.
- El procedimiento de exportación retorna los mismos datos; la generación del archivo Excel se realiza en el backend PHP.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- El frontend puede ser reutilizado para otros catálogos cambiando el action y los campos.

## Integración
- El componente Vue debe estar registrado en el router como página independiente.
- El backend debe exponer el endpoint `/api/execute` y registrar el controlador en `routes/api.php`.

## Ejemplo de eRequest
```json
{
  "eRequest": {
    "action": "cons_tipos_aseo_list",
    "params": { "order": "descripcion" }
  }
}
```

## Ejemplo de eResponse
```json
{
  "eResponse": {
    "success": true,
    "data": [
      { "ctrol_aseo": 1, "tipo_aseo": "O", "descripcion": "Ordinario" },
      ...
    ],
    "message": ""
  }
}
```

## Consideraciones
- El frontend muestra mensajes de error si la consulta falla.
- La exportación a Excel puede implementarse como descarga directa o generación asíncrona.


## Casos de Uso

# Casos de Uso - Cons_Tipos_Aseo

**Categoría:** Form

## Caso de Uso 1: Consulta básica de Tipos de Aseo ordenados por Control

**Descripción:** El usuario accede a la página de consulta y visualiza todos los tipos de aseo ordenados por el campo 'Control'.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
1. El usuario navega a la página 'Consultas de Tipos de Aseo'.
2. El sistema muestra la tabla con los registros ordenados por 'Control'.

**Resultado esperado:**
Se muestran todos los registros de la tabla ta_16_tipo_aseo ordenados por ctrol_aseo.

**Datos de prueba:**
Tabla ta_16_tipo_aseo con al menos 3 registros distintos.

---

## Caso de Uso 2: Cambio de orden a 'Descripción'

**Descripción:** El usuario selecciona 'Descripción' en el selector de orden y la tabla se actualiza.

**Precondiciones:**
El usuario está en la página de consulta de Tipos de Aseo.

**Pasos a seguir:**
1. El usuario selecciona 'Descripción' en el combo de orden.
2. El sistema envía la petición con order='descripcion'.
3. El backend retorna los registros ordenados por descripción.

**Resultado esperado:**
La tabla se actualiza mostrando los registros ordenados alfabéticamente por descripción.

**Datos de prueba:**
Registros con descripciones: 'Hospitalario', 'Ordinario', 'Zona Centro'.

---

## Caso de Uso 3: Exportación a Excel

**Descripción:** El usuario hace clic en el botón 'Exportar Excel' y se genera un archivo descargable.

**Precondiciones:**
El usuario está en la página de consulta y hay registros en la tabla.

**Pasos a seguir:**
1. El usuario hace clic en 'Exportar Excel'.
2. El sistema genera el archivo Excel y lo descarga o muestra mensaje de éxito.

**Resultado esperado:**
El usuario recibe un archivo Excel con los datos actuales de la tabla.

**Datos de prueba:**
Registros actuales en la tabla ta_16_tipo_aseo.

---



## Casos de Prueba

# Casos de Prueba: Cons_Tipos_Aseo

## Caso 1: Consulta por defecto
- **Entrada:** eRequest.action = 'cons_tipos_aseo_list', params.order = 'ctrol_aseo'
- **Esperado:** eResponse.success = true, eResponse.data contiene todos los registros ordenados por ctrol_aseo

## Caso 2: Consulta por descripción
- **Entrada:** eRequest.action = 'cons_tipos_aseo_list', params.order = 'descripcion'
- **Esperado:** eResponse.success = true, eResponse.data ordenado alfabéticamente por descripción

## Caso 3: Orden inválido
- **Entrada:** eRequest.action = 'cons_tipos_aseo_list', params.order = 'hack'
- **Esperado:** eResponse.success = true, eResponse.data ordenado por ctrol_aseo (fallback seguro)

## Caso 4: Exportación a Excel
- **Entrada:** eRequest.action = 'cons_tipos_aseo_export_excel', params.order = 'tipo_aseo'
- **Esperado:** eResponse.success = true, eResponse.message indica que la exportación fue generada

## Caso 5: Acción no soportada
- **Entrada:** eRequest.action = 'no_existente'
- **Esperado:** eResponse.success = false, eResponse.message = 'Acción no soportada'

## Caso 6: Sin registros
- **Precondición:** Tabla ta_16_tipo_aseo vacía
- **Entrada:** eRequest.action = 'cons_tipos_aseo_list', params.order = 'ctrol_aseo'
- **Esperado:** eResponse.success = true, eResponse.data = []


