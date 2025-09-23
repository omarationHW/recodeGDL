# Casos de Uso - CancelacionMasiva

**Categoría:** Form

## Caso de Uso 1: Cancelación masiva estándar

**Descripción:** El usuario ejecuta la cancelación masiva con el criterio estándar de 2 parcialidades vencidas.

**Precondiciones:**
El usuario tiene permisos de acceso y existen convenios con al menos 2 parcialidades vencidas.

**Pasos a seguir:**
1. El usuario accede a la página de Cancelación Masiva.
2. Verifica el número de parcialidades vencidas (por defecto 2).
3. Presiona 'Ejecutar Cancelación'.
4. El sistema ejecuta el proceso y muestra el número de convenios cancelados.

**Resultado esperado:**
Los convenios incumplidos son cancelados y listados en la tabla. Se muestra un mensaje de éxito.

**Datos de prueba:**
Convenios con 2 o más parcialidades vencidas, usuario: admin

---

## Caso de Uso 2: Cancelación masiva con criterio personalizado

**Descripción:** El usuario desea cancelar convenios con 3 parcialidades vencidas.

**Precondiciones:**
El usuario tiene permisos y existen convenios con 3 o más parcialidades vencidas.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Cambia el valor de 'Parcialidades vencidas' a 3.
3. Presiona 'Ejecutar Cancelación'.
4. El sistema ejecuta el proceso y muestra el resultado.

**Resultado esperado:**
Solo los convenios con 3 o más parcialidades vencidas son cancelados.

**Datos de prueba:**
Convenios con 3 parcialidades vencidas, usuario: supervisor

---

## Caso de Uso 3: Visualización de convenios cancelados

**Descripción:** El usuario consulta la lista de convenios cancelados en el día.

**Precondiciones:**
Existen convenios cancelados hoy.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Presiona 'Refrescar Lista'.
3. El sistema muestra la tabla con los convenios cancelados.

**Resultado esperado:**
Se visualiza la lista actualizada de convenios cancelados.

**Datos de prueba:**
Convenios cancelados hoy, usuario: auditor

---

