# Documentación Técnica: Migración Formulario Semáforo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8.1+), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 (SPA), cada formulario es una página independiente.
- **Base de datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse (entrada y salida en JSON).

## 2. Endpoints y Flujo
- **POST /api/execute**
  - Entrada: `{ "eRequest": { "action": "nombre_accion", "params": { ... } } }`
  - Salida: `{ "eResponse": { ... } }`
- **Acciones soportadas:**
  - `getRandomColor`: Devuelve color aleatorio y número generado.
  - `registerColorResult`: Registra resultado del semáforo para un trámite.
  - `getStats`: Devuelve estadísticas de rojos y verdes por usuario.

## 3. Controlador Laravel
- Un solo controlador (`SemaforoController`) maneja todas las acciones.
- Cada acción llama a un método privado que puede usar DB::select o DB::statement para invocar los stored procedures.
- Validación de parámetros con Validator.
- Manejo de errores y logging.

## 4. Componente Vue.js
- Página independiente (`SemaforoPage.vue`).
- No usa tabs ni subcomponentes.
- Muestra dos círculos (rojo y verde), botón de iniciar, estadísticas y botón de aceptar.
- Llama al endpoint `/api/execute` para todas las acciones.
- Usa variables reactivas para estado, resultado y estadísticas.

## 5. Stored Procedures PostgreSQL
- Toda la lógica de negocio SQL se implementa en stored procedures:
  - `sp_semaforo_get_random_color()`: Devuelve color y número.
  - `sp_semaforo_register_color_result(tramite_id, color, user_id)`: Inserta resultado.
  - `sp_semaforo_get_stats(user_id)`: Devuelve conteo de rojos y verdes.
- La tabla `semaforo_tramites` debe existir con campos: id, tramite_id, color, user_id, created_at.

## 6. API Unificada
- Todas las acciones del formulario usan el endpoint `/api/execute`.
- El frontend envía la acción y parámetros en `eRequest`.
- El backend responde en `eResponse`.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o Laravel Sanctum.
- Validar que el usuario tenga permisos para registrar resultados.

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para QA.

## 9. Consideraciones de Migración
- No se usan tabs ni componentes tabulares.
- Cada formulario es una página Vue.js independiente.
- El backend es desacoplado y solo expone el endpoint `/api/execute`.
- Toda la lógica SQL reside en stored procedures.

## 10. Ejemplo de tabla semaforo_tramites
```sql
CREATE TABLE semaforo_tramites (
  id SERIAL PRIMARY KEY,
  tramite_id INT NOT NULL,
  color VARCHAR(10) NOT NULL,
  user_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```
