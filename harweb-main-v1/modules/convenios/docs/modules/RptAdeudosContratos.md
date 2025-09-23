# Documentación Técnica: Migración de RptAdeudosContratos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario/reporte "RptAdeudosContratos" originalmente en Delphi, migrado a una arquitectura moderna basada en:
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)

## 2. Arquitectura
- **API Unificada:** Todas las operaciones se realizan a través de `/api/execute` usando el patrón `eRequest`/`eResponse`.
- **Stored Procedure:** Toda la lógica de consulta y cálculo reside en la función `rpt_adeudos_contratos` en PostgreSQL.
- **Frontend:** El componente Vue.js es una página completa, sin tabs, con navegación breadcrumb y tabla de resultados.

## 3. Flujo de Datos
1. El usuario ingresa los parámetros (colonia, calle, tipo de reporte) en la página Vue.
2. El frontend envía una petición POST a `/api/execute` con `{ eRequest: 'RptAdeudosContratos', params: { colonia, calle, rep } }`.
3. El controlador Laravel recibe la petición, valida los parámetros y ejecuta el stored procedure correspondiente.
4. El resultado se retorna en `eResponse.data` y se muestra en la tabla del frontend.

## 4. Stored Procedure: rpt_adeudos_contratos
- **Entradas:**
  - `p_colonia` (integer): ID de la colonia
  - `p_calle` (integer): ID de la calle
  - `p_rep` (integer): Tipo de reporte (1=adeudos, 2=saldos a favor, 3=liquidados)
- **Salidas:**
  - Listado de contratos con campos: id_convenio, colonia, calle, folio, nombre, pago_total, pagos, desc_calle, descripcion, devolucion, recargos, recargosnvo, pagosreal, concepto
- **Lógica:**
  - Calcula pagos, recargos, devoluciones y determina el concepto (ADE, LIQ, SAF) según el saldo.
  - Filtra según el tipo de reporte solicitado.

## 5. API Controller
- **Ruta:** POST `/api/execute`
- **Parámetros:**
  - `eRequest`: 'RptAdeudosContratos'
  - `params`: { colonia, calle, rep }
- **Respuesta:**
  - `eResponse.success`: true/false
  - `eResponse.data`: array de resultados
  - `eResponse.message`: mensaje de error si aplica

## 6. Frontend (Vue.js)
- Página independiente con formulario de parámetros y tabla de resultados.
- Muestra totales y concepto por contrato.
- Permite cambiar tipo de reporte dinámicamente.

## 7. Seguridad
- Validación de parámetros en backend.
- No expone SQL ni lógica interna al frontend.

## 8. Extensibilidad
- Se pueden agregar más reportes reutilizando el endpoint `/api/execute` y agregando nuevos stored procedures y lógica en el controlador.

## 9. Consideraciones de Migración
- El cálculo de campos calculados (pagosreal, concepto) se realiza en el stored procedure, no en el frontend.
- Los nombres de campos y lógica se mantienen fieles al original Delphi.

## 10. Ejemplo de Petición
```json
{
  "eRequest": "RptAdeudosContratos",
  "params": {
    "colonia": 123,
    "calle": 456,
    "rep": 1
  }
}
```

## 11. Ejemplo de Respuesta
```json
{
  "eResponse": {
    "success": true,
    "data": [
      {
        "id_convenio": 1,
        "colonia": 123,
        "calle": 456,
        "folio": 789,
        "nombre": "Juan Perez",
        "pago_total": 10000.00,
        "pagos": 8000.00,
        "desc_calle": "AV. PRINCIPAL",
        "descripcion": "COL. CENTRO",
        "devolucion": 0.00,
        "recargos": 0.00,
        "recargosnvo": 0.00,
        "pagosreal": 8000.00,
        "concepto": "ADE"
      }
    ],
    "message": ""
  }
}
```
