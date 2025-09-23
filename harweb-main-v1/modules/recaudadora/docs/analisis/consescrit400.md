# Documentación Técnica: Migración Formulario consescrit400 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite consultar registros de pagos de escrituras provenientes del sistema AS400, migrando la funcionalidad de Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend) y PostgreSQL (Base de datos).

## 2. Arquitectura
- **Backend**: Laravel API con endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: PostgreSQL, lógica de consulta encapsulada en stored procedures.

## 3. Flujo de Consulta
1. El usuario ingresa criterios de búsqueda:
   - Por Municipio, Notario y Escritura **O**
   - Por Folio y Fecha
2. El frontend envía una petición POST a `/api/execute` con `action` y `params`.
3. El backend identifica la acción y llama el stored procedure correspondiente.
4. El resultado se retorna en formato JSON.
5. El frontend muestra los resultados en una tabla o un mensaje si no hay datos.

## 4. Endpoint API
- **URL**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "consescrit400_search",
    "params": {
      "mpio": 0,
      "notario": 0,
      "escritura": 0,
      "folio": 1234,
      "fecha": 20240101
    }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 5. Stored Procedures
- `sp_consescrit400_search_by_folio_fecha(folio, fecha)`
- `sp_consescrit400_search_by_mpio_notario_escritura(mpio, notario, escritura)`

## 6. Validaciones
- Si Municipio, Notario y Escritura son 0, se busca por Folio y Fecha.
- Si cualquiera de Municipio, Notario o Escritura es distinto de 0, se busca por esos tres campos.
- Si no se ingresa ningún criterio válido, se muestra mensaje de error.

## 7. Seguridad
- El endpoint requiere autenticación (agregar middleware si es necesario).
- Validar y sanear los parámetros recibidos.

## 8. Frontend
- Página Vue.js independiente, sin tabs.
- Navegación breadcrumb.
- Campos numéricos con navegación por teclado (Enter).
- Tabla de resultados responsiva.
- Mensajes claros de error y éxito.

## 9. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.

## 10. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser optimizados o extendidos según necesidades futuras.
