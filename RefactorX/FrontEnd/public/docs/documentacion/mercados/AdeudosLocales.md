# AdeudosLocales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: AdeudosLocales (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js 3 (SPA), cada formulario es una página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getAdeudosLocales", // o cualquier acción soportada
    "params": { ... } // parámetros específicos
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```

## 3. Controlador Laravel
- **AdeudosLocalesController**
  - Método `execute(Request $request)`
  - Recibe el campo `action` y despacha a la lógica correspondiente.
  - Llama a los stored procedures usando DB::select('CALL ...').
  - Devuelve siempre un JSON con los campos `success`, `data`, `message`.

## 4. Componente Vue.js
- Página independiente `/adeudos-locales`.
- Formulario con año, oficina, periodo.
- Botones para consultar, exportar a Excel, imprimir.
- Tabla de resultados con todos los campos relevantes.
- Usa Axios para consumir el endpoint `/api/execute`.
- Maneja loading y errores.

## 5. Stored Procedures
- Toda la lógica de consulta y cálculo de adeudos, meses, renta, etc. está en stored procedures PostgreSQL.
- Los SPs devuelven tablas (RETURNS TABLE) para facilitar el consumo desde Laravel.

## 6. Seguridad
- El endpoint puede requerir autenticación JWT o session según configuración del proyecto.
- Validación de parámetros en el controlador.

## 7. Extensibilidad
- Para agregar nuevas acciones, solo se debe agregar un nuevo case en el controlador y el SP correspondiente.

## 8. Exportación e Impresión
- Las acciones `exportExcel` y `printReport` pueden implementarse como jobs o respuestas de archivo.
- En el demo, solo muestran un alert.

## 9. Consideraciones de Migración
- Los cálculos de campos como Renta, Meses Adeudo, etc., se realizan en el SP o en el frontend según corresponda.
- El frontend no usa tabs ni componentes tabulares: cada formulario es una página completa.

## 10. Pruebas
- Casos de uso y pruebas detalladas en las secciones siguientes.


## Casos de Uso

# Casos de Uso - AdeudosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Mercados por Año y Oficina

**Descripción:** El usuario consulta el listado de adeudos de mercados para un año, oficina y periodo específicos.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar adeudos.

**Pasos a seguir:**
1. El usuario accede a la página 'Adeudos de Mercados'.
2. Selecciona el año (por ejemplo, 2023), la oficina (por ejemplo, 2) y el periodo (por ejemplo, 5).
3. Hace clic en 'Consultar'.
4. El sistema muestra la tabla con los adeudos correspondientes.

**Resultado esperado:**
Se muestra una tabla con los adeudos de locales para los parámetros seleccionados, incluyendo control, rec, merc, cat, sección, local, letra, bloque, nombre, superficie, renta, adeudo y meses de adeudo.

**Datos de prueba:**
{ "axo": 2023, "oficina": 2, "periodo": 5 }

---

## Caso de Uso 2: Exportación de Adeudos a Excel

**Descripción:** El usuario exporta el listado de adeudos consultados a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta de adeudos y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Exportar Excel'.
2. El sistema genera y descarga un archivo Excel con los datos mostrados.

**Resultado esperado:**
Se descarga un archivo Excel con el listado de adeudos.

**Datos de prueba:**
Debe haber datos consultados previamente.

---

## Caso de Uso 3: Impresión de Reporte de Adeudos

**Descripción:** El usuario imprime el reporte de adeudos de mercados.

**Precondiciones:**
El usuario ya realizó una consulta de adeudos y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Imprimir'.
2. El sistema genera un PDF o abre una ventana de impresión con el reporte.

**Resultado esperado:**
Se muestra el reporte listo para imprimir o se descarga un PDF.

**Datos de prueba:**
Debe haber datos consultados previamente.

---



## Casos de Prueba

# Casos de Prueba: AdeudosLocales

## Caso 1: Consulta exitosa de adeudos
- **Entrada:** { "action": "getAdeudosLocales", "params": { "axo": 2023, "oficina": 2, "periodo": 5 } }
- **Esperado:**
  - success: true
  - data: lista no vacía
  - Cada fila contiene los campos requeridos

## Caso 2: Consulta con parámetros inválidos
- **Entrada:** { "action": "getAdeudosLocales", "params": { "axo": "", "oficina": null, "periodo": null } }
- **Esperado:**
  - success: false
  - message: error de validación o parámetros faltantes

## Caso 3: Exportación a Excel sin datos
- **Entrada:** { "action": "exportExcel", "params": {} }
- **Esperado:**
  - success: false o true (según implementación)
  - message: 'No hay datos para exportar' o similar

## Caso 4: Consulta de meses de adeudo
- **Entrada:** { "action": "getMesesAdeudo", "params": { "id_local": 123, "axo": 2023 } }
- **Esperado:**
  - success: true
  - data: lista de meses de adeudo para el local

## Caso 5: Consulta de renta
- **Entrada:** { "action": "getRenta", "params": { "axo": 2023, "categoria": 1, "seccion": "SS", "clave_cuota": 2 } }
- **Esperado:**
  - success: true
  - data: información de renta correspondiente



