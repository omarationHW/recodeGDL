# PLAN DE HOMOGENEIZACIÓN DE ESTILOS - MÓDULO MERCADOS

## Objetivo
Migrar todos los componentes Vue del módulo Mercados al estándar municipal-theme.css basándose en el patrón de consultausuariosfrm.vue

## Patrón de Referencia
**Archivo:** `RefactorX/FrontEnd/src/views/modules/padron_licencias/consultausuariosfrm.vue`

### Elementos Clave del Patrón

#### 1. Estructura HTML
```html
<div class="module-view">
  <div class="module-view-header">
    <div class="module-view-icon">
      <font-awesome-icon icon="icono" />
    </div>
    <div class="module-view-info">
      <h1>Título</h1>
      <p>Descripción</p>
    </div>
    <div class="button-group ms-auto">
      <!-- Botones de acción -->
    </div>
  </div>

  <div class="module-view-content">
    <!-- Contenido -->
  </div>
</div>
```

#### 2. Cards
```html
<div class="municipal-card">
  <div class="municipal-card-header">
    <h5><font-awesome-icon icon="filter" /> Título</h5>
  </div>
  <div class="municipal-card-body">
    <!-- Contenido -->
  </div>
</div>
```

#### 3. Tablas
```html
<table class="municipal-table">
  <thead class="municipal-table-header">
    <tr>
      <th>Columna</th>
    </tr>
  </thead>
  <tbody>
    <tr class="row-hover">
      <td>Dato</td>
    </tr>
  </tbody>
</table>
```

#### 4. Paginación
- Estándar: 10 registros por página
- Opciones: 5, 10, 25, 50, 100
- Clase: `pagination-controls`
- Componentes: `pagination-info`, `pagination-size`, `pagination-buttons`

#### 5. Botones
- `btn-municipal-primary` (naranja #ea8215)
- `btn-municipal-secondary` (dorado #cc9f52)
- `btn-municipal-purple` (morado #9264cc)
- `btn-municipal-danger` (rojo)

#### 6. Inputs
- `municipal-form-control` para inputs/selects
- `municipal-form-label` para labels
- Clase `form-row` para agrupar campos
- Clase `form-group` para cada campo individual

#### 7. Loading
```javascript
import { useGlobalLoading } from '@/composables/useGlobalLoading'
const { showLoading, hideLoading } = useGlobalLoading()

// Uso:
showLoading('Cargando...', 'Por favor espere')
hideLoading()
```

#### 8. Toast Notifications
```javascript
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()

// Uso:
showToast('success', 'Mensaje')
showToast('warning', 'Advertencia')
showToast('error', 'Error')
showToast('info', 'Información')
```

#### 9. SweetAlert
```javascript
import Swal from 'sweetalert2'

await Swal.fire({
  icon: 'question',
  title: '¿Confirmar?',
  text: 'Mensaje',
  showCancelButton: true,
  confirmButtonColor: '#ea8215',
  cancelButtonColor: '#6c757d',
  confirmButtonText: 'Sí, continuar',
  cancelButtonText: 'Cancelar'
})
```

#### 10. Modales
```html
<Modal
  :show="showModal"
  size="xl"
  @close="cerrarModal"
  :showDefaultFooter="false"
>
  <template #header>
    <h5 class="modal-title">Título</h5>
  </template>

  <!-- Contenido -->

  <div class="modal-actions">
    <button class="btn-municipal-secondary" @click="cerrar">
      <font-awesome-icon icon="times" />
      Cancelar
    </button>
    <button class="btn-municipal-primary" @click="guardar">
      <font-awesome-icon icon="save" />
      Guardar
    </button>
  </div>
</Modal>
```

## Componentes a Migrar (100+ archivos)

### Componentes Principales (18 componentes con SP funcionando)
1. ✅ ConsRequerimientos.vue
2. ✅ AltaPagos.vue
3. ✅ CargaPagEspecial.vue
4. ✅ CargaPagMercado.vue
5. ✅ CargaPagosTexto.vue (si existe)
6. ✅ ConsultaGeneral.vue
7. ✅ DatosIndividuales.vue
8. ✅ EnergiaModif.vue (si existe)
9. ✅ Estadisticas.vue (si existe)
10. ✅ LocalesMtto.vue
11. ✅ PagosIndividual.vue
12. ✅ Prescripcion.vue (si existe)
13. ✅ RptEmisionRbosAbastos.vue (si existe)
14. ✅ RptFacturaEmision.vue
15. ✅ RptFacturaEnergia.vue (si existe)
16. ✅ RptMovimientos.vue

### Componentes Adicionales (resto de archivos)
17. AdeEnergiaGrl.vue
18. AdeudosLocGrl.vue
19. RecaudadorasMercados.vue
20. AdeudosEnergia.vue
... (100+ componentes en total)

## Reglas de Migración

### ✅ HACER:
1. Migrar estilos inline/scoped a clases de municipal-theme.css
2. Implementar loading con useGlobalLoading()
3. Implementar toast notifications
4. Usar SweetAlert para confirmaciones
5. Asegurar paginación de 10 registros por defecto
6. Validar tablas paginadas (server side si es posible)
7. Modales para detalles/edición
8. Íconos de FontAwesome
9. Estructura consistente: module-view → header + content
10. Cards para secciones

### ❌ NO HACER:
1. NO cambiar lógica de negocio
2. NO modificar llamadas a API
3. NO alterar composables existentes (solo agregar nuevos)
4. NO cambiar nombres de props/emits
5. NO eliminar funcionalidad existente
6. NO modificar stored procedures
7. NO cambiar estructura de datos
8. NO alterar validaciones de negocio

## Estrategia de Implementación

### Fase 1: Componentes Prioritarios (18 componentes)
Migrar los 18 componentes con SPs funcionando

### Fase 2: Componentes Secundarios (resto)
Migrar componentes restantes en grupos de 10

### Enfoque de Agentes

#### Agente 1: StyleMigrator
- **Función**: Aplicar estilos municipales a un componente
- **Input**: Ruta del componente Vue
- **Output**: Componente actualizado con estilos municipales
- **Validaciones**:
  - Mantener lógica existente
  - Aplicar clases correctas
  - Implementar loading/toast
  - Agregar paginación si hay tabla

#### Agente 2: StyleVerifier
- **Función**: Verificar que los cambios sean correctos
- **Input**: Ruta del componente migrado
- **Output**: Lista de errores o confirmación OK
- **Validaciones**:
  - Verificar clases municipales aplicadas
  - Verificar estructura module-view
  - Verificar paginación en tablas
  - Verificar loading implementado
  - Verificar toast implementado
  - Verificar que lógica no cambió

#### Proceso:
1. StyleMigrator procesa componente
2. StyleVerifier valida cambios
3. Si hay errores, StyleMigrator corrige
4. Loop hasta que StyleVerifier apruebe
5. Pasar al siguiente componente

## Checklist por Componente

- [ ] Estructura `module-view` implementada
- [ ] Header con ícono + título + botones
- [ ] Cards con `municipal-card`
- [ ] Tablas con `municipal-table`
- [ ] Paginación con estándar de 10
- [ ] Botones con clases `btn-municipal-*`
- [ ] Inputs con `municipal-form-control`
- [ ] Loading con `useGlobalLoading()`
- [ ] Toast con `useLicenciasErrorHandler()`
- [ ] SweetAlert para confirmaciones
- [ ] Modales con componente Modal
- [ ] Sin estilos inline/scoped
- [ ] Lógica sin cambios
- [ ] API calls sin cambios
- [ ] Funcionalidad preservada

## Orden de Prioridad

### Alta Prioridad (Componentes con SPs funcionando):
1. ConsRequerimientos
2. AltaPagos
3. CargaPagEspecial
4. CargaPagMercado
5. ConsultaGeneral
6. DatosIndividuales
7. LocalesMtto
8. PagosIndividual
9. RptMovimientos

### Media Prioridad:
10-30. Componentes de reportes (Rpt*)
31-50. Componentes de consultas (Cons*)
51-70. Componentes de carga (Carga*)

### Baja Prioridad:
70-100+. Componentes auxiliares, mantenimientos, etc.

## Notas Importantes

- Los estilos están en: `RefactorX/FrontEnd/src/styles/municipal-theme.css`
- Archivo de referencia: `RefactorX/FrontEnd/src/views/modules/padron_licencias/consultausuariosfrm.vue`
- NO modificar archivos SQL o stored procedures
- NO cambiar composables existentes (excepto importar nuevos)
- Mantener compatibilidad con API existente
- Validar en navegador después de cada cambio batch
