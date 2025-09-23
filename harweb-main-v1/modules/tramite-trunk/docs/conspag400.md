# Documentación Técnica: Migración Formulario conspag400 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `conspag400` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es consultar los pagos realizados en el AS400 filtrando por recaudadora, UR y cuenta.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, página independiente `/conspag400`.
- **Backend:** Laravel API, endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedure `sp_conspag400`.

## 3. Flujo de Datos
1. El usuario ingresa los parámetros (recaud, urbrus, cuenta) y presiona "Buscar".
2. El frontend envía una petición POST a `/api/execute` con `{ action: 'conspag400_query', params: { recaud, urbrus, cuenta } }`.
3. El backend ejecuta el stored procedure `sp_conspag400` con los parámetros recibidos.
4. El resultado se retorna en formato JSON, mostrando los pagos encontrados o un mensaje si no existen.

## 4. Detalles Técnicos
### 4.1. Endpoint API
- **Ruta:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "conspag400_query",
    "params": {
      "recaud": 123,
      "urbrus": 1,
      "cuenta": 456789
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": "Pagos encontrados"
  }
  ```

### 4.2. Stored Procedure
- **Nombre:** `sp_conspag400`
- **Parámetros:**
  - `p_recaud` (integer)
  - `p_urbrus` (integer)
  - `p_cuenta` (integer)
- **Retorna:** Tabla con los campos de la tabla `pagos_400`.

### 4.3. Frontend
- Página Vue.js independiente.
- Validación de campos obligatorios.
- Navegación por teclado (Enter para avanzar entre campos).
- Mensajes de información y error.
- Tabla responsive para mostrar resultados.

## 5. Seguridad
- Validación de parámetros en backend.
- No se exponen detalles internos de la base de datos.
- El endpoint es genérico, pero sólo permite acciones implementadas.

## 6. Consideraciones
- El endpoint puede ser extendido para otras acciones.
- El stored procedure puede ser optimizado para incluir paginación si la tabla crece mucho.

## 7. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11

## 8. Pruebas
Ver sección de casos de uso y casos de prueba.
