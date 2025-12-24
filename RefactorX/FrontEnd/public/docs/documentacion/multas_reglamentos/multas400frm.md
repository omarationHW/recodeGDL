# Documentación: multas400frm

## Análisis Técnico

# Documentación Técnica: Migración Formulario multas400frm

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `multas400frm` a una arquitectura moderna basada en Laravel (API), Vue.js (frontend) y PostgreSQL (base de datos). Permite consultar registros de multas federales y municipales por diferentes criterios: acta, nombre o domicilio.

## 2. Arquitectura
- **Frontend**: Componente Vue.js independiente, página completa, sin tabs.
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón `eRequest`/`eResponse`.
- **Base de Datos**: PostgreSQL, lógica de consulta encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "multas400_search_by_acta_fed", // o el que corresponda
    "params": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```
- **eRequest posibles**:
  - multas400_search_by_acta_fed
  - multas400_search_by_nombre_fed
  - multas400_search_by_domici_fed
  - multas400_search_by_acta_mpal
  - multas400_search_by_nombre_mpal
  - multas400_search_by_domici_mpal

## 4. Stored Procedures
Cada consulta se implementa como una función PostgreSQL que retorna un conjunto de registros (`SETOF`). Los parámetros se pasan desde Laravel y se usan en la consulta SQL.

## 5. Frontend (Vue.js)
- Página única, con formulario para seleccionar tipo de multa y criterios de búsqueda.
- Botones para buscar por acta, nombre o domicilio.
- Resultados en tabla dinámica.
- Manejo de errores y estados de carga.

## 6. Seguridad
- Todas las consultas son de solo lectura.
- Los parámetros se validan en el backend.
- No se exponen detalles internos de la base de datos.

## 7. Consideraciones
- El LIKE en PostgreSQL es case-sensitive, por eso se usa UPPER() para búsquedas insensibles a mayúsculas/minúsculas.
- El frontend espera que los stored procedures devuelvan los mismos campos que las tablas originales.

## 8. Extensibilidad
- Se pueden agregar nuevos criterios de búsqueda creando nuevos stored procedures y mapeando nuevos `eRequest` en el controlador.

## 9. Pruebas
- Se recomienda probar con datos reales y casos límite (sin resultados, datos inválidos, etc).

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 3.x
- PostgreSQL >= 12

## Casos de Uso

# Casos de Uso - multas400frm

**Categoría:** Form

## Caso de Uso 1: Consulta de multa federal por acta

**Descripción:** El usuario desea consultar una multa federal específica usando dependencia, año y número de acta.

**Precondiciones:**
El registro existe en la tabla multas_fed_400.

**Pasos a seguir:**
1. Ingresar 'dependencia' (ej: 'DIRECCION1').
2. Ingresar 'año de acta' (ej: 2023).
3. Ingresar 'número de acta' (ej: 12345).
4. Seleccionar 'Multas Federales'.
5. Presionar 'Por Acta'.

**Resultado esperado:**
Se muestra el registro correspondiente en la tabla de resultados.

**Datos de prueba:**
{ "dependencia": "DIRECCION1", "anioActa": 2023, "numActa": 12345 }

---

## Caso de Uso 2: Búsqueda de multas municipales por nombre

**Descripción:** El usuario busca todas las multas municipales asociadas a un nombre.

**Precondiciones:**
Existen registros en multas_mpal_400 con el nombre buscado.

**Pasos a seguir:**
1. Seleccionar 'Multas Municipales'.
2. Ingresar 'nombre' (ej: 'JUAN PEREZ').
3. Presionar 'Por Nombre'.

**Resultado esperado:**
Se listan todas las multas municipales cuyo nombre coincida.

**Datos de prueba:**
{ "nombre": "JUAN PEREZ" }

---

## Caso de Uso 3: Búsqueda de multas federales por domicilio inexistente

**Descripción:** El usuario busca multas federales por un domicilio que no existe.

**Precondiciones:**
No existen registros con ese domicilio.

**Pasos a seguir:**
1. Seleccionar 'Multas Federales'.
2. Ingresar 'ubicación' (ej: 'CALLE FALSA 123').
3. Presionar 'Por Domicilio'.

**Resultado esperado:**
Se muestra mensaje de 'No se encontraron resultados'.

**Datos de prueba:**
{ "ubicacion": "CALLE FALSA 123" }

---

## Casos de Prueba

# Casos de Prueba para multas400frm

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|--------------------|
| TC01 | Consulta multa federal por acta existente | dependencia: 'DIRECCION1', anioActa: 2023, numActa: 12345 | Se muestra el registro correcto |
| TC02 | Consulta multa federal por acta inexistente | dependencia: 'NOEXISTE', anioActa: 2022, numActa: 99999 | No se muestran resultados |
| TC03 | Búsqueda municipal por nombre parcial | nombre: '%PEREZ%' | Se listan todas las coincidencias |
| TC04 | Búsqueda federal por domicilio exacto | ubicacion: 'AV. INDEPENDENCIA 100' | Se muestran los registros coincidentes |
| TC05 | Búsqueda municipal por domicilio inexistente | ubicacion: 'CALLE INVENTADA 999' | Mensaje de 'No se encontraron resultados' |
| TC06 | Error de parámetros (falta de campo requerido) | dependencia: '', anioActa: '', numActa: '' | Mensaje de error en la consulta |
| TC07 | Consulta con caracteres especiales | nombre: 'O\'CONNOR' | Se muestran los registros coincidentes o mensaje de error si hay fallo de escape |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

