# Documentación Técnica: Migración de BloquearLicenciafrm (Delphi) a Laravel + Vue.js + PostgreSQL

## ✅ Estado de Revisión
**Última revisión:** 05/11/2025
**Estado:** ✅ REVISADO Y FUNCIONAL
**Revisor:** Claude Code
**Notas de revisión:**
- ✅ Todos los Stored Procedures creados y verificados en esquema `catastro_gdl`
- ✅ Frontend actualizado con formato correcto de requests (wrapper `eRequest`)
- ✅ Operaciones completamente funcionales: búsqueda, bloqueo, desbloqueo, historial
- ✅ 7 SPs implementados: sp_buscar_licencia, sp_tipobloqueo_list, sp_consultar_historial_licencia, sp_consultar_historial_licencia_paginado, sp_bloquear_licencia, sp_desbloquear_licencia, sp_validar_bloqueo_licencia
- ✅ Backend corriendo en: http://localhost:8001
- ✅ Frontend corriendo en: http://localhost:5179
- ✅ 9 tipos de bloqueo disponibles: BLOQUEADA, CABARET, DESGLOSAR LIC, ESTADO 1, INACTIVAS SIN PAGO, PARA REFRENDO, RESPONSIVA, SOLVENTACION, SUSPENSION

---

## 1. Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica de negocio crítica en stored procedures)
- **Patrón de integración:** eRequest/eResponse (payload JSON con acción y datos)

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "nombreAccion",
    "payload": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "message": "...",
    "data": { ... }
  }
  ```

## 3. Flujo de Bloqueo/Desbloqueo
- El usuario busca una licencia por número.
- El sistema muestra los datos de la licencia y su estado actual.
- El usuario puede:
  - Bloquear la licencia (seleccionando tipo y motivo)
  - Desbloquear la licencia (seleccionando el bloqueo activo y motivo)
- El sistema registra el movimiento en la tabla `bloqueo` y actualiza el campo `bloqueado` en `licencias`.
- Si aplica, también bloquea/desbloquea el domicilio en `bloqueo_dom`.

## 4. Seguridad
- Todas las operaciones requieren usuario autenticado (JWT o session).
- El usuario que realiza la acción queda registrado en los movimientos.

## 5. Stored Procedures
- Toda la lógica de bloqueo/desbloqueo está en los SPs `sp_bloquear_licencia` y `sp_desbloquear_licencia`.
- El controlador Laravel solo valida y llama a los SPs.

## 6. Frontend
- El componente Vue es una página completa, sin tabs.
- Permite buscar, bloquear y desbloquear licencias.
- Muestra histórico y bloqueos activos.
- Usa fetch/AJAX para interactuar con `/api/execute`.

## 7. Catálogos
- El catálogo de tipos de bloqueo se obtiene vía la acción `catalogoTipoBloqueo`.

## 8. Consideraciones de Integridad
- No se permite bloquear una licencia ya bloqueada.
- No se permite desbloquear si no hay bloqueos activos.
- El SP asegura atomicidad y consistencia.

## 9. Convenciones
- Todas las fechas se manejan en formato ISO (YYYY-MM-DD).
- Los mensajes de error son claros y orientados al usuario final.

## 10. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones de licencias.

---

# Estructura de Tablas Relacionadas
- **licencias**: id_licencia, bloqueado, ...
- **bloqueo**: id, id_licencia, bloqueado, observa, capturista, fecha_mov, vigente
- **c_tipobloqueo**: id, descripcion
- **bloqueo_dom**: ... (domicilios bloqueados)
- **h_bloqueo_dom**: ... (histórico de domicilios bloqueados)

---

# Ejemplo de Request/Response
## Bloquear licencia
```json
POST /api/execute
{
  "action": "bloquearLicencia",
  "payload": {
    "id_licencia": 12345,
    "tipo_bloqueo": 1,
    "motivo": "Incumplimiento de requisitos"
  }
}
```

## Respuesta
```json
{
  "success": true,
  "message": "Licencia bloqueada correctamente"
}
```

---

# Notas
- El frontend debe refrescar el estado tras cada operación.
- El backend valida todos los parámetros antes de ejecutar los SP.
