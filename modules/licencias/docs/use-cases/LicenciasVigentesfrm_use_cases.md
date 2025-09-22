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

