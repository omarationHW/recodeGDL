# AdeGlobalLocales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Adeudo Global con Accesorios

## Descripción General
Este módulo permite consultar y exportar el listado de locales con adeudo global y accesorios (multas y gastos) y también los locales sin adeudo pero con accesorios, filtrando por oficina, mercado, año y mes. Incluye integración con Vue.js como página independiente, backend Laravel con API unificada y lógica SQL encapsulada en stored procedures PostgreSQL.

## Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## Flujo de Datos
1. El usuario selecciona oficina, mercado, año y mes en la página Vue.
2. Vue llama a `/api/execute` con acción y parámetros.
3. Laravel Controller enruta la acción y llama al stored procedure correspondiente.
4. El resultado se retorna a Vue y se muestra en tablas.
5. Exportación a Excel se realiza en frontend o backend según implementación.

## Endpoints API
- **POST /api/execute**
  - **action:** Nombre de la acción (ej: `getAdeGlobalLocales`)
  - **params:** Parámetros requeridos por la acción

### Ejemplo de Request
```json
{
  "action": "getAdeGlobalLocales",
  "params": {
    "office_id": 1,
    "market_id": 14,
    "year": 2024,
    "month": 6
  }
}
```

### Ejemplo de Response
```json
{
  "success": true,
  "data": [
    { "id_local": 123, "oficina": 1, ... }
  ],
  "message": ""
}
```

## Stored Procedures
- **sp_get_ade_global_locales:** Devuelve locales con adeudo y accesorios.
- **sp_get_locales_sin_adeudo_con_accesorios:** Devuelve locales sin adeudo pero con accesorios.

## Seguridad
- Validar que los parámetros sean correctos y el usuario tenga permisos.
- Sanitizar entradas en el backend.

## Consideraciones
- El frontend debe manejar errores y mostrar mensajes claros.
- El backend debe registrar errores en logs.
- La exportación a Excel puede implementarse en backend (generando archivo y retornando URL) o frontend (usando librerías JS).

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el mismo patrón.
- Los stored procedures pueden ser extendidos para nuevos reportes.


## Casos de Uso

# Casos de Uso - AdeGlobalLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudo Global con Accesorios

**Descripción:** El usuario consulta el listado de locales con adeudo global y accesorios para una oficina y mercado específicos.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página 'Adeudo Global con Accesorios'.
2. Selecciona la oficina 'Zona Centro'.
3. Selecciona el mercado '14 - Mercado Abastos'.
4. Selecciona el año 2024 y mes 6.
5. Hace clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los locales que tienen adeudo y accesorios para los filtros seleccionados.

**Datos de prueba:**
office_id: 1, market_id: 14, year: 2024, month: 6

---

## Caso de Uso 2: Exportar a Excel el listado de locales con adeudo

**Descripción:** El usuario exporta a Excel el listado de locales con adeudo global y accesorios.

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Excel 1'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos mostrados en la tabla de locales con adeudo.

**Datos de prueba:**
office_id: 1, market_id: 14, year: 2024, month: 6

---

## Caso de Uso 3: Consulta de Locales sin Adeudo pero con Accesorios

**Descripción:** El usuario consulta el listado de locales que no tienen adeudo pero sí accesorios.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página 'Adeudo Global con Accesorios'.
2. Selecciona la oficina y mercado deseados.
3. Selecciona año y mes.
4. Hace clic en 'Locales sin Adeudo con Accesorios'.

**Resultado esperado:**
Se muestra una tabla con los locales sin adeudo pero con accesorios.

**Datos de prueba:**
market_id: 14, year: 2024, month: 6

---



## Casos de Prueba

# Casos de Prueba: Adeudo Global con Accesorios

## Caso 1: Consulta exitosa de locales con adeudo
- **Entrada:** office_id=1, market_id=14, year=2024, month=6
- **Acción:** Buscar
- **Resultado esperado:** Lista de locales con adeudo y accesorios, campos: oficina, mercado, categoria, seccion, local, nombre, adeudo, recargos, multa, gastos.

## Caso 2: Consulta sin resultados
- **Entrada:** office_id=1, market_id=99, year=2024, month=6 (mercado inexistente)
- **Acción:** Buscar
- **Resultado esperado:** Tabla vacía, mensaje 'No hay resultados'.

## Caso 3: Exportar a Excel
- **Precondición:** Hay resultados en la tabla
- **Acción:** Click en 'Excel 1'
- **Resultado esperado:** Descarga de archivo Excel con los mismos datos de la tabla.

## Caso 4: Consulta de locales sin adeudo pero con accesorios
- **Entrada:** market_id=14, year=2024, month=6
- **Acción:** Click en 'Locales sin Adeudo con Accesorios'
- **Resultado esperado:** Tabla con locales sin adeudo pero con accesorios.

## Caso 5: Validación de campos obligatorios
- **Entrada:** No seleccionar oficina o mercado
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error 'Seleccione oficina y mercado'.



