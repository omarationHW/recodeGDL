# Documentación Técnica: Migración Formulario Prueba (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario "Prueba" de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos y stored procedures). El objetivo es mantener la lógica funcional original, pero adaptada a mejores prácticas web y desacoplamiento frontend-backend.

## 2. Arquitectura
- **Backend**: Laravel API, endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Vue.js SPA, componente de página independiente para el formulario Prueba.
- **Base de Datos**: PostgreSQL, lógica de negocio encapsulada en stored procedures.

## 3. Flujo de Datos
1. El usuario ingresa un valor de control (`parCtrol`) y envía el formulario.
2. El frontend llama a `/api/execute` con `{ action: 'prueba_query', params: { parCtrol } }`.
3. El backend ejecuta el stored procedure `sp_prueba_query` y retorna los resultados.
4. Para cada resultado, el usuario puede consultar la licencia de giro asociada, lo que dispara otra llamada a `/api/execute` con `{ action: 'licencia_giro_f1', params: { p_tipo, p_numero } }`.
5. El backend ejecuta el stored procedure `sp16_licenciagiro_f1` y retorna el resultado.

## 4. API Unificada
- **Endpoint**: `POST /api/execute`
- **Entrada**:
  - `action`: Nombre de la acción a ejecutar (string)
  - `params`: Parámetros específicos de la acción (object)
- **Salida**:
  - `status`: 'success' | 'error'
  - `message`: Mensaje informativo
  - `data`: Datos de respuesta (array/object)

## 5. Stored Procedures
- Toda la lógica SQL se encapsula en stored procedures para desacoplar la lógica de negocio de la aplicación.
- Los procedimientos devuelven tablas (TABLE) para facilitar el consumo desde Laravel.

## 6. Vue.js Frontend
- El componente es una página completa, no un tab.
- Incluye navegación breadcrumb.
- Permite consultar y mostrar resultados, así como consultar información adicional por fila.
- El memo muestra el JSON de resultados para depuración.

## 7. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel, no incluido aquí).
- Validación de parámetros en backend.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden evolucionar sin cambiar la API.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad.

## 10. Notas de Migración
- El formulario original usaba componentes visuales y lógica procedural. En la migración, la lógica se desacopla y se orienta a servicios.
- El stored procedure de licencia de giro es una simulación; debe adaptarse a la lógica real de negocio si es necesario.
