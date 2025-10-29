# Documentación Técnica: Migración de Formulario listanotificacionesfrm

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `listanotificacionesfrm` a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA) y PostgreSQL (procedimientos almacenados). El objetivo es permitir la consulta y generación de reportes de notificaciones, requerimientos y secuestros de multas, filtrando por recaudadora, año, folios y tipo de documento, con diferentes criterios de ordenamiento.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de reportes encapsulada en stored procedure `sp_listanotificaciones_report`.

## 3. Flujo de Datos
1. El usuario ingresa los filtros y opciones en la página Vue.
2. Al hacer clic en "Imprimir", se envía una petición POST a `/api/execute` con el siguiente payload:
   ```json
   {
     "eRequest": "listanotificaciones_report",
     "params": {
       "reca": 2,
       "axo": 2024,
       "inicio": 1000,
       "final": 2000,
       "tipo": "N",
       "orden": "lote"
     }
   }
   ```
3. Laravel recibe la petición, identifica el eRequest y llama al stored procedure correspondiente.
4. El resultado se retorna en el campo `data` del eResponse.
5. Vue.js muestra el resultado en tabla y el total de actas encontradas.

## 4. Stored Procedure
- **Nombre:** sp_listanotificaciones_report
- **Parámetros:**
  - p_axo: Año de la notificación
  - p_reca: Recaudadora
  - p_inicio: Folio inicial
  - p_final: Folio final
  - p_tipo: Tipo de documento ('N', 'R', 'S')
  - p_orden: Criterio de orden ('lote', 'vigentes', 'dependencia')
- **Retorna:** abrevia, axo_acta, num_acta, num_lote, folioreq
- **Lógica:** Ejecuta el SELECT adecuado según el criterio de orden.

## 5. API
- **Endpoint:** POST /api/execute
- **Request:**
  - eRequest: string (ej. 'listanotificaciones_report')
  - params: objeto con los parámetros requeridos
- **Response:**
  - success: boolean
  - data: array de resultados
  - message: string de error si aplica

## 6. Validaciones
- Todos los campos son obligatorios.
- El campo 'tipo' debe ser uno de 'N', 'R', 'S'.
- El campo 'orden' debe ser uno de 'lote', 'vigentes', 'dependencia'.

## 7. Seguridad
- El endpoint debe estar protegido por autenticación (no incluido aquí, agregar middleware si es necesario).
- Validar y sanear todos los parámetros recibidos.

## 8. Extensibilidad
- Para agregar nuevos reportes, crear nuevos stored procedures y mapearlos en el controlador.

## 9. Pruebas
- Ver sección de casos de uso y casos de prueba.
