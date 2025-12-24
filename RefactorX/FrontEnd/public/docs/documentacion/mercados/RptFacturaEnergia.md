# RptFacturaEnergia

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración RptFacturaEnergia Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de reporte de factura de energía eléctrica (RptFacturaEnergia) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de consulta y presentación se ha adaptado para cumplir con el patrón eRequest/eResponse y un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel Controller (ExecuteController) con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js de página completa, independiente, sin tabs.
- **Base de Datos:** Stored Procedure PostgreSQL para encapsular la lógica SQL del reporte.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest`: Nombre de la operación (ej: `RptFacturaEnergia.getReport`)
  - `eParams`: Objeto con parámetros requeridos
- **Salida:**
  - `success`: true/false
  - `data`: Datos solicitados
  - `message`: Mensaje de error o información

### Ejemplo de Request
```json
{
  "eRequest": "RptFacturaEnergia.getReport",
  "eParams": {
    "oficina": 1,
    "axo": 2024,
    "periodo": 6,
    "mercado": 2
  }
}
```

## 4. Stored Procedure
- **Nombre:** `rpt_factura_energia`
- **Parámetros:**
  - `p_oficina` (int)
  - `p_axo` (int)
  - `p_periodo` (int)
  - `p_mercado` (int)
- **Retorna:** Tabla con los campos requeridos para el reporte.
- **Ventajas:**
  - Encapsula la lógica SQL compleja.
  - Facilita el mantenimiento y pruebas.

## 5. Frontend (Vue.js)
- Página independiente `/factura-energia`.
- Formulario para capturar parámetros.
- Consulta asincrónica al API.
- Presentación tabular y totales.
- Breadcrumb de navegación.

## 6. Controlador Laravel
- Centraliza todas las operaciones bajo `/api/execute`.
- Implementa lógica de ruteo por `eRequest`.
- Maneja errores y validaciones.

## 7. Seguridad
- Validación de parámetros en backend.
- El stored procedure sólo expone los datos requeridos.
- Se recomienda proteger el endpoint con autenticación JWT o similar en producción.

## 8. Pruebas y Casos de Uso
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.

## 9. Extensibilidad
- Para agregar nuevos reportes o formularios, basta con:
  - Crear el stored procedure correspondiente.
  - Agregar el caso en el controlador.
  - Crear el componente Vue.js de página.

## 10. Notas de Migración
- Los nombres de campos y lógica de periodos se han respetado.
- La lógica de etiquetas de periodo se implementa en backend y frontend.
- El reporte es completamente funcional y puede exportarse a PDF/Excel desde el frontend si se requiere.


## Casos de Uso

# Casos de Uso - RptFacturaEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Factura de Energía para un Mercado Específico

**Descripción:** El usuario desea obtener el reporte de consumo y facturación de energía eléctrica para una oficina y mercado en un periodo y año determinados.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los valores de oficina, mercado, año y periodo.

**Pasos a seguir:**
1. El usuario accede a la página 'Factura Energía'.
2. Ingresa los valores: Oficina=1, Mercado=2, Año=2024, Periodo=6 (Junio).
3. Presiona el botón 'Consultar'.
4. El sistema consulta el API y muestra el reporte tabular con los datos correspondientes.

**Resultado esperado:**
Se muestra el reporte con los locales, consumos, importes y totales globales para los parámetros seleccionados.

**Datos de prueba:**
{ "oficina": 1, "mercado": 2, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 2: Validación de Parámetros Faltantes

**Descripción:** El usuario intenta consultar el reporte sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario accede a la página pero omite uno o más campos obligatorios.

**Pasos a seguir:**
1. El usuario deja vacío el campo 'Mercado'.
2. Presiona 'Consultar'.
3. El sistema valida y muestra un mensaje de error.

**Resultado esperado:**
El sistema no realiza la consulta y muestra un mensaje indicando los parámetros faltantes.

**Datos de prueba:**
{ "oficina": 1, "mercado": null, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 3: Reporte sin Resultados

**Descripción:** El usuario consulta un periodo/año/mercado/oficina para el cual no existen datos.

**Precondiciones:**
No existen registros en la base de datos para los parámetros dados.

**Pasos a seguir:**
1. El usuario ingresa Oficina=99, Mercado=99, Año=2020, Periodo=1.
2. Presiona 'Consultar'.
3. El sistema consulta el API y recibe un arreglo vacío.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no hay datos para los parámetros seleccionados.

**Datos de prueba:**
{ "oficina": 99, "mercado": 99, "axo": 2020, "periodo": 1 }

---



## Casos de Prueba

## Casos de Prueba: RptFacturaEnergia

### Caso 1: Consulta exitosa de reporte
- **Entrada:**
  - oficina: 1
  - mercado: 2
  - axo: 2024
  - periodo: 6
- **Acción:** POST /api/execute con eRequest=RptFacturaEnergia.getReport
- **Resultado esperado:**
  - success: true
  - data: arreglo con al menos un registro
  - Totales correctos en frontend

### Caso 2: Parámetros faltantes
- **Entrada:**
  - oficina: 1
  - mercado: (vacío)
  - axo: 2024
  - periodo: 6
- **Acción:** POST /api/execute con eRequest=RptFacturaEnergia.getReport
- **Resultado esperado:**
  - success: false
  - message: 'Parámetros requeridos: oficina, axo, periodo, mercado'

### Caso 3: Sin resultados
- **Entrada:**
  - oficina: 99
  - mercado: 99
  - axo: 2020
  - periodo: 1
- **Acción:** POST /api/execute con eRequest=RptFacturaEnergia.getReport
- **Resultado esperado:**
  - success: true
  - data: arreglo vacío
  - Frontend muestra mensaje 'No hay datos para los parámetros seleccionados.'

### Caso 4: Validación de etiquetas de periodo
- **Entrada:**
  - periodo: 3
  - axo: 2023
- **Acción:** POST /api/execute con eRequest=RptFacturaEnergia.getPeriodLabel
- **Resultado esperado:**
  - success: true
  - data: { short: 'MAR. 2023', long: 'MARZO DE 2023' }

### Caso 5: Error de base de datos
- **Simulación:** Forzar error en el stored procedure (ej: eliminar tabla temporalmente)
- **Acción:** POST /api/execute con parámetros válidos
- **Resultado esperado:**
  - success: false
  - message: error técnico de base de datos



