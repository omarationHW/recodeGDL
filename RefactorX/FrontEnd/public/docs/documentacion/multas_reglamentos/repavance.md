# Documentación: repavance

## Análisis Técnico

# Documentación Técnica: Migración de Formulario repavance (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de avance de recaudación de multas (repavance) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

- **Backend**: Laravel expone un endpoint unificado `/api/execute` que recibe peticiones eRequest/eResponse y ejecuta la lógica de negocio, incluyendo la invocación de stored procedures en PostgreSQL.
- **Frontend**: Un componente Vue.js representa la página completa del formulario, permitiendo seleccionar mes, año, recaudadora y tipo, y mostrando el reporte generado.
- **Base de Datos**: Toda la lógica de agregación y reporte se implementa en stored procedures PostgreSQL.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato de entrada**: `{ eRequest: { action: string, params: object } }`
- **Formato de salida**: `{ eResponse: { success: bool, data: object, message: string } }`

### Ejemplo de eRequest
```json
{
  "eRequest": {
    "action": "repavance_generate_report",
    "params": {
      "mes": 0,
      "anio": 2024,
      "recaudadora_id": 1,
      "tipo": "M"
    }
  }
}
```

## 3. Lógica de Negocio
- El usuario selecciona mes, año, recaudadora y tipo (municipal/federal).
- El backend calcula las fechas de inicio y fin del mes.
- Se invoca el stored procedure `repavance_generate_report` con los parámetros.
- El SP retorna un JSON con el detalle por dependencia (actas y totales en diferentes categorías).
- El frontend muestra el reporte en tabla, con totales.

## 4. Stored Procedure Principal
- **Nombre**: `repavance_generate_report`
- **Entradas**: recaudadora_id, fecha mínima, fecha máxima, tipo, año
- **Salida**: JSON con array de objetos por dependencia, cada uno con los campos: id_dependencia, descripcion, cuantos1, total1, cuantos2, total2, cuantos3, total3, cuantos4, total4
- **Notas**: La lógica de agregación puede adaptarse según la estructura real de las tablas.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para selección de parámetros.
- Tabla de resultados con totales.
- Manejo de errores y estados de carga.

## 6. Seguridad
- Validación de parámetros en backend.
- El SP sólo retorna datos agregados, no datos sensibles.

## 7. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- El SP puede extenderse para incluir más métricas o filtros.

## 8. Consideraciones de Migración
- Los nombres de tablas y campos pueden necesitar ajuste según el modelo real.
- La lógica de filtrado y agregación se centraliza en el SP para eficiencia y mantenibilidad.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## Casos de Uso

# Casos de Uso - repavance

**Categoría:** Form

## Caso de Uso 1: Generar reporte mensual de multas municipales

**Descripción:** El usuario desea obtener el reporte de avance de recaudación de multas municipales para el mes de enero de 2024 en la recaudadora 1.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID de la recaudadora.

**Pasos a seguir:**
1. Acceder a la página de Avance de Recaudación de Multas.
2. Seleccionar 'Enero' como mes.
3. Ingresar '2024' como año.
4. Ingresar '1' como ID de recaudadora.
5. Seleccionar 'Municipal' como tipo.
6. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con el detalle de actas e importes por dependencia para el mes de enero 2024, tipo municipal.

**Datos de prueba:**
{ "mes": 0, "anio": 2024, "recaudadora_id": 1, "tipo": "M" }

---

## Caso de Uso 2: Generar reporte mensual de multas federales

**Descripción:** El usuario desea obtener el reporte de avance de recaudación de multas federales para el mes de febrero de 2024 en la recaudadora 2.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID de la recaudadora.

**Pasos a seguir:**
1. Acceder a la página de Avance de Recaudación de Multas.
2. Seleccionar 'Febrero' como mes.
3. Ingresar '2024' como año.
4. Ingresar '2' como ID de recaudadora.
5. Seleccionar 'Federal' como tipo.
6. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con el detalle de actas e importes por dependencia para el mes de febrero 2024, tipo federal.

**Datos de prueba:**
{ "mes": 1, "anio": 2024, "recaudadora_id": 2, "tipo": "F" }

---

## Caso de Uso 3: Validación de parámetros insuficientes

**Descripción:** El usuario intenta generar un reporte sin ingresar el año.

**Precondiciones:**
El usuario accede a la página pero deja el campo año vacío.

**Pasos a seguir:**
1. Acceder a la página de Avance de Recaudación de Multas.
2. Seleccionar un mes.
3. Dejar el campo año vacío.
4. Ingresar un ID de recaudadora.
5. Seleccionar un tipo.
6. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que faltan parámetros.

**Datos de prueba:**
{ "mes": 0, "anio": null, "recaudadora_id": 1, "tipo": "M" }

---

## Casos de Prueba

## Casos de Prueba para repavance

### Caso 1: Reporte Municipal Enero 2024
- **Entrada:**
  - mes: 0
  - anio: 2024
  - recaudadora_id: 1
  - tipo: 'M'
- **Acción:** POST /api/execute con eRequest.action = 'repavance_generate_report'
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.report.detalle es un array con al menos un elemento
  - Los campos cuantos1, total1, etc. son numéricos

### Caso 2: Reporte Federal Febrero 2024 (Año Bisiesto)
- **Entrada:**
  - mes: 1
  - anio: 2024
  - recaudadora_id: 2
  - tipo: 'F'
- **Acción:** POST /api/execute con eRequest.action = 'repavance_generate_report'
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.report.detalle es un array
  - Las fechas mínimo y máximo consideran 29 días para febrero

### Caso 3: Parámetros insuficientes
- **Entrada:**
  - mes: 0
  - anio: null
  - recaudadora_id: 1
  - tipo: 'M'
- **Acción:** POST /api/execute con eRequest.action = 'repavance_generate_report'
- **Esperado:**
  - eResponse.success = false
  - eResponse.message contiene 'Parámetros insuficientes'

### Caso 4: Validación de totales
- **Entrada:**
  - mes: 2
  - anio: 2023
  - recaudadora_id: 1
  - tipo: 'M'
- **Acción:** POST /api/execute
- **Esperado:**
  - La suma de los campos en el frontend coincide con los totales calculados en el backend

### Caso 5: Reporte sin resultados
- **Entrada:**
  - mes: 5
  - anio: 2022
  - recaudadora_id: 99 (no existe)
  - tipo: 'M'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.report.detalle es un array vacío o todos los campos en cero

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

