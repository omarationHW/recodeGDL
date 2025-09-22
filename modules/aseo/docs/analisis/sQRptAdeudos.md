# Documentación Técnica: Migración de Formulario sQRptAdeudos a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Componente Vue.js de página completa, independiente, con navegación breadcrumb y tabla de resultados.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.

## 2. Endpoint API Unificado
- **Ruta**: `POST /api/execute`
- **Entrada**:
  ```json
  {
    "eRequest": {
      "procedure": "rpt_adeudos_general",
      "params": {
        "sel_emp": 1,
        "num_emp": 0,
        "sel_cont": 1,
        "num_cont": 0,
        "sel_ctrol_aseo": 0,
        "vig_cont": "T",
        "vig_adeudos": "T",
        "ofna": 0,
        "opcion": 1
      }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ]
    }
  }
  ```

## 3. Stored Procedure Principal
- **Nombre**: `rpt_adeudos_general`
- **Tipo**: REPORT
- **Descripción**: Devuelve el reporte de adeudos generales de aseo contratado, con filtros dinámicos y clasificación según parámetro `opcion`.
- **Parámetros**:
  - `sel_emp`: 1=Todas, 2=Por empresa
  - `num_emp`: Número de empresa (si aplica)
  - `sel_cont`: 1=Todos, 2=Por contrato
  - `num_cont`: Número de contrato (si aplica)
  - `sel_ctrol_aseo`: 0=Todos, >0=Por tipo de aseo
  - `vig_cont`: 'T'=Todos, 'V'=Vigente, 'C'=Cancelado
  - `vig_adeudos`: 'T'=Todos, 'V'=Vigente, 'C'=Cancelado, 'P'=Pagado, 'S'=Condonado
  - `ofna`: 0=Todas, >0=Por recaudadora
  - `opcion`: 1=Periodo, 2=Tipo operación, 3=Vigencia, 4=Fecha pago, 5=Recaudadora, 6=Caja

## 4. Controlador Laravel
- **Clase**: `App\Http\Controllers\Api\ExecuteController`
- **Método**: `execute(Request $request)`
- **Lógica**:
  - Recibe el nombre del procedimiento y parámetros.
  - Ejecuta el SP correspondiente vía DB::select.
  - Devuelve los resultados en `eResponse`.

## 5. Componente Vue.js
- **Nombre**: `RptAdeudosGeneral`
- **Características**:
  - Página completa, sin tabs.
  - Formulario de filtros (empresa, contrato, aseo, vigencia, recaudadora, clasificación).
  - Tabla de resultados con todos los campos relevantes.
  - Breadcrumb de navegación.
  - Manejo de carga y errores.

## 6. Seguridad
- Validar que sólo se ejecuten SPs permitidos.
- Sanitizar parámetros en backend.

## 7. Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba.

## 8. Consideraciones
- El SP puede ser extendido para agregar más filtros o columnas si la lógica Delphi original lo requiere.
- El frontend puede ser adaptado para exportar a Excel/PDF si se requiere.
