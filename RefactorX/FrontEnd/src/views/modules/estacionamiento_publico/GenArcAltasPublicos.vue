<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-export" /></div>
      <div class="module-view-info">
        <h1>Generar Remesa de Altas</h1>
        <p>sp14_remesa (altas)</p>
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

      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loadingPeriodo" @click="getPeriodo">
          <font-awesome-icon icon="calendar" /> Último periodo
        </button>
        <button class="btn-municipal-primary" :disabled="loading" @click="generar">
          <font-awesome-icon icon="play" /> Generar
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="sliders" class="me-2" />Parámetros de Generación</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Opción</label>
              <input type="number" class="municipal-form-control" v-model.number="opc" placeholder="1" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input type="number" class="municipal-form-control" v-model.number="axo" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Inicio</label>
              <input type="date" class="municipal-form-control" v-model="fec_ini" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Fin</label>
              <input type="date" class="municipal-form-control" v-model="fec_fin" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Actual Fin</label>
              <input type="date" class="municipal-form-control" v-model="fec_a_fin" />
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-export" class="me-2" />Resultado</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Resultado exitoso -->
          <div v-if="resultData" class="result-success">
            <div class="result-icon-container success">
              <font-awesome-icon icon="check-circle" />
            </div>
            <div class="result-content">
              <h4 class="result-title">Remesa de Altas Generada</h4>
              <div class="result-details">
                <div class="result-item">
                  <font-awesome-icon icon="hashtag" class="result-item-icon" />
                  <span class="result-label">Remesa:</span>
                  <span class="result-value highlight">{{ resultData.remesa }}</span>
                </div>
                <div class="result-item">
                  <font-awesome-icon icon="calendar-alt" class="result-item-icon" />
                  <span class="result-label">Periodo:</span>
                  <span class="result-value">{{ fec_ini }} a {{ fec_fin }}</span>
                </div>
                <div class="result-item">
                  <font-awesome-icon icon="calendar-check" class="result-item-icon" />
                  <span class="result-label">Año:</span>
                  <span class="result-value">{{ axo }}</span>
                </div>
                <div class="result-item" v-if="resultData.obs">
                  <font-awesome-icon icon="info-circle" class="result-item-icon" />
                  <span class="result-label">Observación:</span>
                  <span class="result-value">{{ resultData.obs }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Estado vacío con ejemplo -->
          <div v-else class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="file-export" />
            </div>
            <h4 class="empty-state-title">Generación de Remesa de Altas</h4>
            <p class="empty-state-text">Configure los parámetros y presione "Generar" para crear la remesa</p>
            <div class="empty-state-example">
              <div class="example-card">
                <div class="example-header">
                  <font-awesome-icon icon="lightbulb" class="example-icon" />
                  <span>Ejemplo de uso</span>
                </div>
                <div class="example-body">
                  <div class="example-row">
                    <span class="example-label">1. Clic en "Último periodo"</span>
                    <span class="example-value">Carga fechas automáticamente</span>
                  </div>
                  <div class="example-row">
                    <span class="example-label">2. Verificar parámetros</span>
                    <span class="example-value">Año, fechas, opción</span>
                  </div>
                  <div class="example-row">
                    <span class="example-label">3. Clic en "Generar"</span>
                    <span class="example-value">Crea la remesa de altas</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - GenArcAltasPublicos"
    >
      <h3>Gen Arc Altas Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'GenArcAltasPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, nextTick } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const opc = ref(1)
const axo = ref(new Date().getFullYear())
const fec_ini = ref('')
const fec_fin = ref('')
const fec_a_fin = ref('')
const loadingPeriodo = ref(false)
const resultData = ref(null)

async function getPeriodo() {
  showLoading('Cargando...', 'Obteniendo último periodo')
  loadingPeriodo.value = true
  try {
    const resp = await execute('get_periodo_altas', BASE_DB, [], '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const r = Array.isArray(data) ? data[0] : data

    if (r) {
      fec_ini.value = r.fecha_inicio || ''
      fec_fin.value = r.fecha_fin || ''
      fec_a_fin.value = r.fecha_fin || ''
      showToast('success', `Periodo cargado: ${fec_ini.value} a ${fec_fin.value}`)
    } else {
      showToast('info', 'No se encontró información del último periodo')
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    loadingPeriodo.value = false
    hideLoading()
  }
}

async function generar() {
  if (!fec_ini.value || !fec_fin.value) {
    showToast('warning', 'Las fechas de inicio y fin son requeridas')
    return
  }

  // Confirmación con SweetAlert2
  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Generación',
    html: `<p>¿Generar remesa de altas?</p>
      <ul class="swal-list-left">
        <li><strong>Opción:</strong> ${opc.value}</li>
        <li><strong>Año:</strong> ${axo.value}</li>
        <li><strong>Periodo:</strong> ${fec_ini.value} a ${fec_fin.value}</li>
      </ul>`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, generar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Generando...', 'Creando remesa de altas')
  resultData.value = null
  try {
    const params = [
      { nombre: 'p_Opc', valor: opc.value, tipo: 'integer' },
      { nombre: 'p_Axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_Fec_Ini', valor: fec_ini.value, tipo: 'date' },
      { nombre: 'p_Fec_Fin', valor: fec_fin.value, tipo: 'date' },
      { nombre: 'p_Fec_A_Fin', valor: fec_a_fin.value || fec_fin.value, tipo: 'date' }
    ]
    const resp = await execute('sp14_remesa', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const r = Array.isArray(data) ? data[0] : data

    if (r && resp?.success !== false) {
      resultData.value = {
        remesa: r.remesa || 'N/A',
        obs: r.obs || null
      }

      hideLoading()
      await nextTick()
      await Swal.fire({
        icon: 'success',
        title: 'Remesa Generada',
        html: `<p>${r.obs || 'Remesa de altas creada correctamente'}</p>
          <p><strong>Remesa:</strong> ${r.remesa || 'N/A'}</p>`,
        timer: 3000,
        timerProgressBar: true,
        showConfirmButton: false
      })
    } else {
      hideLoading()
      await nextTick()
      await Swal.fire({
        icon: 'warning',
        title: 'Sin Respuesta',
        text: 'El servidor no devolvió información',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (e) {
    handleApiError(e)
    hideLoading()
  }
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

