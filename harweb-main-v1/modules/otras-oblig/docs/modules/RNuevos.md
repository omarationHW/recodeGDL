# Documentación Técnica: Migración Formulario RNuevos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (sin tabs).
- **Backend**: Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "action": "RNuevos.create",
    "params": {
      "par_tabla": "3",
      "par_control": "123-A",
      ...
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```

## 3. Stored Procedure Principal
- **sp_ins34_rastro_01**: Inserta nuevo local/concesión, valida unicidad, retorna código y mensaje.
- **Parámetros**: ver definición en sección de stored procedures.
- **Retorno**: `expression` (0=OK, 1=Error), `expression_1` (mensaje).

## 4. Validaciones Frontend
- Número de local obligatorio y único.
- Concesionario, superficie, licencia, año obligatorios.
- Año debe ser actual o anterior inmediato.
- Superficie > 0.

## 5. Flujo de Alta
1. Usuario llena formulario.
2. Frontend valida campos.
3. Consulta API si el control ya existe.
4. Si no existe, llama a API para crear.
5. Backend ejecuta stored procedure.
6. Retorna resultado y mensaje.

## 6. Seguridad
- Validación de datos en backend y frontend.
- El endpoint debe requerir autenticación (no incluido aquí por simplicidad).

## 7. Extensibilidad
- El endpoint `/api/execute` permite agregar más acciones fácilmente.
- Los formularios pueden crecer sin modificar la estructura API.

## 8. Errores y Mensajes
- Todos los errores de negocio se retornan en `expression_1` y se muestran al usuario.

## 9. Consideraciones de Migración
- Los combos de tipo local se llenan dinámicamente desde la base de datos.
- Los valores por defecto de recaudadora, sector y zona se fijan según el formulario original.

## 10. Pruebas
- Ver sección de casos de uso y casos de prueba.
