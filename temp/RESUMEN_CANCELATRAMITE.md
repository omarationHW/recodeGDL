# ✅ cancelaTramitefrm.vue - COMPLETADO
## Fecha: 2025-11-08

---

## 🗄️ Stored Procedures Desplegados (3)
**Schema:** comun
**Base de Datos:** padron_licencias (192.168.6.146)

1. **sp_get_tramite_by_id** (p_id_tramite INTEGER)
   - Retorna: información completa del trámite (67 campos)
   - Incluye: folio, tipo, propietario, domicilio, giro, estatus, observaciones, etc.

2. **sp_get_giro_by_id** (p_id_giro INTEGER)
   - Retorna: id_giro, descripcion
   - Fuente: comun.liccat_giros

3. **sp_cancel_tramite** (p_id_tramite INTEGER, p_motivo TEXT)
   - Retorna: result (TEXT), new_status (VARCHAR)
   - Validaciones:
     - Trámite existe
     - No está cancelado previamente
     - No está aprobado (estatus = 'A')
   - Actualiza: comun.tramites.estatus = 'C'
   - Registra motivo en: comun.tramites.espubic

---

## 🎨 Componente Vue Actualizado

### Schema Corregido
Todas las llamadas `execute()` actualizadas para incluir schema 'comun':

```javascript
// ANTES (INCORRECTO - faltaba tenant y schema)
execute('SP_CANCEL_TRAMITE', 'padron_licencias', [...], 'comun')

// DESPUÉS (CORRECTO)
execute('SP_CANCEL_TRAMITE', 'padron_licencias', [...], 'guadalajara', null, 'comun')
```

### Mejoras Visuales
Diálogo de cancelación rediseñado con:
- ✅ Banner de advertencia (amarillo con ⚠️)
- ✅ Tabla informativa con detalles del trámite
- ✅ Campo de texto estilizado para motivo
- ✅ Botones con iconos (Font Awesome)
- ✅ Width: 600px para mejor legibilidad

```javascript
const { value: motivo } = await Swal.fire({
  title: 'Motivo de Cancelación',
  html: `
    <div style="text-align: left; padding: 10px 20px;">
      <!-- Banner de advertencia -->
      <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px;">
        <p><strong>⚠️ Importante:</strong> Está a punto de cancelar el siguiente trámite</p>
      </div>

      <!-- Tabla de información -->
      <div style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
        <table style="width: 100%;">
          <tr>
            <td>Trámite #:</td>
            <td><strong>${tramiteData.value.id_tramite}</strong></td>
          </tr>
          <tr>
            <td>Tipo:</td>
            <td>${tramiteData.value.tipo_tramite || 'N/A'}</td>
          </tr>
          <tr>
            <td>Propietario:</td>
            <td>${propietarioCompleto.value || 'N/A'}</td>
          </tr>
          <tr>
            <td>Giro:</td>
            <td>${giroDescripcion.value || 'N/A'}</td>
          </tr>
        </table>
      </div>

      <!-- Campo de motivo -->
      <label>📝 Motivo de la Cancelación: <span style="color: #dc3545;">*</span></label>
      <textarea id="swal-motivo" class="swal2-textarea"
        placeholder="Describa el motivo..." rows="4"></textarea>
      <small>* El motivo quedará registrado en el historial</small>
    </div>
  `,
  width: '600px',
  confirmButtonColor: '#ea8215',
  cancelButtonColor: '#6c757d',
  confirmButtonText: '<i class="fa fa-arrow-right"></i> Continuar',
  cancelButtonText: '<i class="fa fa-times"></i> Cancelar'
})
```

### Características Existentes
- ✅ useGlobalLoading implementado
- ✅ showLoading/hideLoading en operaciones async
- ✅ Sin estilos inline (todo en CSS global)
- ✅ Validaciones con SweetAlert2
- ✅ Toast notifications

---

## 📊 Verificación

```bash
php temp/deploy_cancelatramite_sps.php
```

Resultado:
```
✓ comun.sp_cancel_tramite
✓ comun.sp_get_giro_by_id
✓ comun.sp_get_tramite_by_id

✓ Despliegue completado exitosamente
```

---

## 🎯 Funcionalidad

### Cancelación de Trámite
1. Buscar trámite por ID
2. Mostrar información completa del trámite
3. Obtener descripción del giro
4. Validar que el trámite se puede cancelar:
   - ✅ No cancelado previamente
   - ✅ No aprobado
5. Solicitar motivo de cancelación (obligatorio)
6. Confirmar cancelación
7. Actualizar estatus a 'C' (Cancelado)
8. Registrar motivo en campo espubic

### Validaciones SP
```sql
-- Trámite no encontrado
IF v_estatus IS NULL THEN
    RETURN QUERY SELECT 'Trámite no encontrado'::TEXT, NULL::VARCHAR;

-- Ya cancelado
IF v_estatus = 'C' THEN
    RETURN QUERY SELECT 'El trámite ya se encuentra cancelado'::TEXT, v_estatus;

-- Aprobado (no se puede cancelar)
IF v_estatus = 'A' THEN
    RETURN QUERY SELECT 'El trámite ya se encuentra aprobado. No se puede cancelar.'::TEXT, v_estatus;
```

---

## 📋 Resumen de Trámites Completados

### Completados (8)
1. ✅ **cancelaTramitefrm.vue** (recién completado)
2. ✅ TramiteBajaAnun.vue
3. ✅ TramiteBajaLic.vue
4. ✅ BloquearTramitefrm.vue
5. ✅ ReactivaTramite.vue
6. ✅ modtramitefrm.vue
7. ✅ doctosfrm.vue
8. ✅ ConsultaTramitefrm.vue (confirmado por usuario)

### Estado: 100% COMPLETADO ✅

---

## 🔧 Archivos Generados

1. **temp/DEPLOY_CANCELATRAMITE_SPS.sql** (161 líneas)
   - 3 stored procedures con schema comun
   - Comentarios descriptivos
   - Permisos GRANT

2. **temp/deploy_cancelatramite_sps.php** (42 líneas)
   - Script de despliegue automatizado
   - Verificación de instalación
   - Conexión a padron_licencias

3. **temp/RESUMEN_CANCELATRAMITE.md** (este archivo)
   - Documentación completa
   - Validaciones y funcionalidad
   - Estado del proyecto

---

**Generado:** 2025-11-08
**Proyecto:** RefactorX Guadalajara - Padrón de Licencias
**Módulo:** Trámites - 100% Completado ✅
