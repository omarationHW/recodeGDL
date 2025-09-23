# Documentación Técnica: Migración de Formulario sdmWebService (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este sistema permite consultar información de predios a través de un WebService SOAP, procesar la respuesta XML, almacenar los datos en PostgreSQL y exponer la funcionalidad mediante una API RESTful y una interfaz web Vue.js.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8+), PostgreSQL
- **Frontend:** Vue.js 2/3 (SPA o multipágina)
- **Integración externa:** WebService SOAP (consultaPredio)
- **API:** Endpoint único `/api/execute` bajo patrón eRequest/eResponse

## 3. Flujo de Proceso
1. El usuario ingresa el ID Predial y la opción en la interfaz Vue.js.
2. Vue.js envía la petición a `/api/execute` con el action `consultaPredio` y los datos requeridos.
3. Laravel recibe la petición, valida los datos y construye el XML de consulta.
4. Laravel consume el WebService SOAP (`consultaPredio`).
5. El XML de respuesta es parseado y convertido a un array de predios.
6. Los datos se almacenan en la tabla `predio_virtual` mediante el SP `sp_insert_predio_virtual`.
7. La respuesta se retorna al frontend en formato JSON.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "consultaPredio",
      "data": {
        "s_idpredial": "<valor>",
        "s_opcion": "<valor>"
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "status": "success|error",
      "message": "Mensaje de resultado",
      "data": [ { ...predio... } ]
    }
  }
  ```

## 5. Stored Procedures y Tablas
- **Tabla:** `predio_virtual` (ver definición SQL)
- **SP:** `sp_insert_predio_virtual(json_data json)`
  - Inserta los predios recibidos en formato JSON.
  - Limpia la tabla antes de insertar (comportamiento temporal, puede ajustarse según requerimientos).

## 6. Seguridad
- Validación de datos en backend y frontend.
- Manejo de errores y logs en Laravel.
- SOAPClient configurado para evitar inyecciones.

## 7. Frontend
- Página Vue.js independiente para la consulta de predios.
- Formulario simple, tabla de resultados, mensajes de error y loading.
- Navegación breadcrumb.

## 8. Configuración
- El WSDL del WebService puede configurarse en `config/services.php`:
  ```php
  'sdmwebservice' => [
      'wsdl' => env('SDM_WEBSERVICE_WSDL', 'http://192.168.17.90:1888/EJBMpredio/SeBePredio?wsdl'),
  ],
  ```

## 9. Consideraciones
- El SP limpia la tabla antes de insertar para simular el comportamiento de TVirtualTable (temporal). Puede adaptarse a lógica de actualización o inserción incremental.
- El XML recibido puede variar; el parser debe adaptarse si la estructura cambia.
- El endpoint es extensible para otras acciones siguiendo el patrón eRequest/eResponse.

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba.
