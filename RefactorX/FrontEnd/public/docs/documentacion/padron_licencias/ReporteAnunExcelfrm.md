# Documentación Técnica: ReporteAnunExcelfrm

## Análisis Técnico

# Documentación Técnica: Migración Formulario ReporteAnunExcel (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (POST)
- **Frontend**: Vue.js SPA, página independiente para el formulario
- **Base de Datos**: PostgreSQL, lógica de reportes en stored procedures
- **Comunicación**: eRequest/eResponse (action, params)

## 2. API Backend
- **Controlador**: `ReporteAnunExcelController`
- **Métodos principales**:
  - `getGruposAnun`: Devuelve lista de grupos de anuncios
  - `getReporteAnuncios`: Ejecuta el SP de reporte con filtros
  - `exportReporteAnuncios`: Genera archivo Excel y devuelve URL
- **Endpoint único**: `/api/execute` (POST)
  - Entrada: `{ action: string, params: object }`
  - Salida: `{ status: 'success'|'error', data: any, message: string }`

## 3. Frontend Vue.js
- **Componente**: `ReporteAnunExcelPage.vue`
- **Características**:
  - Formulario con todos los filtros (vigencia, tipo reporte, fechas, adeudo, grupo)
  - Botón para consultar y exportar a Excel
  - Tabla de resultados dinámica
  - Descarga de Excel vía URL
  - Sin tabs, es página completa

## 4. Stored Procedure PostgreSQL
- **Nombre**: `sp_reporte_anuncios_excel`
- **Entradas**: Filtros del formulario (vigencia, tipo reporte, fechas, adeudo, grupo, etc)
- **Salida**: Tabla con columnas del reporte
- **Lógica**: Construcción dinámica del SQL según filtros, agrupaciones y joins

## 5. Flujo de Datos
1. Usuario accede a la página `/reporte-anuncios`
2. Vue.js carga grupos de anuncios vía `getGruposAnun`
3. Usuario llena filtros y presiona "Consultar"
4. Vue.js envía eRequest a `/api/execute` con action `getReporteAnuncios`
5. Laravel llama el SP y devuelve resultados
6. Usuario puede exportar a Excel (action `exportReporteAnuncios`)

## 6. Seguridad
- Validación de parámetros en backend
- Solo lectura (no hay escritura en este formulario)
- Exportación de Excel solo para usuarios autenticados

## 7. Consideraciones
- El SP puede ser optimizado para índices y performance
- El endpoint `/api/execute` puede ser usado por otros formularios
- El frontend es desacoplado, puede integrarse en cualquier SPA

## 8. Extensibilidad
- Se pueden agregar más filtros en el SP y el formulario
- El patrón eRequest/eResponse permite versionar acciones fácilmente

## 9. Ejemplo de eRequest/eResponse
```json
{
  "action": "getReporteAnuncios",
  "params": {
    "vigencia": 1,
    "tipoRep": 0,
    "fechaCons": "2024-06-01",
    "adeudo": 2,
    "axoIni": 2023,
    "grupoAnunId": 5
  }
}
```

## 10. Integración
- El endpoint `/api/execute` debe estar registrado en `routes/api.php` y apuntar al método `execute` del controlador.
- El frontend debe importar el componente y agregar la ruta correspondiente en el router de Vue.js.

---

## Casos de Prueba

# Casos de Prueba: ReporteAnunExcel

## Caso 1: Consulta básica de anuncios vigentes sin adeudo
- **Entrada**: `{ action: 'getReporteAnuncios', params: { vigencia: 1, tipoRep: 0, fechaCons: '2024-06-01', adeudo: 1 } }`
- **Esperado**: Respuesta status=success, data con anuncios vigentes y sin adeudo

## Caso 2: Exportar reporte con adeudo desde año
- **Entrada**: `{ action: 'exportReporteAnuncios', params: { vigencia: 0, tipoRep: 0, fechaCons: '2024-06-01', adeudo: 2, axoIni: 2022 } }`
- **Esperado**: status=success, data.url contiene enlace a archivo Excel

## Caso 3: Filtro por grupo y rango de fechas
- **Entrada**: `{ action: 'getReporteAnuncios', params: { vigencia: 0, tipoRep: 1, fechaIni: '2024-01-01', fechaFin: '2024-06-01', grupoAnunId: 3 } }`
- **Esperado**: status=success, data contiene solo anuncios del grupo 3 y fechas en rango

## Caso 4: Error por parámetros inválidos
- **Entrada**: `{ action: 'getReporteAnuncios', params: { vigencia: 1, tipoRep: 0 } }` (falta fechaCons)
- **Esperado**: status=error, message indica parámetro faltante

## Caso 5: Exportar Excel sin resultados
- **Entrada**: `{ action: 'exportReporteAnuncios', params: { vigencia: 1, tipoRep: 0, fechaCons: '1900-01-01', adeudo: 1 } }`
- **Esperado**: status=success, data.url generado, pero archivo vacío o con encabezados únicamente

## Casos de Uso

# Casos de Uso - ReporteAnunExcelfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de anuncios vigentes sin adeudo a la fecha

**Descripción:** El usuario desea obtener un listado de todos los anuncios vigentes (vigente = 'V') que no tienen adeudo, a la fecha actual.

**Precondiciones:**
El usuario tiene acceso al sistema y existen anuncios vigentes en la base de datos.

**Pasos a seguir:**
- Acceder a la página de Reporte de Anuncios
- Seleccionar 'A la Fecha' como tipo de reporte
- Seleccionar 'Vigentes (V)' como vigencia
- Seleccionar 'Sin Adeudo' como filtro de adeudo
- Ingresar la fecha de consulta (por defecto hoy)
- Presionar 'Consultar'

**Resultado esperado:**
Se muestra una tabla con los anuncios vigentes sin adeudo, con todas las columnas relevantes.

**Datos de prueba:**
Anuncios con vigente = 'V' y sin adeudo en detsal_lic.

---

## Caso de Uso 2: Exportar reporte de anuncios con adeudo desde año específico

**Descripción:** El usuario requiere exportar a Excel todos los anuncios que tienen adeudo desde el año 2022.

**Precondiciones:**
Existen anuncios con adeudo desde 2022.

**Pasos a seguir:**
- Acceder a la página de Reporte de Anuncios
- Seleccionar 'A la Fecha' como tipo de reporte
- Seleccionar 'Todas' como vigencia
- Seleccionar 'Con Adeudo desde' como filtro de adeudo
- Ingresar año 2022
- Presionar 'Exportar a Excel'

**Resultado esperado:**
Se descarga un archivo Excel con los anuncios filtrados por adeudo desde 2022.

**Datos de prueba:**
Anuncios con registros en detsal_lic con cvepago=0 y axo=2022.

---

## Caso de Uso 3: Filtrar anuncios por grupo y rango de fechas

**Descripción:** El usuario desea ver anuncios de un grupo específico en un rango de fechas de otorgamiento.

**Precondiciones:**
Existen grupos de anuncios y anuncios asociados.

**Pasos a seguir:**
- Acceder a la página de Reporte de Anuncios
- Seleccionar 'Rango de Fechas' como tipo de reporte
- Ingresar fechas de inicio y fin
- Seleccionar un grupo de anuncios
- Presionar 'Consultar'

**Resultado esperado:**
Se muestran solo los anuncios del grupo seleccionado y en el rango de fechas indicado.

**Datos de prueba:**
Anuncios asociados a un grupo y con fecha_otorgamiento dentro del rango.

---


