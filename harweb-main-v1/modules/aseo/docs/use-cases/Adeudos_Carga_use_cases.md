# Casos de Uso - Adeudos_Carga

**Categoría:** Form

## Caso de Uso 1: Carga masiva de adeudos para el ejercicio actual

**Descripción:** El usuario administrador ejecuta la carga de adeudos para todos los contratos vigentes del año fiscal actual.

**Precondiciones:**
El usuario tiene permisos de administrador. El ejercicio actual no tiene adeudos generados previamente.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Adeudos.
2. Ingresa el ejercicio actual (por ejemplo, 2024) y su ID de usuario.
3. Presiona el botón 'Ejecutar Carga de Adeudos'.
4. El sistema valida los datos y ejecuta el proceso.
5. El sistema muestra un mensaje de éxito.

**Resultado esperado:**
Se generan 12 adeudos (uno por mes) para cada contrato vigente y no vigente del ejercicio seleccionado. No hay duplicados.

**Datos de prueba:**
ejercicio: 2024, usuario_id: 23

---

## Caso de Uso 2: Intento de carga de adeudos con ejercicio inválido

**Descripción:** El usuario intenta ejecutar la carga de adeudos con un año inválido (por ejemplo, 1999).

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Adeudos.
2. Ingresa el ejercicio 1999 y su ID de usuario.
3. Presiona el botón 'Ejecutar Carga de Adeudos'.

**Resultado esperado:**
El sistema rechaza la petición y muestra un mensaje de error indicando que el ejercicio es inválido.

**Datos de prueba:**
ejercicio: 1999, usuario_id: 23

---

## Caso de Uso 3: Carga de adeudos cuando ya existen pagos para el periodo

**Descripción:** El usuario ejecuta la carga de adeudos para un ejercicio donde ya existen algunos pagos generados.

**Precondiciones:**
Existen registros previos en ta_16_pagos para algunos contratos y meses del ejercicio.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Adeudos.
2. Ingresa el ejercicio correspondiente y su ID de usuario.
3. Presiona el botón 'Ejecutar Carga de Adeudos'.

**Resultado esperado:**
El sistema inserta solo los pagos que no existen, ignorando los duplicados. No se generan errores.

**Datos de prueba:**
ejercicio: 2024, usuario_id: 23 (con pagos previos en ta_16_pagos)

---

