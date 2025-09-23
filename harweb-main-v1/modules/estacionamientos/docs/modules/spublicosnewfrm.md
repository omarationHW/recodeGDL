# Documentación Técnica: Migración de Formulario spublicosnewfrm

## 1. Arquitectura General
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js (SPA, cada formulario es una página)
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de datos:** PostgreSQL, toda la lógica de negocio crítica en stored procedures

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": { ... } | null,
    "error": "mensaje de error" | null
  }
  ```

### Acciones soportadas:
- `buscar_persona_rfc` (params: { rfc })
- `listar_categorias` (params: {})
- `ultimo_num_estacionamiento` (params: {})
- `consultar_predio` (params: { dato })
- `costo_forma` (params: {})
- `alta_estacionamiento` (params: {...})
- `alta_adeudo_forma` (params: {...})

## 3. Stored Procedures
- Toda la lógica de inserción y consulta relevante está en stored procedures (ver sección correspondiente).
- Los SPs devuelven siempre un resultado estructurado (result/resultstr/idnvo, etc).

## 4. Frontend (Vue.js)
- Cada formulario es una página independiente (NO tabs).
- Navegación por rutas, breadcrumbs incluidos.
- El formulario de alta de estacionamiento público replica la lógica y validaciones del Delphi original.
- Modal para mapa del predio (iframe).
- Mensajes de éxito/error claros.

## 5. Seguridad
- Validación de parámetros en backend y frontend.
- El usuario (movto_usr, id_usuario) debe obtenerse del contexto de sesión real (aquí se usa 1 como ejemplo).

## 6. Consideraciones
- El endpoint `/api/execute` es el único punto de entrada para todas las operaciones.
- El frontend debe manejar los flujos de selección de RFC, búsqueda de predio, y alta de estacionamiento de forma secuencial.
- Los SPs pueden ser extendidos para lógica adicional (auditoría, validaciones, etc).

## 7. Pruebas
- Casos de uso y pruebas incluidas para asegurar la funcionalidad completa.
