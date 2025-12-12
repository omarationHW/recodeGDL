<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="database" />
      </div>
      <div class="module-view-info">
        <h1>Control de Importación Catastral</h1>
        <p>Aseo Contratado - Sincronización y validación con el padrón catastral municipal</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Estadísticas Dashboard -->
      <div class="stats-dashboard mb-4">
        <div class="stat-item stat-primary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="file-contract" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.total_contratos || 0 }}</div>
            <div class="stat-label-mini">Contratos Registrados</div>
          </div>
        </div>

        <div class="stat-item stat-success">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="check-circle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.sincronizados || 0 }}</div>
            <div class="stat-label-mini">Sincronizados ({{ porcentajeSincronizados }}%)</div>
          </div>
        </div>

        <div class="stat-item stat-warning">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="exclamation-triangle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.desincronizados || 0 }}</div>
            <div class="stat-label-mini">Desincronizados</div>
          </div>
        </div>

        <div class="stat-item stat-danger">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="times-circle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.sin_cuenta || 0 }}</div>
            <div class="stat-label-mini">Sin Cuenta Catastral</div>
          </div>
        </div>
      </div>

      <!-- Acciones Rápidas -->
      <div class="row g-3 mb-4">
        <div class="col-md-4">
          <div class="action-card">
            <div class="action-card-icon bg-primary">
              <font-awesome-icon icon="sync" size="2x" />
            </div>
            <div class="action-card-content">
              <h5 class="action-card-title">Verificar Sincronización</h5>
              <p class="action-card-description">
                Compara los datos de contratos con el padrón catastral y detecta diferencias.
              </p>
              <button
                class="btn-municipal-primary w-100"
                @click="verificarSincronizacion"
                :disabled="cargando"
              >
                <font-awesome-icon :icon="cargando ? 'spinner' : 'play'" :spin="cargando" />
                {{ cargando ? 'Procesando...' : 'Ejecutar Verificación' }}
              </button>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="action-card">
            <div class="action-card-icon bg-success">
              <font-awesome-icon icon="cloud-download-alt" size="2x" />
            </div>
            <div class="action-card-content">
              <h5 class="action-card-title">Actualizar desde Catastro</h5>
              <p class="action-card-description">
                Sincroniza automáticamente domicilios y propietarios desde el padrón catastral.
              </p>
              <button
                class="btn-municipal-primary w-100"
                @click="actualizarDesdeCatastro"
                :disabled="cargando"
              >
                <font-awesome-icon :icon="cargando ? 'spinner' : 'download'" :spin="cargando" />
                {{ cargando ? 'Actualizando...' : 'Ejecutar Actualización' }}
              </button>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="action-card">
            <div class="action-card-icon bg-info">
              <font-awesome-icon icon="file-excel" size="2x" />
            </div>
            <div class="action-card-content">
              <h5 class="action-card-title">Generar Reporte</h5>
              <p class="action-card-description">
                Exporta un reporte detallado en Excel de todas las inconsistencias encontradas.
              </p>
              <button
                class="btn-municipal-info w-100"
                @click="generarReporte"
                :disabled="cargando || resultados.length === 0"
              >
                <font-awesome-icon icon="file-excel" />
                Generar Reporte Excel
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados de la Verificación -->
      <div v-if="resultados.length > 0" class="municipal-card mb-4">
        <div class="municipal-card-header">
          <div class="d-flex justify-content-between align-items-center">
            <h5 class="mb-0">
              <font-awesome-icon icon="list-check" class="me-2" />
              Resultados: {{ tipoOperacion }}
            </h5>
            <div>
              <span class="badge badge-primary me-2">{{ resultados.length }} registros</span>
              <button class="btn-municipal-secondary btn-sm" @click="limpiarResultados">
                <font-awesome-icon icon="times" />
                Limpiar
              </button>
            </div>
          </div>
        </div>

        <div class="municipal-card-body p-0">
          <!-- Filtros rápidos -->
          <div class="p-3 border-bottom">
            <div class="row g-2">
              <div class="col-md-3">
                <input
                  type="text"
                  class="municipal-form-control municipal-form-control-sm"
                  v-model="filtroContrato"
                  placeholder="Buscar por contrato..."
                >
              </div>
              <div class="col-md-3">
                <select class="municipal-form-control municipal-form-control-sm" v-model="filtroTipo">
                  <option value="">Todos los estados</option>
                  <option value="SINCRONIZADO">Sincronizados</option>
                  <option value="DIFERENCIA_NOMBRE">Diferencia en Nombre</option>
                  <option value="DIFERENCIA_DOMICILIO">Diferencia en Domicilio</option>
                  <option value="SIN_CUENTA">Sin Cuenta</option>
                  <option value="NO_EXISTE_CATASTRO">No Existe en Catastro</option>
                </select>
              </div>
              <div class="col-md-6 text-end">
                <small class="text-muted">
                  Mostrando {{ resultadosFiltrados.length }} de {{ resultados.length }} registros
                </small>
              </div>
            </div>
          </div>

          <!-- Tabla de resultados -->
          <div class="table-responsive" style="max-height: 500px; overflow-y: auto;">
            <table class="municipal-table">
              <thead class="municipal-table-header" style="position: sticky; top: 0; z-index: 10;">
                <tr>
                  <th style="width: 100px;">Contrato</th>
                  <th style="width: 140px;">Cuenta Catastral</th>
                  <th>Contribuyente Contrato</th>
                  <th>Propietario Catastro</th>
                  <th style="width: 150px;">Status</th>
                  <th>Observaciones</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="item in resultadosFiltrados"
                  :key="item.control_contrato"
                  :class="getRowClass(item.tipo_diferencia)"
                >
                  <td><strong>{{ item.num_contrato }}</strong></td>
                  <td><code class="text-muted">{{ item.cuenta_catastral }}</code></td>
                  <td>{{ item.contribuyente }}</td>
                  <td>{{ item.propietario_catastro || '-' }}</td>
                  <td>
                    <span class="badge" :class="getStatusBadge(item.tipo_diferencia)">
                      <font-awesome-icon :icon="getStatusIcon(item.tipo_diferencia)" class="me-1" />
                      {{ formatTipoDiferencia(item.tipo_diferencia) }}
                    </span>
                  </td>
                  <td><small class="text-muted">{{ item.observaciones }}</small></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Estado vacío cuando no hay resultados -->
      <div v-else-if="!cargando" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="search" size="4x" />
        </div>
        <h4>No hay resultados</h4>
        <p class="text-muted">
          Ejecuta una verificación para comparar los contratos con el padrón catastral
        </p>
      </div>

      <!-- Log del Proceso -->
      <div v-if="logProceso.length > 0" class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="mb-0">
            <font-awesome-icon icon="terminal" class="me-2" />
            Log del Proceso
            <button
              class="btn-municipal-secondary btn-sm float-end"
              @click="logProceso = []"
            >
              <font-awesome-icon icon="trash" />
              Limpiar Log
            </button>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="log-viewer">
            <div
              v-for="(log, index) in logProceso"
              :key="index"
              class="log-entry"
              :class="'log-' + log.tipo"
            >
              <span class="log-time">[{{ log.hora }}]</span>
              <font-awesome-icon :icon="getLogIcon(log.tipo)" class="log-icon" />
              <span class="log-message">{{ log.mensaje }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      v-if="mostrarAyuda"
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Control de Importación Catastral"
    >
      <div class="documentation-content">
        <h6><font-awesome-icon icon="info-circle" class="me-2" />Descripción</h6>
        <p>
          Herramienta para mantener sincronizados los datos de contratos de aseo
          con el padrón catastral municipal.
        </p>

        <h6><font-awesome-icon icon="cogs" class="me-2" />Operaciones Disponibles</h6>
        <ul class="list-unstyled">
          <li class="mb-2">
            <strong><font-awesome-icon icon="sync" class="text-primary me-2" />Verificar Sincronización:</strong>
            Identifica contratos con datos diferentes a catastro
          </li>
          <li class="mb-2">
            <strong><font-awesome-icon icon="cloud-download-alt" class="text-success me-2" />Actualizar desde Catastro:</strong>
            Sincroniza domicilios y propietarios automáticamente
          </li>
          <li class="mb-2">
            <strong><font-awesome-icon icon="file-excel" class="text-info me-2" />Generar Reporte:</strong>
            Exporta listado de inconsistencias encontradas
          </li>
        </ul>

        <h6><font-awesome-icon icon="tags" class="me-2" />Tipos de Diferencias</h6>
        <div class="row g-2">
          <div class="col-md-6">
            <div class="p-2 border rounded">
              <span class="badge bg-success me-2">SINCRONIZADO</span>
              <small>Datos coinciden con catastro</small>
            </div>
          </div>
          <div class="col-md-6">
            <div class="p-2 border rounded">
              <span class="badge bg-warning me-2">DIFERENCIA_NOMBRE</span>
              <small>Nombre de contribuyente diferente</small>
            </div>
          </div>
          <div class="col-md-6">
            <div class="p-2 border rounded">
              <span class="badge bg-info me-2">DIFERENCIA_DOMICILIO</span>
              <small>Domicilio diferente</small>
            </div>
          </div>
          <div class="col-md-6">
            <div class="p-2 border rounded">
              <span class="badge bg-danger me-2">SIN_CUENTA</span>
              <small>Contrato sin cuenta catastral</small>
            </div>
          </div>
        </div>

        <div class="alert alert-info mt-3">
          <font-awesome-icon icon="lightbulb" class="me-2" />
          <strong>Recomendación:</strong> Ejecute la verificación periódicamente para mantener
          la integridad de los datos. Las actualizaciones automáticas solo afectan domicilios
          y nombres, no datos del servicio.
        </div>
      </div>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Ctrol_Imp_Cat'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()
const { showLoading, hideLoading } = useGlobalLoading()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const estadisticas = ref({})
const resultados = ref([])
const logProceso = ref([])
const tipoOperacion = ref('')
const filtroContrato = ref('')
const filtroTipo = ref('')

// Computed
const porcentajeSincronizados = computed(() => {
  const total = estadisticas.value.total_contratos || 0
  if (total === 0) return 0
  const sincronizados = estadisticas.value.sincronizados || 0
  return Math.round((sincronizados / total) * 100)
})

const resultadosFiltrados = computed(() => {
  let filtered = resultados.value

  if (filtroContrato.value) {
    filtered = filtered.filter(r =>
      r.num_contrato?.toLowerCase().includes(filtroContrato.value.toLowerCase()) ||
      r.cuenta_catastral?.toLowerCase().includes(filtroContrato.value.toLowerCase())
    )
  }

  if (filtroTipo.value) {
    filtered = filtered.filter(r => r.tipo_diferencia === filtroTipo.value)
  }

  return filtered
})

// Métodos
const verificarSincronizacion = async () => {
  const result = await Swal.fire({
    title: '¿Verificar Sincronización?',
    text: 'Se compararán todos los contratos activos con el padrón catastral',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#0066cc',
    cancelButtonColor: '#6c757d',
    confirmButtonText: '<i class="fas fa-check"></i> Sí, verificar',
    cancelButtonText: '<i class="fas fa-times"></i> Cancelar',
    customClass: {
      confirmButton: 'btn btn-primary',
      cancelButton: 'btn btn-secondary'
    }
  })

  if (!result.isConfirmed) return

  cargando.value = true
  logProceso.value = []
  agregarLog('info', 'Iniciando verificación de sincronización...')

  try {
    const response = await execute('SP_ASEO_VERIFICAR_SINCRONIZACION_CATASTRO', 'aseo_contratado', {})
    resultados.value = response || []
    tipoOperacion.value = 'Verificación de Sincronización'

    const sincronizados = resultados.value.filter(r => r.tipo_diferencia === 'SINCRONIZADO').length
    const desincronizados = resultados.value.length - sincronizados

    agregarLog('success', `Verificación completada: ${sincronizados} sincronizados, ${desincronizados} con diferencias`)
    await cargarEstadisticas()

    showToast(`Verificación completada: ${resultados.value.length} registros analizados`, 'success')
  } catch (error) {
    hideLoading()
    agregarLog('error', `Error en verificación: ${error.message}`)
    handleApiError(error, 'Error al verificar sincronización')
  } finally {
    cargando.value = false
  }
}

const actualizarDesdeCatastro = async () => {
  const result = await Swal.fire({
    title: '¿Actualizar desde Catastro?',
    html: `
      <div class="text-start">
        <p>Se sincronizarán los datos de domicilio y propietario de todos los contratos con el padrón catastral.</p>
        <div class="alert alert-warning mb-0">
          <i class="fas fa-exclamation-triangle me-2"></i>
          <strong>Esta operación no se puede deshacer.</strong>
        </div>
      </div>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#198754',
    cancelButtonColor: '#6c757d',
    confirmButtonText: '<i class="fas fa-check"></i> Sí, actualizar',
    cancelButtonText: '<i class="fas fa-times"></i> Cancelar'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  logProceso.value = []
  agregarLog('info', 'Iniciando actualización desde catastro...')

  try {
    const response = await execute('SP_ASEO_ACTUALIZAR_DESDE_CATASTRO', 'aseo_contratado', {})

    if (response && response.length > 0) {
      const stats = response[0]
      agregarLog('success', `Actualización completada: ${stats.actualizados} registros sincronizados`)
      agregarLog('info', `${stats.sin_cambios || 0} registros sin cambios`)
      agregarLog('warning', `${stats.errores || 0} errores encontrados`)

      await Swal.fire({
        title: '¡Actualizado!',
        html: `Se sincronizaron <strong>${stats.actualizados}</strong> contrato(s) correctamente`,
        icon: 'success',
        confirmButtonColor: '#198754'
      })

      await cargarEstadisticas()
    }
  } catch (error) {
    hideLoading()
    agregarLog('error', `Error en actualización: ${error.message}`)
    handleApiError(error, 'Error al actualizar desde catastro')
  } finally {
    cargando.value = false
  }
}

const generarReporte = async () => {
  if (resultados.value.length === 0) {
    return showToast('Primero ejecute una verificación', 'warning')
  }

  agregarLog('info', 'Generando reporte de inconsistencias...')
  showToast('Generando reporte Excel...', 'info')

  // Aquí se implementaría la exportación real
  setTimeout(() => {
    agregarLog('success', 'Reporte generado correctamente')
    showToast('Reporte generado (simulado)', 'success')
  }, 1000)
}

const limpiarResultados = () => {
  resultados.value = []
  tipoOperacion.value = ''
  filtroContrato.value = ''
  filtroTipo.value = ''
  showToast('Resultados limpiados', 'info')
}

const agregarLog = (tipo, mensaje) => {
  const hora = new Date().toLocaleTimeString('es-MX')
  logProceso.value.push({ tipo, mensaje, hora })
}

const cargarEstadisticas = async () => {
  try {
    const response = await execute('SP_ASEO_ESTADISTICAS_SINCRONIZACION', 'aseo_contratado', {})
    if (response && response.length > 0) {
      estadisticas.value = response[0]
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const formatTipoDiferencia = (tipo) => {
  const tipos = {
    'SINCRONIZADO': 'Sincronizado',
    'DIFERENCIA_NOMBRE': 'Dif. Nombre',
    'DIFERENCIA_DOMICILIO': 'Dif. Domicilio',
    'SIN_CUENTA': 'Sin Cuenta',
    'NO_EXISTE_CATASTRO': 'No Existe'
  }
  return tipos[tipo] || tipo
}

const getStatusBadge = (tipo) => {
  const badges = {
    'SINCRONIZADO': 'bg-success',
    'DIFERENCIA_NOMBRE': 'bg-warning',
    'DIFERENCIA_DOMICILIO': 'bg-info',
    'SIN_CUENTA': 'bg-danger',
    'NO_EXISTE_CATASTRO': 'bg-danger'
  }
  return badges[tipo] || 'bg-secondary'
}

const getStatusIcon = (tipo) => {
  const icons = {
    'SINCRONIZADO': 'check-circle',
    'DIFERENCIA_NOMBRE': 'exclamation-triangle',
    'DIFERENCIA_DOMICILIO': 'info-circle',
    'SIN_CUENTA': 'times-circle',
    'NO_EXISTE_CATASTRO': 'ban'
  }
  return icons[tipo] || 'question-circle'
}

const getRowClass = (tipo) => {
  if (tipo === 'SINCRONIZADO') return ''
  if (tipo === 'SIN_CUENTA' || tipo === 'NO_EXISTE_CATASTRO') return 'table-danger'
  if (tipo === 'DIFERENCIA_NOMBRE') return 'table-warning'
  return 'table-info'
}

const getLogClass = (tipo) => {
  const classes = {
    'success': 'text-success',
    'error': 'text-danger',
    'warning': 'text-warning',
    'info': 'text-info'
  }
  return classes[tipo] || 'text-muted'
}

const getLogIcon = (tipo) => {
  const icons = {
    'success': 'check-circle',
    'error': 'times-circle',
    'warning': 'exclamation-triangle',
    'info': 'info-circle'
  }
  return icons[tipo] || 'circle'
}

onMounted(() => {
  cargarEstadisticas()
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

