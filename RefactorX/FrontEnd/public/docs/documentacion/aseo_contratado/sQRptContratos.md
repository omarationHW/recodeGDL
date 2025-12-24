# Documentación Técnica: sQRptContratos

## Análisis

# Documentación Técnica: Migración de sQRptContratos a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General

- **Backend:** Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y parámetros.
- **Frontend:** Componente Vue.js de página completa, independiente, para consulta y visualización del reporte.
- **Base de Datos:** PostgreSQL, lógica de reportes encapsulada en stored procedure `rpt_contratos`.
- **Patrón de integración:** eRequest/eResponse para desacoplar lógica de negocio y presentación.

## 2. Endpoint API

- **Ruta:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "RptContratos",
    "params": {
      "seleccion": 1,
      "Ofna": 0,
      "Rep": 0,
      "opcion": 1,
      "Num_emp": 0,
      "Ctrol_Aseo": 0,
      "Vigencia": "T"
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "message": "Reporte generado",
      "data": {
        "contratos": [ ... ],
        "totales": {
          "total": 10,
          "vigentes": 8,
          "cancelados": 2
        }
      }
    }
  }
  ```

## 3. Stored Procedure: `rpt_contratos`

- Recibe parámetros de filtro y clasificación.
- Construye dinámicamente el SQL según los filtros.
- Devuelve todos los campos requeridos para el reporte.
- Permite paginar y filtrar desde el frontend si se desea.

## 4. Frontend (Vue.js)

- Formulario de filtros con todos los parámetros posibles.
- Tabla responsive con todos los campos del reporte.
- Muestra totales de contratos, vigentes y cancelados.
- Manejo de errores y estados de carga.
- Navegación breadcrumb.

## 5. Backend (Laravel)

- Controlador único `ExecuteController`.
- Método `execute` que despacha según `eRequest`.
- Llama al stored procedure y procesa los resultados para totales.
- Responde siempre con el patrón `eResponse`.

## 6. Seguridad

- Validar y sanear parámetros en el backend.
- El stored procedure solo permite SELECT, sin modificaciones.
- Se recomienda proteger el endpoint con autenticación según el contexto del sistema.

## 7. Extensibilidad

- Se pueden agregar más reportes o procesos reutilizando el endpoint `/api/execute`.
- El frontend puede ser extendido para exportar a Excel/PDF si se requiere.

## 8. Consideraciones de Migración

- Los nombres de campos y tablas deben coincidir con los de la base de datos PostgreSQL.
- Si existen diferencias, ajustar el stored procedure y el frontend.
- El reporte es solo de consulta, no hay operaciones de alta/baja/modificación.


## Casos de Uso

# Casos de Uso - sQRptContratos

**Categoría:** Form

## Caso de Uso 1: Consulta general de contratos vigentes

**Descripción:** El usuario desea obtener el listado completo de contratos vigentes, sin filtros adicionales.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contratos vigentes en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Contratos.
2. Deja todos los filtros en sus valores por defecto (seleccion=1, Vigencia='T').
3. Presiona el botón 'Generar Reporte'.

**Resultado esperado:**
Se muestra la tabla con todos los contratos vigentes y cancelados (excepto los de status 'Z'), junto con los totales.

**Datos de prueba:**
Base de datos con al menos 5 contratos vigentes y 2 cancelados.

---

## Caso de Uso 2: Reporte filtrado por empresa específica

**Descripción:** El usuario desea ver solo los contratos de una empresa específica.

**Precondiciones:**
El usuario conoce el número de empresa (Num_emp) y existen contratos asociados.

**Pasos a seguir:**
1. El usuario selecciona 'Por Empresa' en el filtro Selección.
2. Ingresa el número de empresa en el campo correspondiente.
3. Presiona 'Generar Reporte'.

**Resultado esperado:**
Se muestran únicamente los contratos asociados a la empresa seleccionada.

**Datos de prueba:**
Num_emp=3, existen 2 contratos para esa empresa.

---

## Caso de Uso 3: Reporte de contratos cancelados por tipo de aseo

**Descripción:** El usuario desea ver todos los contratos cancelados de un tipo de aseo específico.

**Precondiciones:**
Existen contratos cancelados con Ctrol_Aseo=5.

**Pasos a seguir:**
1. El usuario selecciona Vigencia='C' (Cancelado).
2. Ingresa Ctrol_Aseo=5.
3. Presiona 'Generar Reporte'.

**Resultado esperado:**
Se muestran solo los contratos cancelados con Ctrol_Aseo=5.

**Datos de prueba:**
Al menos 1 contrato cancelado con Ctrol_Aseo=5.

---



## Casos de Prueba

## Casos de Prueba para Reporte de Contratos

### Caso 1: Consulta general sin filtros
- **Entrada:**
  - seleccion: 1
  - Ofna: 0
  - Rep: 0
  - opcion: 1
  - Num_emp: 0
  - Ctrol_Aseo: 0
  - Vigencia: 'T'
- **Esperado:**
  - Respuesta HTTP 200
  - eResponse.success = true
  - eResponse.data.contratos contiene todos los contratos (excepto status 'Z')
  - Totales correctos

### Caso 2: Filtro por empresa
- **Entrada:**
  - seleccion: 2
  - Num_emp: 3
  - Ofna: 0
  - Rep: 0
  - opcion: 2
  - Ctrol_Aseo: 0
  - Vigencia: 'T'
- **Esperado:**
  - Solo contratos de la empresa 3
  - Totales corresponden a esa empresa

### Caso 3: Contratos cancelados de tipo de aseo específico
- **Entrada:**
  - seleccion: 1
  - Ofna: 0
  - Rep: 0
  - opcion: 3
  - Num_emp: 0
  - Ctrol_Aseo: 5
  - Vigencia: 'C'
- **Esperado:**
  - Solo contratos cancelados con Ctrol_Aseo=5
  - Totales correctos

### Caso 4: Sin resultados
- **Entrada:**
  - seleccion: 2
  - Num_emp: 9999 (empresa inexistente)
  - Ofna: 0
  - Rep: 0
  - opcion: 1
  - Ctrol_Aseo: 0
  - Vigencia: 'T'
- **Esperado:**
  - eResponse.data.contratos es array vacío
  - Totales en cero

### Caso 5: Error de parámetros
- **Entrada:**
  - eRequest: 'RptContratos'
  - params: { seleccion: 'abc' } (valor inválido)
- **Esperado:**
  - eResponse.success = false
  - Mensaje de error adecuado


