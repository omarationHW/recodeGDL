# Documentación Técnica: Migración de RptAdeudosConvDiversos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte de "Adeudos Convenios Diversos". Permite consultar, filtrar y exportar información de convenios diversos (predial, licencias, mercados, etc.) agrupados por zona, tipo, subtipo y estado, mostrando el saldo, pagos y recargos de cada convenio.

## 2. Arquitectura
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de Datos:** PostgreSQL (todas las consultas y lógica SQL encapsuladas en stored procedures)
- **Patrón API:** eRequest/eResponse (JSON)

## 3. Flujo de Datos
1. El usuario accede a la página de reporte y selecciona los filtros (tipo, subtipo, zona, estado, fecha de corte).
2. Al enviar el formulario, el frontend realiza una petición POST a `/api/execute` con el eRequest correspondiente.
3. El backend (Laravel) recibe la petición, identifica la acción (`getRptAdeudosConvDiversos`), ejecuta el stored procedure adecuado y retorna los datos en eResponse.
4. El frontend muestra los resultados en una tabla, permitiendo exportar a CSV/PDF.

## 4. Endpoint Unificado
- **URL:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "getRptAdeudosConvDiversos",
      "params": {
        "tipo": 1,
        "subtipo": 1,
        "letras": "ZC1",
        "estado": "A",
        "fecha": "2024-06-30"
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": "",
      "errors": []
    }
  }
  ```

## 5. Stored Procedures
- Toda la lógica de consulta y agregación está en funciones PostgreSQL (`rpt_adeudos_conv_diversos`, `rpt_adeudos_conv_diversos_detalle`, `rpt_adeudos_conv_diversos_resumen`).
- Los SPs reciben parámetros de filtro y retornan tablas con los datos requeridos.

## 6. Seguridad
- El endpoint requiere autenticación (Laravel Sanctum/JWT recomendado).
- Validación de parámetros y control de acceso por usuario.

## 7. Frontend
- El componente Vue es una página completa, sin tabs, con navegación breadcrumb.
- Permite seleccionar filtros, consultar y exportar resultados.
- El diseño es responsivo y accesible.

## 8. Extensibilidad
- Para agregar nuevos reportes, basta con crear el SP correspondiente y mapear la acción en el controlador.
- El frontend puede agregar nuevas páginas para otros reportes siguiendo el mismo patrón.

## 9. Consideraciones de Migración
- Todos los queries Delphi se migran a SPs/funcones PostgreSQL.
- El API es desacoplado: el frontend nunca accede directo a tablas, sólo a través de `/api/execute`.
- El patrón eRequest/eResponse permite versionar y auditar las acciones.

## 10. Ejemplo de Uso
- El usuario selecciona: Tipo = Predial, Subtipo = Urbano, Zona = ZC1, Estado = Vigente, Fecha = 2024-06-30.
- El sistema retorna todos los convenios diversos de predial urbano, zona centro, vigentes al 30 de junio de 2024, con sus saldos y pagos.

---
