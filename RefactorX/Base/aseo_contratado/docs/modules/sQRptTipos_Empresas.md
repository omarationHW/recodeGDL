# Documentación Técnica: Migración de Formulario sQRptTipos_Empresas

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `sQRptTipos_Empresas` al stack Laravel + Vue.js + PostgreSQL. El objetivo es mostrar un catálogo de tipos de empresas, permitiendo al usuario seleccionar el criterio de ordenamiento (por número de control, tipo o descripción).

## 2. Arquitectura
- **Backend:** Laravel expone un endpoint único `/api/execute` que recibe un `eRequest` y parámetros. La lógica de negocio y acceso a datos se delega a stored procedures en PostgreSQL.
- **Frontend:** Un componente Vue.js independiente, que consume el endpoint y muestra los datos en una tabla, permitiendo cambiar el criterio de ordenamiento.
- **Base de Datos:** Toda la lógica SQL se encapsula en stored procedures. El SP principal es `sp_get_tipos_empresas`.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "getTiposEmpresas",
    "params": { "opcion": 1 }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_get_tipos_empresas`
- **Parámetro:** `opcion` (integer)
  - 1: Ordenar por `ctrol_emp`
  - 2: Ordenar por `tipo_empresa`
  - 3: Ordenar por `descripcion`
- **Retorno:** SETOF ta_16_tipos_emp (todas las columnas)

## 5. Frontend (Vue.js)
- Página independiente, con breadcrumb y tabla de resultados.
- Selector para cambiar el criterio de ordenamiento.
- Muestra la fecha/hora de impresión.

## 6. Seguridad
- El endpoint debe protegerse con autenticación (no incluida en este ejemplo, pero recomendable en producción).
- Validar que el parámetro `opcion` esté en el rango permitido.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevos casos de uso sin modificar la ruta del endpoint.
- Los stored procedures pueden evolucionar sin afectar el frontend.

## 8. Consideraciones de Migración
- Los nombres de campos y tablas deben coincidir con la estructura original.
- El SP puede adaptarse si la tabla cambia de nombre o estructura.

## 9. Dependencias
- Laravel >= 8
- Vue.js >= 2.6 (o 3.x, según el proyecto)
- PostgreSQL >= 10

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba.
