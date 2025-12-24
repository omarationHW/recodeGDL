# Documentación Técnica: h_bloqueoDomiciliosfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario Histórico de Bloqueo de Domicilios (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde al formulario de consulta y reporte del histórico de domicilios bloqueados/desbloqueados en el sistema de licencias municipales. Permite consultar, filtrar, exportar e imprimir el historial de bloqueos y desbloqueos de domicilios, así como ver detalles de cada movimiento.

## 2. Arquitectura
- **Backend:** Laravel (PHP 8+), PostgreSQL
- **Frontend:** Vue.js (Vue 2/3), Axios para llamadas API
- **API:** Endpoint único `/api/execute` con patrón eRequest/eResponse
- **Base de datos:** PostgreSQL, lógica de negocio en stored procedures

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listar|filtrar|exportar|imprimir|detalle",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```

## 4. Métodos Disponibles
- `listar`: Lista todos los registros históricos, ordenados por el campo solicitado.
- `filtrar`: Filtra por campo y valor (ejemplo: calle, capturista, etc).
- `exportar`: Devuelve los datos en formato para exportar a Excel (el frontend genera el archivo).
- `imprimir`: Devuelve los datos en formato para impresión PDF (el frontend genera el archivo).
- `detalle`: Devuelve el detalle de un registro por ID.

## 5. Stored Procedures
Toda la lógica SQL reside en stored procedures de PostgreSQL:
- `sp_h_bloqueo_dom_listar(p_order TEXT)`
- `sp_h_bloqueo_dom_filtrar(p_campo TEXT, p_valor TEXT, p_order TEXT)`
- `sp_h_bloqueo_dom_detalle(p_id INTEGER)`

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o sesión Laravel.
- Validar permisos de usuario antes de permitir exportar/imprimir.

## 7. Frontend (Vue.js)
- Página independiente, sin tabs.
- Tabla con ordenamiento y filtro por calle.
- Botones para exportar e imprimir (emitir eventos para que el frontend genere Excel/PDF).
- Detalle histórico mostrado al seleccionar un registro.
- Breadcrumb para navegación.

## 8. Integración
- El componente Vue se comunica con el backend usando Axios.
- El backend ejecuta el stored procedure correspondiente según la acción.
- El frontend es responsable de la generación de archivos Excel/PDF a partir de los datos recibidos.

## 9. Consideraciones
- El campo `tipo_mov` se traduce a texto amigable en el frontend (Vue filter).
- El backend es agnóstico del formato de exportación; sólo entrega los datos.
- El diseño permite agregar más acciones en el futuro usando el mismo endpoint.

## 10. Ejemplo de llamada API
```js
// Listar
axios.post('/api/execute', {
  eRequest: { action: 'listar', params: { order: 'calle,num_ext' } }
});
// Filtrar
axios.post('/api/execute', {
  eRequest: { action: 'filtrar', params: { campo: 'calle', valor: 'AVENIDA', order: 'calle,num_ext' } }
});
```

## 11. Migración de lógica Delphi
- Todas las consultas SQL y ordenamientos del formulario Delphi se migran a stored procedures parametrizados.
- La exportación e impresión se realiza en el frontend, no en el backend.
- El filtro por campo se realiza usando ILIKE para búsquedas insensibles a mayúsculas/minúsculas.

## 12. Extensibilidad
- Se pueden agregar más acciones (alta, edición, eliminación) siguiendo el mismo patrón.
- El endpoint y los stored procedures pueden ser reutilizados por otros módulos.

## Casos de Prueba

# Casos de Prueba: Histórico de Bloqueo de Domicilios

## Caso 1: Consulta general
- **Acción:** listar
- **Entrada:** { "action": "listar", "params": { "order": "calle,num_ext" } }
- **Resultado esperado:** Respuesta contiene todos los registros de la tabla h_bloqueo_dom ordenados por calle y número exterior.

## Caso 2: Filtrado por calle
- **Acción:** filtrar
- **Entrada:** { "action": "filtrar", "params": { "campo": "calle", "valor": "AVENIDA", "order": "calle,num_ext" } }
- **Resultado esperado:** Respuesta contiene solo los registros donde el campo calle contiene 'AVENIDA'.

## Caso 3: Exportar a Excel
- **Acción:** exportar
- **Entrada:** { "action": "exportar", "params": { "order": "fecha DESC, hora DESC" } }
- **Resultado esperado:** Respuesta contiene los datos en formato adecuado para exportar a Excel.

## Caso 4: Imprimir PDF
- **Acción:** imprimir
- **Entrada:** { "action": "imprimir", "params": { "order": "modifico,fecha_mov DESC" } }
- **Resultado esperado:** Respuesta contiene los datos en formato adecuado para impresión PDF.

## Caso 5: Detalle de registro
- **Acción:** detalle
- **Entrada:** { "action": "detalle", "params": { "id": 123 } }
- **Resultado esperado:** Respuesta contiene el registro con id=123 de la tabla h_bloqueo_dom.

## Casos de Uso

# Casos de Uso - h_bloqueoDomiciliosfrm

**Categoría:** Form

## Caso de Uso 1: Consulta general del histórico de domicilios bloqueados

**Descripción:** El usuario accede a la página de histórico y visualiza todos los domicilios bloqueados/desbloqueados ordenados por calle y número exterior.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
[
  "El usuario navega a la página 'Histórico de Bloqueo de Domicilios'.",
  "El sistema carga automáticamente la lista completa usando la acción 'listar' con orden 'calle,num_ext'.",
  "El usuario visualiza la tabla con todos los registros históricos."
]

**Resultado esperado:**
Se muestra la tabla con todos los domicilios históricos bloqueados/desbloqueados.

**Datos de prueba:**
No se requiere dato de entrada específico.

---

## Caso de Uso 2: Filtrado por calle específica

**Descripción:** El usuario busca domicilios históricos bloqueados que contengan una calle específica.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
[
  "El usuario escribe 'AVENIDA' en el campo de búsqueda.",
  "El sistema envía la acción 'filtrar' con campo 'calle' y valor 'AVENIDA'.",
  "La tabla se actualiza mostrando solo los registros que contienen 'AVENIDA' en el campo calle."
]

**Resultado esperado:**
Solo se muestran los domicilios históricos bloqueados cuya calle contiene 'AVENIDA'.

**Datos de prueba:**
Campo de búsqueda: 'AVENIDA'

---

## Caso de Uso 3: Exportación de listado a Excel

**Descripción:** El usuario exporta el listado actual de domicilios históricos bloqueados a un archivo Excel.

**Precondiciones:**
El usuario está autenticado y tiene permisos de exportación.

**Pasos a seguir:**
[
  "El usuario hace clic en el botón 'Exportar a Excel'.",
  "El sistema envía la acción 'exportar' con el orden actual.",
  "El frontend recibe los datos y genera un archivo Excel descargable.",
  "El usuario descarga el archivo Excel."
]

**Resultado esperado:**
El usuario obtiene un archivo Excel con el listado de domicilios históricos bloqueados.

**Datos de prueba:**
No se requiere dato de entrada específico.

---
