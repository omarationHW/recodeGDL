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

