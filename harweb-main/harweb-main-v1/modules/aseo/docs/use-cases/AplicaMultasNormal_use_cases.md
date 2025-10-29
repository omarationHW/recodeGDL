# Casos de Uso - AplicaMultasNormal

**Categoría:** Form

## Caso de Uso 1: Consulta de configuración actual de aplicación de multas normales

**Descripción:** El usuario accede a la página para visualizar la configuración vigente de aplicación de requerimientos normales.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
1. El usuario navega a la página 'Aplicación Normal de Requerimientos para Cobro'.
2. El sistema realiza una petición a /api/execute con action 'get_aplicareq'.
3. El sistema muestra la descripción, si aplica y el porcentaje actual.

**Resultado esperado:**
La página muestra los valores actuales de la configuración.

**Datos de prueba:**
No se requiere data específica, solo que exista al menos una fila en ta_aplicareq.

---

## Caso de Uso 2: Cambio a aplicación normal (sin porcentaje)

**Descripción:** El usuario decide que la aplicación debe ser normal (sin descuento) y guarda el cambio.

**Precondiciones:**
El usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario selecciona la opción 'SI' en la radio de aplicación.
2. El usuario deja el campo porcentaje en 0 (o vacío).
3. El usuario pulsa 'Guardar Cambios'.
4. El sistema envía action 'update_aplicareq' con aplica='S', porc=0.

**Resultado esperado:**
El sistema actualiza la configuración y muestra el mensaje 'La Aplicación Normal Realizada'.

**Datos de prueba:**
aplica: 'S', porc: 0

---

## Caso de Uso 3: Cambio a no aplicación normal con porcentaje

**Descripción:** El usuario decide que la aplicación no será normal y debe aplicar un porcentaje de descuento.

**Precondiciones:**
El usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario selecciona la opción 'NO' en la radio de aplicación.
2. El usuario ingresa un valor mayor a 0 en el campo porcentaje (ejemplo: 25).
3. El usuario pulsa 'Guardar Cambios'.
4. El sistema envía action 'update_aplicareq' con aplica='N', porc=25.

**Resultado esperado:**
El sistema actualiza la configuración y muestra el mensaje 'La NO Aplicación Normal CON PORCENTAJE Realizada'.

**Datos de prueba:**
aplica: 'N', porc: 25

---

