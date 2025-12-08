# Documentación Técnica: Semaforo

## Análisis Técnico

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

## Casos de Prueba

# Casos de Prueba para Formulario Semáforo

## Caso 1: Generar color aleatorio
- **Entrada:**
  - action: getRandomColor
  - params: { user_id: 1 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.color = 'ROJO' o 'VERDE'
  - eResponse.data.numcolor entre 1 y 100

## Caso 2: Registrar resultado válido
- **Entrada:**
  - action: registerColorResult
  - params: { tramite_id: 123, color: 'VERDE', user_id: 1 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.message = 'Resultado registrado'

## Caso 3: Registrar resultado con color inválido
- **Entrada:**
  - action: registerColorResult
  - params: { tramite_id: 123, color: 'AZUL', user_id: 1 }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message contiene 'color'

## Caso 4: Consultar estadísticas
- **Entrada:**
  - action: getStats
  - params: { user_id: 1 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.rojos >= 0
  - eResponse.data.verdes >= 0

## Caso 5: Registrar resultado sin tramite_id
- **Entrada:**
  - action: registerColorResult
  - params: { color: 'VERDE', user_id: 1 }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message contiene 'tramite_id'

## Casos de Uso

# Casos de Uso - Semaforo

**Categoría:** Form

## Caso de Uso 1: Caso de Uso 1: Generar y Registrar Resultado de Semáforo

**Descripción:** El usuario inicia el semáforo, obtiene un color aleatorio y registra el resultado para un trámite.

**Precondiciones:**
El usuario está autenticado y tiene acceso al formulario Semáforo.

**Pasos a seguir:**
- El usuario accede a la página Semáforo.
- Presiona el botón 'Iniciar'.
- El sistema muestra un color (ROJO o VERDE) y el número generado.
- El usuario presiona 'Aceptar' para registrar el resultado.
- El sistema guarda el resultado en la base de datos.

**Resultado esperado:**
El resultado del semáforo se registra correctamente y se actualizan las estadísticas.

**Datos de prueba:**
{ "user_id": 1, "tramite_id": 123 }

---

## Caso de Uso 2: Caso de Uso 2: Consultar Estadísticas de Semáforo

**Descripción:** El usuario consulta cuántos resultados rojos y verdes ha obtenido.

**Precondiciones:**
El usuario ha registrado al menos un resultado de semáforo.

**Pasos a seguir:**
- El usuario accede a la página Semáforo.
- El sistema muestra automáticamente las estadísticas de rojos y verdes.

**Resultado esperado:**
Se muestran los conteos correctos de rojos y verdes para el usuario.

**Datos de prueba:**
{ "user_id": 1 }

---

## Caso de Uso 3: Caso de Uso 3: Validación de Parámetros al Registrar Resultado

**Descripción:** El sistema valida que los parámetros requeridos estén presentes y sean válidos al registrar un resultado.

**Precondiciones:**
El usuario intenta registrar un resultado con parámetros incompletos o inválidos.

**Pasos a seguir:**
- El usuario envía una petición para registrar resultado sin 'tramite_id' o con un color inválido.
- El sistema valida los parámetros.

**Resultado esperado:**
El sistema responde con un mensaje de error indicando el parámetro faltante o inválido.

**Datos de prueba:**
{ "color": "AZUL", "user_id": 1 }

---


