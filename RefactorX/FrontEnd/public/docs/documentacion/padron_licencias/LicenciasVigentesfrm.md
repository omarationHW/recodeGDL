# Documentación Técnica: LicenciasVigentesfrm

## Análisis Técnico

# Documentación Técnica: Licencias Vigentes (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (sin tabs)
- **Base de Datos:** PostgreSQL 14+, lógica de negocio en stored procedures
- **Exportación:** Laravel-Excel para generación de archivos temporales
- **Seguridad:** Autenticación JWT recomendada, validación de roles/acciones

## Flujo de Trabajo
1. **El usuario accede a la página de Licencias Vigentes** (`/licencias-vigentes`)
2. El componente Vue carga los grupos de licencias (opcional)
3. El usuario selecciona filtros y consulta
4. El frontend envía un POST a `/api/execute` con `{action: 'getLicenciasVigentes', params: {...}}`
5. El backend ejecuta el SP `sp_licencias_vigentes` y retorna los resultados
6. El usuario puede exportar a Excel (llama `exportLicenciasExcel`)
7. El usuario puede activar la baja masiva (llama `bajaLicencias`)

## API: eRequest/eResponse
- **Endpoint:** `POST /api/execute`
- **Body:** `{ action: string, params: object }`
- **Response:** `{ success: bool, data: any, message: string }`

## Stored Procedures
- Toda la lógica de consulta y proceso está en SPs PostgreSQL
- Los filtros se pasan como JSON para máxima flexibilidad
- Los procesos de baja son transaccionales

## Seguridad y Validaciones
- Validar que sólo usuarios autorizados puedan dar de baja
- Validar que los campos requeridos estén presentes
- Validar que la licencia esté vigente y no bloqueada antes de baja

## Exportación a Excel
- El backend genera el archivo y retorna una URL temporal
- El frontend abre el archivo en una nueva pestaña

## Consideraciones de Migración
- Los queries Delphi se migran a SPs parametrizados
- El control de baja masiva se realiza en el SP, con rollback en caso de error
- El frontend es reactivo y muestra mensajes de error/éxito

## Estructura de Carpetas
- `app/Http/Controllers/LicenciasVigentesController.php`
- `resources/js/pages/LicenciasVigentesPage.vue`
- `database/migrations/` (tablas y SPs)

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar el endpoint
- Los SPs pueden evolucionar para nuevos filtros/campos

# Endpoints y Acciones
| Acción                | Descripción                                 |
|----------------------|---------------------------------------------|
| getLicenciasVigentes | Consulta el reporte con filtros              |
| exportLicenciasExcel | Exporta el reporte a Excel                   |
| bajaLicencias        | Aplica baja masiva de licencias seleccionadas|

# Parámetros de Filtros (Ejemplo)
```json
{
  "tipoReporte": "fecha|rango",
  "fechaConsulta": "2024-06-01",
  "fechaIni": "2024-01-01",
  "fechaFin": "2024-06-01",
  "vigencia": "V|CB|A|todas",
  "clasificacion": "A|B|C|D|todas",
  "adeudo": "todos|sin|desde|pagado|sinpago|al|fechapago",
  "axo": 2024,
  "fechaPagoIni": "2024-01-01",
  "fechaPagoFin": "2024-06-01",
  "grupoLic": 1,
  "bloqueo": 0,
  "filtrarActividad": true,
  "actividad": "RESTAURANTE"
}
```

# Ejemplo de Proceso de Baja
- El usuario selecciona una o varias licencias
- Ingresa año, folio y motivo
- El frontend envía `{action: 'bajaLicencias', params: {axo, folio, motivo, licencias: [123,456]}}`
- El SP actualiza licencias y anuncios ligados, cancela adeudos

# Errores Comunes
- Si la licencia ya está cancelada, retorna error
- Si falta algún campo requerido, retorna error

# Pruebas y Validación
- Usar Postman o frontend para probar todos los escenarios
- Validar que la baja es irreversible y consistente

## Casos de Uso

# Casos de Uso - LicenciasVigentesfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de Licencias Vigentes con Filtros

**Descripción:** El usuario consulta el reporte de licencias vigentes aplicando varios filtros (vigencia, clasificación, grupo, bloqueo, actividad, fechas).

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de Licencias Vigentes.
2. Selecciona filtros: Vigencia = 'V', Clasificación = 'B', Grupo = '1', Bloqueo = '0', Actividad = 'RESTAURANTE', Fecha de Consulta = '2024-06-01'.
3. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra el listado de licencias vigentes tipo B, grupo 1, no bloqueadas, actividad 'RESTAURANTE', vigentes al 2024-06-01.

**Datos de prueba:**
{
  "vigencia": "V",
  "clasificacion": "B",
  "grupoLic": 1,
  "bloqueo": 0,
  "filtrarActividad": true,
  "actividad": "RESTAURANTE",
  "tipoReporte": "fecha",
  "fechaConsulta": "2024-06-01"
}

---

## Caso de Uso 2: Exportación a Excel del Reporte

**Descripción:** El usuario exporta el reporte de licencias vigentes a Excel con los filtros aplicados.

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados.

**Pasos a seguir:**
1. Accede a la página de Licencias Vigentes.
2. Aplica los filtros deseados.
3. Presiona 'Exportar a Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos del reporte filtrado.

**Datos de prueba:**
{
  "vigencia": "V",
  "clasificacion": "A",
  "tipoReporte": "fecha",
  "fechaConsulta": "2024-06-01"
}

---

## Caso de Uso 3: Baja Masiva de Licencias

**Descripción:** El usuario da de baja varias licencias seleccionadas, indicando año, folio y motivo.

**Precondiciones:**
El usuario tiene permisos de baja y las licencias están vigentes y no bloqueadas.

**Pasos a seguir:**
1. Accede a la página de Licencias Vigentes.
2. Realiza una consulta y selecciona varias licencias.
3. Presiona 'Baja', ingresa año, folio y motivo.
4. Confirma la operación.

**Resultado esperado:**
Las licencias y sus anuncios ligados quedan con vigente 'C', se actualizan los campos de baja y se cancelan los adeudos.

**Datos de prueba:**
{
  "axo": 2024,
  "folio": 1234,
  "motivo": "Cierre definitivo",
  "licencias": [1001, 1002, 1003]
}

---
