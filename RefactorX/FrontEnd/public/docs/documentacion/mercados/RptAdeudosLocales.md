# RptAdeudosLocales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Adeudos de Locales

## Descripción General
Este módulo permite consultar, visualizar y exportar el listado de adeudos de locales de mercados municipales, filtrando por año, recaudadora y periodo (mes). Incluye la lógica de cálculo de renta, meses de adeudo y exportación a Excel.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js independiente como página completa.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.
- **API**: Todas las operaciones se realizan mediante el endpoint `/api/execute`.

## Flujo de Datos
1. El usuario accede a la página de Adeudos de Locales.
2. Selecciona año, recaudadora y mes.
3. Al consultar, el frontend envía un eRequest con acción `getAdeudosLocales` y los parámetros seleccionados.
4. El backend ejecuta el stored procedure `sp_get_adeudos_locales` y retorna los datos en eResponse.
5. El usuario puede exportar el resultado a Excel (funcionalidad a implementar).

## Endpoints
- **POST /api/execute**
  - **Entrada**: `{ eRequest: { action: string, params: object } }`
  - **Salida**: `{ eResponse: { success: bool, message: string, data: any } }`

## Stored Procedures
- `sp_get_adeudos_locales(axo, oficina, periodo)`
- `sp_get_meses_adeudo(id_local, axo, periodo)`
- `sp_get_renta_local(axo, categoria, seccion, clave_cuota)`

## Validaciones
- Todos los parámetros requeridos deben ser enviados.
- El año debe ser >= 1990.
- El periodo (mes) debe estar entre 1 y 12.
- La recaudadora debe existir.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Validar que el usuario tenga permisos para consultar la recaudadora seleccionada.

## Exportación a Excel
- La exportación debe realizarse en backend, generando un archivo temporal y devolviendo la URL de descarga.

## Errores
- Todos los errores se devuelven en el campo `message` de eResponse.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.



## Casos de Uso

# Casos de Uso - RptAdeudosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Locales por Año y Recaudadora

**Descripción:** El usuario consulta el listado de adeudos de locales para un año y recaudadora específicos.

**Precondiciones:**
El usuario está autenticado y tiene permisos para la recaudadora seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página de Adeudos de Locales.
2. Selecciona el año 2024, recaudadora 'Zona Centro', y periodo 6 (junio).
3. Hace clic en 'Consultar'.
4. El sistema muestra el listado de adeudos correspondientes.

**Resultado esperado:**
Se muestra una tabla con los adeudos de locales de la recaudadora 'Zona Centro' para junio 2024.

**Datos de prueba:**
{ axo: 2024, oficina: 1, periodo: 6 }

---

## Caso de Uso 2: Exportación de Adeudos a Excel

**Descripción:** El usuario exporta el listado de adeudos consultado a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta de adeudos y hay resultados en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en 'Exportar Excel'.
2. El sistema genera el archivo y ofrece la descarga.

**Resultado esperado:**
El usuario descarga un archivo Excel con los datos mostrados.

**Datos de prueba:**
Debe existir al menos un registro en la consulta previa.

---

## Caso de Uso 3: Consulta de Meses de Adeudo de un Local

**Descripción:** El usuario consulta los meses de adeudo de un local específico.

**Precondiciones:**
El usuario conoce el ID del local y tiene permisos.

**Pasos a seguir:**
1. El usuario solicita los meses de adeudo para el local ID 1234, año 2024, periodo 6.
2. El sistema retorna la lista de meses y montos adeudados.

**Resultado esperado:**
Se retorna un arreglo con los meses y montos de adeudo del local.

**Datos de prueba:**
{ id_local: 1234, axo: 2024, periodo: 6 }

---



## Casos de Prueba

# Casos de Prueba: Adeudos de Locales

## Caso 1: Consulta exitosa de adeudos
- **Entrada:** { axo: 2024, oficina: 1, periodo: 6 }
- **Acción:** POST /api/execute con action 'getAdeudosLocales'
- **Resultado esperado:** eResponse.success = true, eResponse.data contiene arreglo de adeudos

## Caso 2: Consulta con parámetros inválidos
- **Entrada:** { axo: '', oficina: 1, periodo: 6 }
- **Acción:** POST /api/execute con action 'getAdeudosLocales'
- **Resultado esperado:** eResponse.success = false, eResponse.message indica error de validación

## Caso 3: Exportación a Excel sin datos
- **Entrada:** action 'exportAdeudosLocalesExcel' sin haber consultado datos
- **Acción:** POST /api/execute
- **Resultado esperado:** eResponse.success = true, eResponse.message = 'Exportación en proceso' (o error si no implementado)

## Caso 4: Consulta de meses de adeudo
- **Entrada:** { id_local: 1234, axo: 2024, periodo: 6 }
- **Acción:** POST /api/execute con action 'getMesesAdeudo'
- **Resultado esperado:** eResponse.success = true, eResponse.data contiene arreglo de meses

## Caso 5: Consulta de renta de local
- **Entrada:** { axo: 2024, categoria: 1, seccion: 'PS', clave_cuota: 4 }
- **Acción:** POST /api/execute con action 'getRentaLocal'
- **Resultado esperado:** eResponse.success = true, eResponse.data contiene importe_cuota



