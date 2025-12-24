# AdeudosEnergia

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Adeudos de Energía Eléctrica

## Descripción General
Este módulo permite consultar, exportar y reportar el listado de adeudos de energía eléctrica por año y oficina recaudadora. Incluye:
- Backend Laravel con endpoint unificado `/api/execute`.
- Frontend Vue.js como página independiente.
- Lógica de negocio y reportes implementados en stored procedures PostgreSQL.
- Exportación a Excel y generación de reportes PDF (integración sugerida).

## Arquitectura
- **API Unificada**: Todas las operaciones se realizan mediante el endpoint `/api/execute` usando el patrón eRequest/eResponse.
- **Stored Procedures**: Toda la lógica de consulta y agregación reside en procedimientos almacenados PostgreSQL.
- **Frontend**: Página Vue.js independiente, sin tabs, con navegación breadcrumb y tabla de resultados.

## Flujo de Datos
1. El usuario selecciona año y oficina y presiona "Buscar".
2. El frontend envía un POST a `/api/execute` con `{ action: 'getAdeudosEnergia', params: { axo, oficina } }`.
3. Laravel ejecuta el stored procedure `sp_get_adeudos_energia` y retorna los resultados.
4. El usuario puede exportar a Excel o imprimir (PDF) usando los botones correspondientes, que llaman a los endpoints `exportExcel` o `printReport`.

## Endpoints y Acciones
- `getRecaudadoras`: Lista de oficinas recaudadoras.
- `getAdeudosEnergia`: Consulta de adeudos por año y oficina.
- `getMesesAdeudoEnergia`: Consulta de meses y cuotas para un local.
- `exportExcel`: Exporta los datos actuales a Excel (integración sugerida con SheetJS o Laravel Excel).
- `printReport`: Genera un PDF del reporte (integración sugerida con dompdf o similar).

## Validaciones
- El año debe estar entre 1994 y 2999.
- La oficina debe ser seleccionada.
- Los errores de backend se muestran en el frontend.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel).
- Validar que los parámetros sean correctos y sanitizados.

## Integraciones Sugeridas
- **Excel**: SheetJS en frontend o Laravel Excel en backend.
- **PDF**: dompdf o similar en backend.

## Estructura de la Base de Datos
- `ta_11_adeudo_energ`: Adeudos de energía por local, año, periodo.
- `ta_11_energia`: Datos de energía por local.
- `ta_11_locales`: Datos de locales.
- `ta_12_recaudadoras`: Catálogo de oficinas recaudadoras.

## Notas de Migración
- Todas las consultas SQL del sistema Delphi se han migrado a stored procedures PostgreSQL.
- El frontend Vue.js es una página completa, sin tabs, y puede integrarse en cualquier SPA.

# Parámetros de Stored Procedures
- `sp_get_adeudos_energia(axo INTEGER, oficina INTEGER)`
- `sp_get_meses_adeudo_energia(id_energia INTEGER, axo INTEGER)`

# Ejemplo de eRequest/eResponse
```json
{
  "action": "getAdeudosEnergia",
  "params": { "axo": 2024, "oficina": 5 }
}
```

# Respuesta
```json
{
  "success": true,
  "data": [ ... ],
  "message": ""
}
```


## Casos de Uso

# Casos de Uso - AdeudosEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Energía por Año y Oficina

**Descripción:** El usuario desea consultar todos los adeudos de energía eléctrica del año 2024 para la oficina 5 (Cruz del Sur).

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
- Ingresa a la página de Adeudos de Energía.
- Selecciona el año 2024.
- Selecciona la oficina 5.
- Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los locales que tienen adeudos de energía eléctrica para el año y oficina seleccionados, incluyendo los periodos y cuotas.

**Datos de prueba:**
{ "axo": 2024, "oficina": 5 }

---

## Caso de Uso 2: Exportar Adeudos a Excel

**Descripción:** El usuario desea exportar el listado de adeudos de energía a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
- Presiona el botón 'Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos mostrados en la tabla.

**Datos de prueba:**
Datos de la consulta previa.

---

## Caso de Uso 3: Imprimir Reporte de Adeudos

**Descripción:** El usuario desea imprimir el reporte de adeudos de energía eléctrica.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
- Presiona el botón 'Imprimir'.

**Resultado esperado:**
Se genera y muestra un PDF listo para imprimir con el listado de adeudos.

**Datos de prueba:**
Datos de la consulta previa.

---



## Casos de Prueba

# Casos de Prueba: Adeudos de Energía Eléctrica

## Caso 1: Consulta exitosa
- **Entrada:** Año=2024, Oficina=5
- **Acción:** Buscar
- **Resultado esperado:** Tabla con datos de adeudos, sin errores.

## Caso 2: Año fuera de rango
- **Entrada:** Año=1990, Oficina=1
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error 'Año fuera de rango'.

## Caso 3: Oficina no seleccionada
- **Entrada:** Año=2024, Oficina=''
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error 'Debe seleccionar una oficina'.

## Caso 4: Exportar Excel sin datos
- **Entrada:** Sin realizar búsqueda
- **Acción:** Presionar 'Excel'
- **Resultado esperado:** Mensaje de error 'No hay datos para exportar'.

## Caso 5: Imprimir sin datos
- **Entrada:** Sin realizar búsqueda
- **Acción:** Presionar 'Imprimir'
- **Resultado esperado:** Mensaje de error 'No hay datos para imprimir'.

## Caso 6: Consulta con datos inexistentes
- **Entrada:** Año=2099, Oficina=9
- **Acción:** Buscar
- **Resultado esperado:** Tabla vacía, mensaje 'No hay datos para los filtros seleccionados.'



