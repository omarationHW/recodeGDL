# Documentación Técnica: sQRptAdeudos

## Análisis

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


## Casos de Uso

# Casos de Uso - sQRptAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta general de adeudos de todas las empresas

**Descripción:** El usuario desea obtener el reporte de todos los adeudos de aseo contratado, sin filtrar por empresa ni contrato.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en las tablas relacionadas.

**Pasos a seguir:**
1. Ingresar a la página de Reporte de Adeudos Generales.
2. Dejar los filtros en sus valores por defecto (todas las empresas, todos los contratos, todos los tipos de aseo, etc).
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los registros de adeudos, agrupados y ordenados según el parámetro de clasificación seleccionado.

**Datos de prueba:**
sel_emp: 1, num_emp: 0, sel_cont: 1, num_cont: 0, sel_ctrol_aseo: 0, vig_cont: 'T', vig_adeudos: 'T', ofna: 0, opcion: 1

---

## Caso de Uso 2: Reporte de adeudos por empresa específica y contrato vigente

**Descripción:** El usuario desea ver sólo los adeudos de una empresa específica y sólo los contratos vigentes.

**Precondiciones:**
Existe al menos una empresa con contratos vigentes y adeudos registrados.

**Pasos a seguir:**
1. Seleccionar 'Por Empresa' en el filtro Empresa.
2. Ingresar el número de empresa deseado.
3. Seleccionar 'Vigente' en el filtro Vigencia Contrato.
4. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestran únicamente los adeudos correspondientes a la empresa y contratos vigentes seleccionados.

**Datos de prueba:**
sel_emp: 2, num_emp: 123, sel_cont: 1, num_cont: 0, sel_ctrol_aseo: 0, vig_cont: 'V', vig_adeudos: 'T', ofna: 0, opcion: 1

---

## Caso de Uso 3: Reporte filtrado por tipo de aseo y recaudadora

**Descripción:** El usuario desea ver los adeudos de un tipo de aseo específico y de una recaudadora determinada.

**Precondiciones:**
Existen registros con el tipo de aseo y recaudadora seleccionados.

**Pasos a seguir:**
1. Ingresar el código de tipo de aseo en el filtro correspondiente.
2. Ingresar el código de recaudadora en el filtro correspondiente.
3. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestran sólo los adeudos que cumplen ambos criterios.

**Datos de prueba:**
sel_emp: 1, num_emp: 0, sel_cont: 1, num_cont: 0, sel_ctrol_aseo: 5, vig_cont: 'T', vig_adeudos: 'T', ofna: 2, opcion: 1

---



## Casos de Prueba

# Casos de Prueba para Reporte de Adeudos Generales

## Caso 1: Consulta general sin filtros
- **Entrada**:
  - sel_emp: 1
  - num_emp: 0
  - sel_cont: 1
  - num_cont: 0
  - sel_ctrol_aseo: 0
  - vig_cont: 'T'
  - vig_adeudos: 'T'
  - ofna: 0
  - opcion: 1
- **Esperado**: Se listan todos los adeudos existentes en la base de datos.

## Caso 2: Consulta por empresa y contratos vigentes
- **Entrada**:
  - sel_emp: 2
  - num_emp: 123
  - sel_cont: 1
  - num_cont: 0
  - sel_ctrol_aseo: 0
  - vig_cont: 'V'
  - vig_adeudos: 'T'
  - ofna: 0
  - opcion: 1
- **Esperado**: Sólo se muestran los adeudos de la empresa 123 y contratos vigentes.

## Caso 3: Consulta por tipo de aseo y recaudadora
- **Entrada**:
  - sel_emp: 1
  - num_emp: 0
  - sel_cont: 1
  - num_cont: 0
  - sel_ctrol_aseo: 5
  - vig_cont: 'T'
  - vig_adeudos: 'T'
  - ofna: 2
  - opcion: 1
- **Esperado**: Sólo se muestran los adeudos con tipo de aseo 5 y recaudadora 2.

## Caso 4: Consulta por contrato específico y vigencia cancelada
- **Entrada**:
  - sel_emp: 1
  - num_emp: 0
  - sel_cont: 2
  - num_cont: 456
  - sel_ctrol_aseo: 0
  - vig_cont: 'C'
  - vig_adeudos: 'T'
  - ofna: 0
  - opcion: 1
- **Esperado**: Sólo se muestran los adeudos del contrato 456 con contratos cancelados.

## Caso 5: Consulta por vigencia de adeudos pagados
- **Entrada**:
  - sel_emp: 1
  - num_emp: 0
  - sel_cont: 1
  - num_cont: 0
  - sel_ctrol_aseo: 0
  - vig_cont: 'T'
  - vig_adeudos: 'P'
  - ofna: 0
  - opcion: 1
- **Esperado**: Sólo se muestran los adeudos con status_vigencia_1 = 'P' (pagados).


