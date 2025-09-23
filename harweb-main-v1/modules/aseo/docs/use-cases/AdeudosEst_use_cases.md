# Casos de Uso - AdeudosEst

**Categoría:** Form

## Caso de Uso 1: Consulta de estadístico de pagos para un año completo

**Descripción:** El usuario desea obtener el reporte de pagos realizados (cuota normal, excedente, contenedores) para todos los meses del año 2023.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de pagos en 2023.

**Pasos a seguir:**
1. Ingresar año inicial: 2023, mes inicial: 1
2. Ingresar año final: 2023, mes final: 12
3. Hacer clic en 'Ejecutar'

**Resultado esperado:**
Se muestra una tabla con 12 filas (una por mes), mostrando los totales de cada tipo de pago por periodo.

**Datos de prueba:**
{ "aso_in": 2023, "mes_in": 1, "aso_fin": 2023, "mes_fin": 12 }

---

## Caso de Uso 2: Consulta de estadístico de pagos para un solo mes

**Descripción:** El usuario desea ver los pagos realizados únicamente en marzo de 2024.

**Precondiciones:**
El usuario tiene acceso y existen pagos en marzo 2024.

**Pasos a seguir:**
1. Ingresar año inicial: 2024, mes inicial: 3
2. Ingresar año final: 2024, mes final: 3
3. Hacer clic en 'Ejecutar'

**Resultado esperado:**
Se muestra una sola fila con los totales de cada tipo de pago para marzo 2024.

**Datos de prueba:**
{ "aso_in": 2024, "mes_in": 3, "aso_fin": 2024, "mes_fin": 3 }

---

## Caso de Uso 3: Validación de error por periodo inválido

**Descripción:** El usuario intenta consultar un periodo donde el año final es menor que el inicial.

**Precondiciones:**
El usuario tiene acceso.

**Pasos a seguir:**
1. Ingresar año inicial: 2024, mes inicial: 5
2. Ingresar año final: 2023, mes final: 12
3. Hacer clic en 'Ejecutar'

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el periodo es inválido.

**Datos de prueba:**
{ "aso_in": 2024, "mes_in": 5, "aso_fin": 2023, "mes_fin": 12 }

---

