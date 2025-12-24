# RptAdeudosEnergia

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración RptAdeudosEnergia Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el reporte de adeudos de energía eléctrica por local, migrando la lógica de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de consulta y cálculo se traslada a stored procedures en PostgreSQL, y la comunicación entre frontend y backend se realiza mediante un endpoint API unificado usando el patrón eRequest/eResponse.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 2/3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, lógica de reportes en stored procedures.

## 3. Endpoint API Unificado
- **Ruta:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": "RptAdeudosEnergia.getReport",
    "params": {
      "axo": 2024,
      "oficina": 1
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- **rpt_adeudos_energia(axo, oficina):** Devuelve el listado de adeudos, datos del local, nombre, locales adicionales, meses y adeudo total por local.
- **rpt_adeudos_energia_meses(id_energia, axo):** Devuelve los periodos (meses/bimestres) y el importe de adeudo para un id_energia y año.

## 5. Lógica de Negocio Migrada
- El cálculo de campos como `datoslocal`, `meses` y `cuota` se realiza en el stored procedure principal.
- El frontend ajusta los labels de columnas según el año y la oficina (por ejemplo, "Cuota Mes." vs "Cuota Bim.").
- El frontend muestra totales y cuenta de locales con adeudo.

## 6. Seguridad
- Validación de parámetros en el backend.
- El endpoint sólo ejecuta procedimientos conocidos.
- Se recomienda proteger el endpoint con autenticación JWT o similar en producción.

## 7. Extensibilidad
- Para agregar nuevos reportes o acciones, basta con agregar nuevos casos en el controlador y nuevos stored procedures.

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## 9. Dependencias
- Laravel 10+
- Vue.js 2/3
- PostgreSQL 12+

## 10. Notas de Migración
- Los nombres de campos y tablas deben coincidir con los de la base de datos origen.
- El procedimiento principal replica la lógica de Delphi, incluyendo la construcción de campos calculados.


## Casos de Uso

# Casos de Uso - RptAdeudosEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Energía para un Año y Oficina

**Descripción:** El usuario desea obtener el listado de adeudos de energía eléctrica para todos los locales de una oficina y año específicos.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de adeudo para el año y oficina seleccionados.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Adeudos de Energía.
2. Selecciona el año (por ejemplo, 2023) y la oficina (por ejemplo, Zona Centro).
3. Presiona el botón 'Consultar'.
4. El sistema consulta el API y muestra el listado de adeudos.

**Resultado esperado:**
Se muestra una tabla con los datos de cada local, nombre, locales adicionales, meses y adeudo total. Se muestran los totales y el número de locales con adeudo.

**Datos de prueba:**
{ "axo": 2023, "oficina": 1 }

---

## Caso de Uso 2: Validación de Etiquetas según Año y Oficina

**Descripción:** El sistema debe mostrar las etiquetas correctas para 'Cuota Mes.' o 'Cuota Bim.' y 'Mes de Adeudo' o 'Bimestre de Adeudo' según el año y la oficina.

**Precondiciones:**
El usuario accede al reporte y selecciona diferentes combinaciones de año y oficina.

**Pasos a seguir:**
1. Seleccionar oficina distinta de 5 y año mayor a 2002.
2. Consultar el reporte y verificar que las etiquetas sean 'Cuota Mes.' y 'Mes de Adeudo'.
3. Seleccionar año menor o igual a 2002 y consultar, verificar que las etiquetas cambian a 'Cuota Bim.' y 'Bimestre de Adeudo'.
4. Seleccionar oficina 5 y consultar, verificar que la columna de cuota no se muestra.

**Resultado esperado:**
Las etiquetas y columnas se ajustan dinámicamente según la lógica de negocio.

**Datos de prueba:**
{ "axo": 2001, "oficina": 2 } y { "axo": 2024, "oficina": 5 }

---

## Caso de Uso 3: Manejo de Errores por Parámetros Faltantes

**Descripción:** El sistema debe manejar adecuadamente los casos en que el usuario no proporciona los parámetros requeridos.

**Precondiciones:**
El usuario intenta consultar el reporte sin seleccionar año u oficina.

**Pasos a seguir:**
1. Dejar vacío el campo año o la oficina.
2. Presionar 'Consultar'.
3. El sistema debe mostrar un mensaje de error indicando los parámetros faltantes.

**Resultado esperado:**
El usuario recibe un mensaje claro de error y no se realiza la consulta.

**Datos de prueba:**
{ "axo": null, "oficina": 1 }

---



## Casos de Prueba

# Casos de Prueba: RptAdeudosEnergia

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Consulta exitosa de adeudos para año y oficina válidos | { "axo": 2023, "oficina": 1 } | Respuesta con success=true, data con lista de adeudos, totales correctos |
| 2 | Etiquetas correctas para año <= 2002 | { "axo": 2002, "oficina": 2 } | Etiquetas 'Cuota Bim.' y 'Bimestre de Adeudo', columna cuota visible |
| 3 | Etiquetas correctas para oficina 5 | { "axo": 2024, "oficina": 5 } | Columna cuota NO visible, etiquetas ajustadas |
| 4 | Error por falta de parámetros | { "axo": null, "oficina": 1 } | success=false, mensaje de error 'Parámetros axo y oficina requeridos' |
| 5 | Consulta de meses de adeudo por id_energia | { "eRequest": "RptAdeudosEnergia.getMeses", "params": { "id_energia": 123, "axo": 2023 } } | Lista de periodos e importes para ese id_energia y año |
| 6 | Consulta con año/oficina sin datos | { "axo": 1999, "oficina": 1 } | success=true, data vacía |



