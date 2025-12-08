# Documentación Técnica: GirosDconAdeudofrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario GirosDconAdeudo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de reporte de giros restringidos con adeudos anteriores, migrado desde Delphi a una arquitectura moderna usando Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El acceso a la funcionalidad se realiza mediante un endpoint API unificado y un componente Vue.js de página completa.

## 2. Arquitectura
- **Backend:** Laravel 10+, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js (SPA o multipágina), componente independiente
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en stored procedure

## 3. Flujo de Datos
1. El usuario ingresa el año del adeudo y presiona "Imprimir".
2. El frontend envía una petición POST a `/api/execute` con `eRequest: 'GirosDconAdeudoReport'` y el año en el payload.
3. El backend ejecuta el stored procedure `report_giros_dcon_adeudo(p_year)` en PostgreSQL.
4. El resultado se retorna en el campo `data` del eResponse.
5. El frontend muestra el reporte en tabla y permite imprimirlo.

## 4. Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "GirosDconAdeudoReport",
    "payload": { "year": 2022 }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": "Datos encontrados.",
    "errors": []
  }
  ```

## 5. Stored Procedure
- **Nombre:** `report_giros_dcon_adeudo(p_year INTEGER)`
- **Tipo:** REPORT
- **Descripción:** Devuelve licencias con adeudo desde el año especificado, incluyendo nombre, ubicación y giro.
- **Parámetro:** `p_year` (año del adeudo)
- **Retorno:** Tabla con columnas: licencia, propietario, propietarionvo, domCompleto, descripcion, axo

## 6. Componente Vue.js
- Página independiente con ruta propia
- Formulario para año del adeudo
- Tabla de resultados con totales
- Botón para imprimir el reporte
- Mensajes de error y estado

## 7. Seguridad
- Validación de parámetros en frontend y backend
- Manejo de errores y mensajes claros
- El endpoint puede protegerse con middleware de autenticación según la política del sistema

## 8. Consideraciones de Migración
- El reporte Delphi usaba componentes visuales y BDE; ahora todo es vía API y SPA
- El SQL original fue adaptado a sintaxis PostgreSQL y encapsulado en un stored procedure
- El frontend es responsivo y amigable

## 9. Extensibilidad
- El endpoint unificado permite agregar más reportes y procesos usando el mismo patrón eRequest/eResponse
- El stored procedure puede ser optimizado o extendido según necesidades futuras

## 10. Dependencias
- Laravel 10+
- Vue.js 2/3
- PostgreSQL 12+
- Bootstrap 4+ (para estilos en el ejemplo)

---

## Casos de Prueba

# Casos de Prueba: GirosDconAdeudo

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Consulta exitosa con datos | year: 2022 | Respuesta success=true, data con registros, message='Datos encontrados.' |
| TC02 | Consulta sin datos | year: 1999 | Respuesta success=true, data vacía, message='No se encontraron licencias...' |
| TC03 | Año inválido (menor a 1900) | year: 1800 | Respuesta success=false, error='Ingrese un año válido.' |
| TC04 | Año inválido (mayor a 2100) | year: 2200 | Respuesta success=false, error='Ingrese un año válido.' |
| TC05 | Sin parámetro year | (no year) | Respuesta success=false, error='El año del adeudo es requerido.' |
| TC06 | eRequest no soportado | eRequest: 'UnknownRequest' | Respuesta success=false, error='eRequest no soportado.' |
| TC07 | Error de base de datos | year: 'texto' | Respuesta success=false, error interno del servidor |

**Notas:**
- Todos los casos deben probarse tanto desde el frontend como vía API directa.
- Para TC01 y TC02, verificar que los datos coincidan con la base de datos real.
- Para TC03 y TC04, la validación debe ocurrir en frontend y backend.
- Para TC06, probar con un eRequest inexistente.

## Casos de Uso

# Casos de Uso - GirosDconAdeudofrm

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte para año con adeudos existentes

**Descripción:** El usuario desea obtener el reporte de giros restringidos con adeudos para un año en el que existen registros.

**Precondiciones:**
El usuario tiene acceso al sistema y existen licencias con adeudo en el año 2022.

**Pasos a seguir:**
1. El usuario accede a la página de reporte de giros restringidos con adeudos.
2. Ingresa el año '2022' en el campo correspondiente.
3. Presiona el botón 'Imprimir'.
4. El sistema consulta el reporte y muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra una tabla con las licencias, nombres, ubicaciones, giros y el total de giros con adeudo desde 2022.

**Datos de prueba:**
year: 2022

---

## Caso de Uso 2: Consulta de reporte para año sin adeudos

**Descripción:** El usuario consulta el reporte para un año en el que no existen licencias con adeudo.

**Precondiciones:**
El usuario tiene acceso al sistema y no existen licencias con adeudo en el año 1999.

**Pasos a seguir:**
1. El usuario accede a la página de reporte.
2. Ingresa el año '1999'.
3. Presiona 'Imprimir'.

**Resultado esperado:**
El sistema muestra el mensaje 'No se encontraron licencias...'.

**Datos de prueba:**
year: 1999

---

## Caso de Uso 3: Validación de año inválido

**Descripción:** El usuario intenta consultar el reporte ingresando un año inválido (por ejemplo, 1800).

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de reporte.
2. Ingresa el año '1800'.
3. Presiona 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el año es inválido.

**Datos de prueba:**
year: 1800

---
