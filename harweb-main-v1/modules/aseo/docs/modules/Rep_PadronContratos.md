# Documentación Técnica: Migración de Formulario Rep_PadronContratos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el reporte de Padrón de Contratos, permitiendo filtrar por tipo de aseo, vigencia, y periodo. El backend está en Laravel, el frontend en Vue.js, y la lógica de negocio SQL reside en stored procedures de PostgreSQL. Toda la comunicación se realiza mediante un endpoint API unificado `/api/execute` usando el patrón eRequest/eResponse.

## 2. Arquitectura
- **Backend:** Laravel Controller (`PadronContratosController`) con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación y filtros.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures (`sp16_contratos`, `con16_detade_01`).
- **API:** Todas las operaciones se realizan mediante POST a `/api/execute` con parámetros `action` y `params`.

## 3. API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getPadronContratos",
    "params": {
      "tipo": "T",
      "vigencia": "V"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- **sp16_contratos:** Devuelve el padrón de contratos filtrado por tipo y vigencia.
- **con16_detade_01:** Devuelve el detalle de adeudos por contrato, periodo y tipo de reporte.
- **ta_16_dia_limite:** Tabla de días límite por mes (no SP, pero se consulta desde el backend).

## 5. Flujo de la Aplicación
1. El usuario accede a la página de Padrón de Contratos.
2. Selecciona filtros (tipo de aseo, vigencia, periodo).
3. Al hacer clic en "Buscar", el frontend envía un eRequest a `/api/execute` con `action: getPadronContratos`.
4. El backend ejecuta el SP `sp16_contratos` y retorna los contratos.
5. El usuario puede ver el detalle de adeudos de cada contrato, que dispara un eRequest con `action: getDetalleAdeudos`.
6. El backend ejecuta el SP `con16_detade_01` y retorna el detalle.

## 6. Seguridad
- Todas las operaciones requieren autenticación (middleware Laravel).
- Validación de parámetros en el backend.

## 7. Consideraciones de Migración
- Los combos Delphi se migran a `<select>` en Vue.js.
- El reporte Delphi se convierte en tabla HTML con totales.
- El cálculo de totales se realiza en el frontend.
- El endpoint es único y multipropósito.

## 8. Extensibilidad
- Para agregar nuevos reportes, basta con agregar nuevos SP y acciones en el controlador.

## 9. Pruebas
- Ver sección de casos de uso y casos de prueba.

